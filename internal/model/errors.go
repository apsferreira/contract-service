package model

import "errors"

// BKL-959: erros de domínio tipados permitem mapeamento HTTP sem string comparison.
var (
	ErrContractNotFound    = errors.New("contract not found")
	ErrContractUnauthorized = errors.New("unauthorized: contract belongs to different user")
	ErrContractAlreadyAccepted = errors.New("contract already accepted")
	ErrContractExpired     = errors.New("contract expired")
	ErrTemplateNotFound    = errors.New("no active template found")
)
