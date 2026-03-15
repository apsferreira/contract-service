package model

import (
	"time"

	"github.com/google/uuid"
)

type ContractStatus string

const (
	ContractStatusPending  ContractStatus = "pending"
	ContractStatusAccepted ContractStatus = "accepted"
	ContractStatusExpired  ContractStatus = "expired"
	ContractStatusRevoked  ContractStatus = "revoked"
)

type Contract struct {
	ID              uuid.UUID      `json:"id"`
	UserID          uuid.UUID      `json:"user_id"`
	ProductType     string         `json:"product_type"`
	TemplateID      uuid.UUID      `json:"template_id"`
	TemplateVersion string         `json:"template_version"`
	ContentHTML     string         `json:"content_html"`
	ContentHash     string         `json:"content_hash"`
	Variables       map[string]any `json:"variables,omitempty"`
	Status          ContractStatus `json:"status"`
	ExpiresAt       time.Time      `json:"expires_at"`
	PDFPath         *string        `json:"pdf_path,omitempty"`
	PDFGeneratedAt  *time.Time     `json:"pdf_generated_at,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
}

type CreateContractRequest struct {
	UserID      uuid.UUID      `json:"user_id" validate:"required"`
	ProductType string         `json:"product_type" validate:"required"`
	Variables   map[string]any `json:"variables,omitempty"`
}

type CreateContractResponse struct {
	ContractID  uuid.UUID `json:"contract_id"`
	ContentHTML string    `json:"content_html"`
	ExpiresAt   time.Time `json:"expires_at"`
}
