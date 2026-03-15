package repository

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type SignatureRepository interface {
	Create(ctx context.Context, signature *model.ContractSignature) error
	GetByContractID(ctx context.Context, contractID uuid.UUID) (*model.ContractSignature, error)
	GetLastSignature(ctx context.Context) (*model.ContractSignature, error)
	GetByID(ctx context.Context, id uuid.UUID) (*model.ContractSignature, error)
}

type signatureRepository struct {
	db *pgxpool.Pool
}

func NewSignatureRepository(db *pgxpool.Pool) SignatureRepository {
	return &signatureRepository{db: db}
}

func (r *signatureRepository) Create(ctx context.Context, signature *model.ContractSignature) error {
	query := `
		INSERT INTO contract_signatures (id, contract_id, user_id, ip_address, user_agent, 
		                                  session_token_hash, content_hash, prev_hash, record_hash)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		RETURNING created_at
	`
	return r.db.QueryRow(ctx, query,
		signature.ID,
		signature.ContractID,
		signature.UserID,
		signature.IPAddress,
		signature.UserAgent,
		signature.SessionTokenHash,
		signature.ContentHash,
		signature.PrevHash,
		signature.RecordHash,
	).Scan(&signature.CreatedAt)
}

func (r *signatureRepository) GetByContractID(ctx context.Context, contractID uuid.UUID) (*model.ContractSignature, error) {
	query := `
		SELECT id, contract_id, user_id, ip_address, user_agent, session_token_hash, 
		       content_hash, prev_hash, record_hash, created_at
		FROM contract_signatures
		WHERE contract_id = $1
		ORDER BY created_at DESC
		LIMIT 1
	`
	var s model.ContractSignature
	err := r.db.QueryRow(ctx, query, contractID).Scan(
		&s.ID, &s.ContractID, &s.UserID, &s.IPAddress, &s.UserAgent,
		&s.SessionTokenHash, &s.ContentHash, &s.PrevHash, &s.RecordHash, &s.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &s, err
}

func (r *signatureRepository) GetLastSignature(ctx context.Context) (*model.ContractSignature, error) {
	query := `
		SELECT id, contract_id, user_id, ip_address, user_agent, session_token_hash, 
		       content_hash, prev_hash, record_hash, created_at
		FROM contract_signatures
		ORDER BY created_at DESC
		LIMIT 1
	`
	var s model.ContractSignature
	err := r.db.QueryRow(ctx, query).Scan(
		&s.ID, &s.ContractID, &s.UserID, &s.IPAddress, &s.UserAgent,
		&s.SessionTokenHash, &s.ContentHash, &s.PrevHash, &s.RecordHash, &s.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &s, err
}

func (r *signatureRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.ContractSignature, error) {
	query := `
		SELECT id, contract_id, user_id, ip_address, user_agent, session_token_hash, 
		       content_hash, prev_hash, record_hash, created_at
		FROM contract_signatures
		WHERE id = $1
	`
	var s model.ContractSignature
	err := r.db.QueryRow(ctx, query, id).Scan(
		&s.ID, &s.ContractID, &s.UserID, &s.IPAddress, &s.UserAgent,
		&s.SessionTokenHash, &s.ContentHash, &s.PrevHash, &s.RecordHash, &s.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	return &s, err
}
