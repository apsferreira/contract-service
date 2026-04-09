package service

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
)

// ── GetContract ───────────────────────────────────────────────────────────────

func TestGetContract_Success(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}
	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	userID := uuid.New()
	contractID := uuid.New()
	contractRepo.contracts[contractID] = &model.Contract{
		ID:          contractID,
		UserID:      userID,
		ProductType: "plano-premium",
		Status:      model.ContractStatusPending,
		ContentHTML: "<p>Contrato</p>",
		ContentHash: "abc123",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	result, err := svc.GetContract(context.Background(), contractID)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if result == nil {
		t.Fatal("esperava contrato não-nil")
	}
	if result.ID != contractID {
		t.Errorf("ID incorreto: got %v", result.ID)
	}
}

func TestGetContract_NotFound(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}
	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	_, err := svc.GetContract(context.Background(), uuid.New())
	if err == nil {
		t.Fatal("esperava erro para contrato não encontrado")
	}
}

// ── ListUserContracts ─────────────────────────────────────────────────────────

func TestListUserContracts_Success(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}
	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	userID := uuid.New()
	for i := 0; i < 3; i++ {
		id := uuid.New()
		contractRepo.contracts[id] = &model.Contract{
			ID:        id,
			UserID:    userID,
			Status:    model.ContractStatusPending,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
	}
	// Contrato de outro usuário — não deve aparecer
	otherID := uuid.New()
	contractRepo.contracts[otherID] = &model.Contract{
		ID:     otherID,
		UserID: uuid.New(),
		Status: model.ContractStatusPending,
	}

	contracts, total, err := svc.ListUserContracts(context.Background(), userID, 20, 0)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if total != 3 {
		t.Errorf("esperava 3 contratos, got %d", total)
	}
	if len(contracts) != 3 {
		t.Errorf("esperava 3 contratos no slice, got %d", len(contracts))
	}
}

func TestListUserContracts_DefaultLimit(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}
	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	// Limit 0 deve aplicar padrão 20
	_, _, err := svc.ListUserContracts(context.Background(), uuid.New(), 0, 0)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
}

func TestListUserContracts_MaxLimit(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}
	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	// Limit > 100 deve ser capped — o mock não verifica, mas valida que não retorna erro
	_, _, err := svc.ListUserContracts(context.Background(), uuid.New(), 500, 0)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
}

// ── TemplateService ───────────────────────────────────────────────────────────

// mockTemplateRepoFull implementa TemplateRepository com dados reais para testar o service.
type mockTemplateRepoFull struct {
	templates   map[uuid.UUID]*model.ContractTemplate
	createErr   error
	updateErr   error
	deactivateErr error
}

func newMockTemplateRepoFull() *mockTemplateRepoFull {
	return &mockTemplateRepoFull{templates: make(map[uuid.UUID]*model.ContractTemplate)}
}

func (m *mockTemplateRepoFull) Create(ctx context.Context, template *model.ContractTemplate) error {
	if m.createErr != nil {
		return m.createErr
	}
	template.CreatedAt = time.Now()
	m.templates[template.ID] = template
	return nil
}

func (m *mockTemplateRepoFull) GetByID(ctx context.Context, id uuid.UUID) (*model.ContractTemplate, error) {
	t, ok := m.templates[id]
	if !ok {
		return nil, nil
	}
	return t, nil
}

func (m *mockTemplateRepoFull) GetActiveByProductType(ctx context.Context, productType string) (*model.ContractTemplate, error) {
	for _, t := range m.templates {
		if t.ProductType == productType && t.IsActive {
			return t, nil
		}
	}
	return nil, nil
}

func (m *mockTemplateRepoFull) List(ctx context.Context, productType *string, limit, offset int) ([]model.ContractTemplate, int, error) {
	var result []model.ContractTemplate
	for _, t := range m.templates {
		if productType == nil || t.ProductType == *productType {
			result = append(result, *t)
		}
	}
	return result, len(result), nil
}

func (m *mockTemplateRepoFull) Update(ctx context.Context, id uuid.UUID, req *model.UpdateTemplateRequest) (*model.ContractTemplate, error) {
	if m.updateErr != nil {
		return nil, m.updateErr
	}
	t, ok := m.templates[id]
	if !ok {
		return nil, fmt.Errorf("template not found")
	}
	if req.IsActive != nil {
		t.IsActive = *req.IsActive
	}
	if req.ContentHTML != nil {
		t.ContentHTML = *req.ContentHTML
	}
	m.templates[id] = t
	return t, nil
}

func (m *mockTemplateRepoFull) DeactivateOthers(ctx context.Context, productType string, exceptID uuid.UUID) error {
	if m.deactivateErr != nil {
		return m.deactivateErr
	}
	for id, t := range m.templates {
		if t.ProductType == productType && id != exceptID {
			t.IsActive = false
			m.templates[id] = t
		}
	}
	return nil
}

