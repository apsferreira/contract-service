package service

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/institutoitinerante/contract-service/internal/repository"
)

type TemplateService interface {
	CreateTemplate(ctx context.Context, req *model.CreateTemplateRequest) (*model.ContractTemplate, error)
	GetTemplate(ctx context.Context, id uuid.UUID) (*model.ContractTemplate, error)
	ListTemplates(ctx context.Context, productType *string, limit, offset int) ([]model.ContractTemplate, int, error)
	UpdateTemplate(ctx context.Context, id uuid.UUID, req *model.UpdateTemplateRequest) (*model.ContractTemplate, error)
	ActivateTemplate(ctx context.Context, id uuid.UUID) error
}

type templateService struct {
	repo repository.TemplateRepository
}

func NewTemplateService(repo repository.TemplateRepository) TemplateService {
	return &templateService{repo: repo}
}

func (s *templateService) CreateTemplate(ctx context.Context, req *model.CreateTemplateRequest) (*model.ContractTemplate, error) {
	template := &model.ContractTemplate{
		ID:                   uuid.New(),
		ProductType:          req.ProductType,
		Version:              req.Version,
		ContentHTML:          req.ContentHTML,
		RequiresReAcceptance: req.RequiresReAcceptance,
		IsActive:             false,
	}

	if err := s.repo.Create(ctx, template); err != nil {
		return nil, fmt.Errorf("failed to create template: %w", err)
	}

	return template, nil
}

func (s *templateService) GetTemplate(ctx context.Context, id uuid.UUID) (*model.ContractTemplate, error) {
	template, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, fmt.Errorf("failed to get template: %w", err)
	}
	if template == nil {
		return nil, fmt.Errorf("template not found")
	}
	return template, nil
}

func (s *templateService) ListTemplates(ctx context.Context, productType *string, limit, offset int) ([]model.ContractTemplate, int, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}

	templates, total, err := s.repo.List(ctx, productType, limit, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list templates: %w", err)
	}

	return templates, total, nil
}

func (s *templateService) UpdateTemplate(ctx context.Context, id uuid.UUID, req *model.UpdateTemplateRequest) (*model.ContractTemplate, error) {
	template, err := s.repo.Update(ctx, id, req)
	if err != nil {
		return nil, fmt.Errorf("failed to update template: %w", err)
	}
	return template, nil
}

func (s *templateService) ActivateTemplate(ctx context.Context, id uuid.UUID) error {
	template, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return fmt.Errorf("failed to get template: %w", err)
	}
	if template == nil {
		return fmt.Errorf("template not found")
	}

	active := true
	if err := s.repo.DeactivateOthers(ctx, template.ProductType, id); err != nil {
		return fmt.Errorf("failed to deactivate others: %w", err)
	}

	_, err = s.repo.Update(ctx, id, &model.UpdateTemplateRequest{IsActive: &active})
	if err != nil {
		return fmt.Errorf("failed to activate template: %w", err)
	}

	return nil
}
