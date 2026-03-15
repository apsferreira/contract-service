package model

import (
	"time"

	"github.com/google/uuid"
)

type ContractSignature struct {
	ID               uuid.UUID `json:"id"`
	ContractID       uuid.UUID `json:"contract_id"`
	UserID           uuid.UUID `json:"user_id"`
	IPAddress        string    `json:"ip_address"`
	UserAgent        string    `json:"user_agent"`
	SessionTokenHash string    `json:"session_token_hash"`
	ContentHash      string    `json:"content_hash"`
	PrevHash         *string   `json:"prev_hash,omitempty"`
	RecordHash       string    `json:"record_hash"`
	CreatedAt        time.Time `json:"created_at"`
}

type AcceptContractRequest struct {
	IPAddress        string `json:"ip_address" validate:"required"`
	UserAgent        string `json:"user_agent" validate:"required"`
	SessionTokenHash string `json:"session_token_hash" validate:"required"`
}

type AcceptContractResponse struct {
	SignatureID uuid.UUID  `json:"signature_id"`
	AcceptedAt  time.Time  `json:"accepted_at"`
	PDFUrl      *string    `json:"pdf_url,omitempty"`
}
