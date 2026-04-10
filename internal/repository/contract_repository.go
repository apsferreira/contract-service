package repository

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ContractRepository interface {
	Create(ctx context.Context, contract *model.Contract) error
	GetByID(ctx context.Context, id uuid.UUID) (*model.Contract, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status model.ContractStatus) error
	UpdateContent(ctx context.Context, id uuid.UUID, contentHTML, contentHash string) error
	// UpdateStatusTx executa UpdateStatus dentro da transação fornecida.
	UpdateStatusTx(ctx context.Context, tx pgx.Tx, id uuid.UUID, status model.ContractStatus) error
	// UpdateContentTx executa UpdateContent dentro da transação fornecida.
	UpdateContentTx(ctx context.Context, tx pgx.Tx, id uuid.UUID, contentHTML, contentHash string) error
	UpdatePDFPath(ctx context.Context, id uuid.UUID, pdfPath string) error
	ListByUser(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Contract, int, error)
	// BeginTx inicia uma transação pgx.
	BeginTx(ctx context.Context) (pgx.Tx, error)
}

type contractRepository struct {
	db *pgxpool.Pool
}

func NewContractRepository(db *pgxpool.Pool) ContractRepository {
	return &contractRepository{db: db}
}

func (r *contractRepository) BeginTx(ctx context.Context) (pgx.Tx, error) {
	return r.db.Begin(ctx)
}

func (r *contractRepository) Create(ctx context.Context, contract *model.Contract) error {
	variablesJSON, _ := json.Marshal(contract.Variables)

	query := `
		INSERT INTO contracts (id, user_id, product_type, template_id, template_version,
		                       content_html, content_hash, variables, status, expires_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING created_at, updated_at
	`
	return r.db.QueryRow(ctx, query,
		contract.ID,
		contract.UserID,
		contract.ProductType,
		contract.TemplateID,
		contract.TemplateVersion,
		contract.ContentHTML,
		contract.ContentHash,
		variablesJSON,
		contract.Status,
		contract.ExpiresAt,
	).Scan(&contract.CreatedAt, &contract.UpdatedAt)
}

func (r *contractRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Contract, error) {
	query := `
		SELECT id, user_id, product_type, template_id, template_version, content_html, 
		       content_hash, variables, status, expires_at, pdf_path, pdf_generated_at,
		       created_at, updated_at
		FROM contracts
		WHERE id = $1
	`
	var c model.Contract
	var variablesJSON []byte
	
	err := r.db.QueryRow(ctx, query, id).Scan(
		&c.ID, &c.UserID, &c.ProductType, &c.TemplateID, &c.TemplateVersion,
		&c.ContentHTML, &c.ContentHash, &variablesJSON, &c.Status, &c.ExpiresAt,
		&c.PDFPath, &c.PDFGeneratedAt, &c.CreatedAt, &c.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	if len(variablesJSON) > 0 {
		if err := json.Unmarshal(variablesJSON, &c.Variables); err != nil {
			return nil, err
		}
	}

	return &c, nil
}

func (r *contractRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status model.ContractStatus) error {
	query := `UPDATE contracts SET status = $1 WHERE id = $2`
	_, err := r.db.Exec(ctx, query, status, id)
	return err
}

func (r *contractRepository) UpdateStatusTx(ctx context.Context, tx pgx.Tx, id uuid.UUID, status model.ContractStatus) error {
	query := `UPDATE contracts SET status = $1 WHERE id = $2`
	_, err := tx.Exec(ctx, query, status, id)
	return err
}

func (r *contractRepository) UpdateContent(ctx context.Context, id uuid.UUID, contentHTML, contentHash string) error {
	query := `UPDATE contracts SET content_html = $1, content_hash = $2 WHERE id = $3`
	_, err := r.db.Exec(ctx, query, contentHTML, contentHash, id)
	return err
}

func (r *contractRepository) UpdateContentTx(ctx context.Context, tx pgx.Tx, id uuid.UUID, contentHTML, contentHash string) error {
	query := `UPDATE contracts SET content_html = $1, content_hash = $2 WHERE id = $3`
	_, err := tx.Exec(ctx, query, contentHTML, contentHash, id)
	return err
}

func (r *contractRepository) UpdatePDFPath(ctx context.Context, id uuid.UUID, pdfPath string) error {
	query := `UPDATE contracts SET pdf_path = $1, pdf_generated_at = CURRENT_TIMESTAMP WHERE id = $2`
	_, err := r.db.Exec(ctx, query, pdfPath, id)
	return err
}

func (r *contractRepository) ListByUser(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Contract, int, error) {
	var contracts []model.Contract
	var total int

	countQuery := "SELECT COUNT(*) FROM contracts WHERE user_id = $1"
	err := r.db.QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	query := `
		SELECT id, user_id, product_type, template_id, template_version, content_html, 
		       content_hash, variables, status, expires_at, pdf_path, pdf_generated_at,
		       created_at, updated_at
		FROM contracts
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	for rows.Next() {
		var c model.Contract
		var variablesJSON []byte
		
		err := rows.Scan(
			&c.ID, &c.UserID, &c.ProductType, &c.TemplateID, &c.TemplateVersion,
			&c.ContentHTML, &c.ContentHash, &variablesJSON, &c.Status, &c.ExpiresAt,
			&c.PDFPath, &c.PDFGeneratedAt, &c.CreatedAt, &c.UpdatedAt,
		)
		if err != nil {
			return nil, 0, err
		}

		if len(variablesJSON) > 0 {
			if err := json.Unmarshal(variablesJSON, &c.Variables); err != nil {
				return nil, 0, err
			}
		}

		contracts = append(contracts, c)
	}

	return contracts, total, rows.Err()
}
