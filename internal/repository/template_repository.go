package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type TemplateRepository interface {
	Create(ctx context.Context, template *model.ContractTemplate) error
	GetByID(ctx context.Context, id uuid.UUID) (*model.ContractTemplate, error)
	GetActiveByProductType(ctx context.Context, productType string) (*model.ContractTemplate, error)
	List(ctx context.Context, productType *string, limit, offset int) ([]model.ContractTemplate, int, error)
	Update(ctx context.Context, id uuid.UUID, req *model.UpdateTemplateRequest) (*model.ContractTemplate, error)
	DeactivateOthers(ctx context.Context, productType string, exceptID uuid.UUID) error
}

type templateRepository struct {
	db *pgxpool.Pool
}

func NewTemplateRepository(db *pgxpool.Pool) TemplateRepository {
	return &templateRepository{db: db}
}

func (r *templateRepository) Create(ctx context.Context, template *model.ContractTemplate) error {
	query := `
		INSERT INTO contract_templates (id, product_type, version, content_html, requires_re_acceptance, is_active)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING created_at, updated_at
	`
	return r.db.QueryRow(ctx, query,
		template.ID,
		template.ProductType,
		template.Version,
		template.ContentHTML,
		template.RequiresReAcceptance,
		template.IsActive,
	).Scan(&template.CreatedAt, &template.UpdatedAt)
}

func (r *templateRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.ContractTemplate, error) {
	query := `
		SELECT id, product_type, version, content_html, requires_re_acceptance, is_active, 
		       created_at, updated_at, deactivated_at
		FROM contract_templates
		WHERE id = $1
	`
	var t model.ContractTemplate
	err := r.db.QueryRow(ctx, query, id).Scan(
		&t.ID, &t.ProductType, &t.Version, &t.ContentHTML, &t.RequiresReAcceptance,
		&t.IsActive, &t.CreatedAt, &t.UpdatedAt, &t.DeactivatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &t, err
}

func (r *templateRepository) GetActiveByProductType(ctx context.Context, productType string) (*model.ContractTemplate, error) {
	query := `
		SELECT id, product_type, version, content_html, requires_re_acceptance, is_active, 
		       created_at, updated_at, deactivated_at
		FROM contract_templates
		WHERE product_type = $1 AND is_active = true
		ORDER BY created_at DESC
		LIMIT 1
	`
	var t model.ContractTemplate
	err := r.db.QueryRow(ctx, query, productType).Scan(
		&t.ID, &t.ProductType, &t.Version, &t.ContentHTML, &t.RequiresReAcceptance,
		&t.IsActive, &t.CreatedAt, &t.UpdatedAt, &t.DeactivatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &t, err
}

func (r *templateRepository) List(ctx context.Context, productType *string, limit, offset int) ([]model.ContractTemplate, int, error) {
	var templates []model.ContractTemplate
	var total int

	countQuery := "SELECT COUNT(*) FROM contract_templates"
	query := `
		SELECT id, product_type, version, content_html, requires_re_acceptance, is_active, 
		       created_at, updated_at, deactivated_at
		FROM contract_templates
	`
	args := []any{}
	if productType != nil {
		countQuery += " WHERE product_type = $1"
		query += " WHERE product_type = $1"
		args = append(args, *productType)
	}

	err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, err
	}

	query += " ORDER BY created_at DESC LIMIT $" + string(rune(len(args)+1)) + " OFFSET $" + string(rune(len(args)+2))
	args = append(args, limit, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	for rows.Next() {
		var t model.ContractTemplate
		err := rows.Scan(
			&t.ID, &t.ProductType, &t.Version, &t.ContentHTML, &t.RequiresReAcceptance,
			&t.IsActive, &t.CreatedAt, &t.UpdatedAt, &t.DeactivatedAt,
		)
		if err != nil {
			return nil, 0, err
		}
		templates = append(templates, t)
	}

	return templates, total, rows.Err()
}

func (r *templateRepository) Update(ctx context.Context, id uuid.UUID, req *model.UpdateTemplateRequest) (*model.ContractTemplate, error) {
	updates := []string{}
	args := []any{id}
	argPos := 2

	if req.ContentHTML != nil {
		updates = append(updates, "content_html = $"+string(rune('0'+argPos)))
		args = append(args, *req.ContentHTML)
		argPos++
	}
	if req.RequiresReAcceptance != nil {
		updates = append(updates, "requires_re_acceptance = $"+string(rune('0'+argPos)))
		args = append(args, *req.RequiresReAcceptance)
		argPos++
	}
	if req.IsActive != nil {
		updates = append(updates, "is_active = $"+string(rune('0'+argPos)))
		args = append(args, *req.IsActive)
		if !*req.IsActive {
			updates = append(updates, "deactivated_at = CURRENT_TIMESTAMP")
		}
	}

	if len(updates) == 0 {
		return r.GetByID(ctx, id)
	}

	query := "UPDATE contract_templates SET " + updates[0]
	for i := 1; i < len(updates); i++ {
		query += ", " + updates[i]
	}
	query += " WHERE id = $1"

	_, err := r.db.Exec(ctx, query, args...)
	if err != nil {
		return nil, err
	}

	return r.GetByID(ctx, id)
}

func (r *templateRepository) DeactivateOthers(ctx context.Context, productType string, exceptID uuid.UUID) error {
	query := `
		UPDATE contract_templates 
		SET is_active = false, deactivated_at = $1
		WHERE product_type = $2 AND id != $3 AND is_active = true
	`
	_, err := r.db.Exec(ctx, query, time.Now(), productType, exceptID)
	return err
}
