package model

import "errors"

// BKL-959: erros de domínio tipados permitem mapeamento HTTP sem string comparison.
// BKL-960: mensagens em português para consistência com padrão IIT.
var (
	ErrContractNotFound        = errors.New("contrato não encontrado")
	ErrContractUnauthorized    = errors.New("não autorizado: contrato pertence a outro usuário")
	ErrContractAlreadyAccepted = errors.New("contrato já foi aceito")
	ErrContractExpired         = errors.New("contrato expirado")
	ErrTemplateNotFound        = errors.New("template ativo não encontrado")
)
