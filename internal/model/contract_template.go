package model

import (
	"time"

	"github.com/google/uuid"
)

type ContractTemplate struct {
	ID                   uuid.UUID  `json:"id"`
	ProductType          string     `json:"product_type"`
	Version              string     `json:"version"`
	ContentHTML          string     `json:"content_html"`
	RequiresReAcceptance bool       `json:"requires_re_acceptance"`
	IsActive             bool       `json:"is_active"`
	CreatedAt            time.Time  `json:"created_at"`
	UpdatedAt            time.Time  `json:"updated_at"`
	DeactivatedAt        *time.Time `json:"deactivated_at,omitempty"`
}

type CreateTemplateRequest struct {
	ProductType          string `json:"product_type" validate:"required"`
	Version              string `json:"version" validate:"required"`
	ContentHTML          string `json:"content_html" validate:"required"`
	RequiresReAcceptance bool   `json:"requires_re_acceptance"`
}

type UpdateTemplateRequest struct {
	ContentHTML          *string `json:"content_html,omitempty"`
	RequiresReAcceptance *bool   `json:"requires_re_acceptance,omitempty"`
	IsActive             *bool   `json:"is_active,omitempty"`
}
