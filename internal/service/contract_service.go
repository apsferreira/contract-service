package service

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/institutoitinerante/contract-service/internal/repository"
)

type ContractService interface {
	CreateContract(ctx context.Context, req *model.CreateContractRequest) (*model.CreateContractResponse, error)
	AcceptContract(ctx context.Context, contractID uuid.UUID, userID uuid.UUID, req *model.AcceptContractRequest) (*model.AcceptContractResponse, error)
	GetContract(ctx context.Context, id uuid.UUID) (*model.Contract, error)
	ListUserContracts(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Contract, int, error)
}

type contractService struct {
	contractRepo  repository.ContractRepository
	templateRepo  repository.TemplateRepository
	signatureRepo repository.SignatureRepository
}

func NewContractService(
	contractRepo repository.ContractRepository,
	templateRepo repository.TemplateRepository,
	signatureRepo repository.SignatureRepository,
) ContractService {
	return &contractService{
		contractRepo:  contractRepo,
		templateRepo:  templateRepo,
		signatureRepo: signatureRepo,
	}
}

func (s *contractService) CreateContract(ctx context.Context, req *model.CreateContractRequest) (*model.CreateContractResponse, error) {
	template, err := s.templateRepo.GetActiveByProductType(ctx, req.ProductType)
	if err != nil {
		return nil, fmt.Errorf("failed to get active template: %w", err)
	}
	if template == nil {
		return nil, fmt.Errorf("no active template found for product type: %s", req.ProductType)
	}

	renderedHTML := s.renderTemplate(template.ContentHTML, req.Variables)
	contentHash := s.calculateSHA256(renderedHTML)

	contract := &model.Contract{
		ID:              uuid.New(),
		UserID:          req.UserID,
		ProductType:     req.ProductType,
		TemplateID:      template.ID,
		TemplateVersion: template.Version,
		ContentHTML:     renderedHTML,
		ContentHash:     contentHash,
		Variables:       req.Variables,
		Status:          model.ContractStatusPending,
		ExpiresAt:       time.Now().Add(60 * time.Minute),
	}

	if err := s.contractRepo.Create(ctx, contract); err != nil {
		return nil, fmt.Errorf("failed to create contract: %w", err)
	}

	return &model.CreateContractResponse{
		ContractID:  contract.ID,
		ContentHTML: contract.ContentHTML,
		ExpiresAt:   contract.ExpiresAt,
	}, nil
}

func (s *contractService) AcceptContract(ctx context.Context, contractID uuid.UUID, userID uuid.UUID, req *model.AcceptContractRequest) (*model.AcceptContractResponse, error) {
	contract, err := s.contractRepo.GetByID(ctx, contractID)
	if err != nil {
		return nil, fmt.Errorf("failed to get contract: %w", err)
	}
	if contract == nil {
		return nil, fmt.Errorf("contract not found")
	}

	if contract.UserID != userID {
		return nil, fmt.Errorf("unauthorized: contract belongs to different user")
	}

	if contract.Status == model.ContractStatusAccepted {
		return nil, fmt.Errorf("contract already accepted")
	}

	if time.Now().After(contract.ExpiresAt) {
		_ = s.contractRepo.UpdateStatus(ctx, contractID, model.ContractStatusExpired)
		return nil, fmt.Errorf("contract expired")
	}

	lastSignature, err := s.signatureRepo.GetLastSignature(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get last signature: %w", err)
	}

	var prevHash *string
	if lastSignature != nil {
		prevHash = &lastSignature.RecordHash
	}

	signature := &model.ContractSignature{
		ID:               uuid.New(),
		ContractID:       contractID,
		UserID:           userID,
		IPAddress:        req.IPAddress,
		UserAgent:        req.UserAgent,
		SessionTokenHash: req.SessionTokenHash,
		ContentHash:      contract.ContentHash,
		PrevHash:         prevHash,
	}

	signature.RecordHash = s.calculateRecordHash(signature)

	if err := s.signatureRepo.Create(ctx, signature); err != nil {
		return nil, fmt.Errorf("failed to create signature: %w", err)
	}

	if err := s.contractRepo.UpdateStatus(ctx, contractID, model.ContractStatusAccepted); err != nil {
		return nil, fmt.Errorf("failed to update contract status: %w", err)
	}

	return &model.AcceptContractResponse{
		SignatureID: signature.ID,
		AcceptedAt:  signature.CreatedAt,
		PDFUrl:      nil,
	}, nil
}

func (s *contractService) GetContract(ctx context.Context, id uuid.UUID) (*model.Contract, error) {
	contract, err := s.contractRepo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get contract: %w", err)
	}
	if contract == nil {
		return nil, fmt.Errorf("contract not found")
	}
	return contract, nil
}

func (s *contractService) ListUserContracts(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Contract, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	contracts, total, err := s.contractRepo.ListByUser(ctx, userID, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list contracts: %w", err)
	}

	return contracts, total, nil
}

func (s *contractService) renderTemplate(template string, variables map[string]any) string {
	rendered := template
	for key, value := range variables {
		placeholder := fmt.Sprintf("{{%s}}", key)
		rendered = strings.ReplaceAll(rendered, placeholder, fmt.Sprint(value))
	}
	return rendered
}

func (s *contractService) calculateSHA256(data string) string {
	hash := sha256.Sum256([]byte(data))
	return hex.EncodeToString(hash[:])
}

func (s *contractService) calculateRecordHash(sig *model.ContractSignature) string {
	prevHashStr := ""
	if sig.PrevHash != nil {
		prevHashStr = *sig.PrevHash
	}

	data := fmt.Sprintf("%s|%s|%s|%s|%s|%s|%s",
		sig.ContractID.String(),
		sig.UserID.String(),
		sig.IPAddress,
		sig.SessionTokenHash,
		sig.ContentHash,
		prevHashStr,
		sig.ID.String(),
	)

	return s.calculateSHA256(data)
}