func TestTemplateService_CreateTemplate_Success(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	result, err := svc.CreateTemplate(context.Background(), &model.CreateTemplateRequest{
		ProductType: "plano-basic",
		Version:     "1.0",
		ContentHTML: "<p>Contrato básico</p>",
	})
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if result == nil {
		t.Fatal("esperava template não-nil")
	}
	if result.IsActive {
		t.Error("novo template não deve ser ativo por padrão")
	}
	if result.ProductType != "plano-basic" {
		t.Errorf("ProductType incorreto: %s", result.ProductType)
	}
}

func TestTemplateService_CreateTemplate_RepoError(t *testing.T) {
	repo := newMockTemplateRepoFull()
	repo.createErr = fmt.Errorf("db error")
	svc := NewTemplateService(repo)

	_, err := svc.CreateTemplate(context.Background(), &model.CreateTemplateRequest{
		ProductType: "plano",
		Version:     "1.0",
		ContentHTML: "<p>x</p>",
	})
	if err == nil {
		t.Fatal("esperava erro de repositório")
	}
}

func TestTemplateService_GetTemplate_Success(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	templateID := uuid.New()
	repo.templates[templateID] = &model.ContractTemplate{
		ID:          templateID,
		ProductType: "plano",
		Version:     "1.0",
		ContentHTML: "<p>X</p>",
		IsActive:    true,
	}

	result, err := svc.GetTemplate(context.Background(), templateID)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if result == nil {
		t.Fatal("esperava template não-nil")
	}
	if result.ID != templateID {
		t.Errorf("ID incorreto")
	}
}

func TestTemplateService_GetTemplate_NotFound(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	_, err := svc.GetTemplate(context.Background(), uuid.New())
	if err == nil {
		t.Fatal("esperava erro para template não encontrado")
	}
}

func TestTemplateService_ListTemplates_DefaultLimit(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	// Limit 0 deve aplicar padrão
	_, _, err := svc.ListTemplates(context.Background(), nil, 0, 0)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
}

func TestTemplateService_ListTemplates_WithProductType(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	// Preencher repo com templates
	for i := 0; i < 3; i++ {
		id := uuid.New()
		repo.templates[id] = &model.ContractTemplate{
			ID:          id,
			ProductType: "plano-premium",
			Version:     fmt.Sprintf("1.%d", i),
			ContentHTML: "<p>X</p>",
		}
	}
	// Template de outro tipo
	otherId := uuid.New()
	repo.templates[otherId] = &model.ContractTemplate{
		ID:          otherId,
		ProductType: "plano-basic",
		Version:     "1.0",
		ContentHTML: "<p>Y</p>",
	}

	productType := "plano-premium"
	templates, total, err := svc.ListTemplates(context.Background(), &productType, 20, 0)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if total != 3 {
		t.Errorf("esperava 3 templates, got %d (total=%d)", len(templates), total)
	}
}

func TestTemplateService_UpdateTemplate_Success(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	templateID := uuid.New()
	repo.templates[templateID] = &model.ContractTemplate{
		ID:          templateID,
		ProductType: "plano",
		Version:     "1.0",
		ContentHTML: "<p>Antigo</p>",
	}

	newContent := "<p>Novo conteúdo</p>"
	result, err := svc.UpdateTemplate(context.Background(), templateID, &model.UpdateTemplateRequest{
		ContentHTML: &newContent,
	})
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}
	if result.ContentHTML != newContent {
		t.Errorf("conteúdo não atualizado: got %s", result.ContentHTML)
	}
}

func TestTemplateService_ActivateTemplate_Success(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	// Dois templates do mesmo tipo, um ativo
	idAtivo := uuid.New()
	idNovo := uuid.New()
	repo.templates[idAtivo] = &model.ContractTemplate{
		ID:          idAtivo,
		ProductType: "plano",
		Version:     "1.0",
		ContentHTML: "<p>v1</p>",
		IsActive:    true,
	}
	repo.templates[idNovo] = &model.ContractTemplate{
		ID:          idNovo,
		ProductType: "plano",
		Version:     "2.0",
		ContentHTML: "<p>v2</p>",
		IsActive:    false,
	}

	err := svc.ActivateTemplate(context.Background(), idNovo)
	if err != nil {
		t.Fatalf("erro inesperado: %v", err)
	}

	// Verificar que o novo está ativo e o antigo foi desativado
	if !repo.templates[idNovo].IsActive {
		t.Error("esperava template novo ativo")
	}
	if repo.templates[idAtivo].IsActive {
		t.Error("esperava template antigo desativado")
	}
}

func TestTemplateService_ActivateTemplate_NotFound(t *testing.T) {
	repo := newMockTemplateRepoFull()
	svc := NewTemplateService(repo)

	err := svc.ActivateTemplate(context.Background(), uuid.New())
	if err == nil {
		t.Fatal("esperava erro para template não encontrado")
	}
}
