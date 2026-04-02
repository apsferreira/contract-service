package service

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
)

type mockContractRepo struct {
	contracts map[uuid.UUID]*model.Contract
}

func (m *mockContractRepo) Create(ctx context.Context, contract *model.Contract) error {
	contract.CreatedAt = time.Now()
	contract.UpdatedAt = time.Now()
	m.contracts[contract.ID] = contract
	return nil
}

func (m *mockContractRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.Contract, error) {
	return m.contracts[id], nil
}

func (m *mockContractRepo) UpdateStatus(ctx context.Context, id uuid.UUID, status model.ContractStatus) error {
	if c, ok := m.contracts[id]; ok {
		c.Status = status
	}
	return nil
}

func (m *mockContractRepo) UpdateContent(ctx context.Context, id uuid.UUID, contentHTML, contentHash string) error {
	if c, ok := m.contracts[id]; ok {
		c.ContentHTML = contentHTML
		c.ContentHash = contentHash
	}
	return nil
}

func (m *mockContractRepo) UpdatePDFPath(ctx context.Context, id uuid.UUID, pdfPath string) error {
	if c, ok := m.contracts[id]; ok {
		c.PDFPath = &pdfPath
	}
	return nil
}

func (m *mockContractRepo) ListByUser(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Contract, int, error) {
	var result []model.Contract
	for _, c := range m.contracts {
		if c.UserID == userID {
			result = append(result, *c)
		}
	}
	return result, len(result), nil
}

type mockTemplateRepo struct {
	templates map[string]*model.ContractTemplate
}

func (m *mockTemplateRepo) Create(ctx context.Context, template *model.ContractTemplate) error {
	return nil
}

func (m *mockTemplateRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.ContractTemplate, error) {
	return nil, nil
}

func (m *mockTemplateRepo) GetActiveByProductType(ctx context.Context, productType string) (*model.ContractTemplate, error) {
	return m.templates[productType], nil
}

func (m *mockTemplateRepo) List(ctx context.Context, productType *string, limit, offset int) ([]model.ContractTemplate, int, error) {
	return nil, 0, nil
}

func (m *mockTemplateRepo) Update(ctx context.Context, id uuid.UUID, req *model.UpdateTemplateRequest) (*model.ContractTemplate, error) {
	return nil, nil
}

func (m *mockTemplateRepo) DeactivateOthers(ctx context.Context, productType string, exceptID uuid.UUID) error {
	return nil
}

type mockSignatureRepo struct {
	signatures map[uuid.UUID]*model.ContractSignature
	lastSig    *model.ContractSignature
}

func (m *mockSignatureRepo) Create(ctx context.Context, signature *model.ContractSignature) error {
	signature.CreatedAt = time.Now()
	m.signatures[signature.ID] = signature
	m.lastSig = signature
	return nil
}

func (m *mockSignatureRepo) GetByContractID(ctx context.Context, contractID uuid.UUID) (*model.ContractSignature, error) {
	for _, s := range m.signatures {
		if s.ContractID == contractID {
			return s, nil
		}
	}
	return nil, nil
}

func (m *mockSignatureRepo) GetLastSignature(ctx context.Context) (*model.ContractSignature, error) {
	return m.lastSig, nil
}

func (m *mockSignatureRepo) GetByID(ctx context.Context, id uuid.UUID) (*model.ContractSignature, error) {
	return m.signatures[id], nil
}

func TestCreateContract(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{
		templates: map[string]*model.ContractTemplate{
			"brio": {
				ID:          uuid.New(),
				ProductType: "brio",
				Version:     "1.0",
				ContentHTML: "<h1>Contract for {{user_name}}</h1>",
				IsActive:    true,
			},
		},
	}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}

	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	req := &model.CreateContractRequest{
		UserID:      uuid.New(),
		ProductType: "brio",
		Variables:   map[string]any{"user_name": "John Doe"},
	}

	resp, err := svc.CreateContract(context.Background(), req)
	if err != nil {
		t.Fatalf("CreateContract failed: %v", err)
	}

	if resp.ContractID == uuid.Nil {
		t.Error("Expected valid contract ID")
	}

	if resp.ContentHTML != "<h1>Contract for John Doe</h1>" {
		t.Errorf("Expected rendered HTML, got: %s", resp.ContentHTML)
	}

	if resp.ExpiresAt.Before(time.Now()) {
		t.Error("ExpiresAt should be in the future")
	}
}

func TestAcceptContract(t *testing.T) {
	userID := uuid.New()
	contractID := uuid.New()

	contractRepo := &mockContractRepo{
		contracts: map[uuid.UUID]*model.Contract{
			contractID: {
				ID:          contractID,
				UserID:      userID,
				ProductType: "brio",
				ContentHash: "abc123",
				Status:      model.ContractStatusPending,
				ExpiresAt:   time.Now().Add(30 * time.Minute),
			},
		},
	}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}

	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	req := &model.AcceptContractRequest{
		IPAddress:        "192.168.1.1",
		UserAgent:        "Mozilla/5.0",
		SessionTokenHash: "session123",
	}

	resp, err := svc.AcceptContract(context.Background(), contractID, userID, req)
	if err != nil {
		t.Fatalf("AcceptContract failed: %v", err)
	}

	if resp.SignatureID == uuid.Nil {
		t.Error("Expected valid signature ID")
	}

	contract, _ := contractRepo.GetByID(context.Background(), contractID)
	if contract.Status != model.ContractStatusAccepted {
		t.Errorf("Expected contract status to be accepted, got: %s", contract.Status)
	}
}

func TestAcceptContractExpired(t *testing.T) {
	userID := uuid.New()
	contractID := uuid.New()

	contractRepo := &mockContractRepo{
		contracts: map[uuid.UUID]*model.Contract{
			contractID: {
				ID:        contractID,
				UserID:    userID,
				Status:    model.ContractStatusPending,
				ExpiresAt: time.Now().Add(-10 * time.Minute),
			},
		},
	}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}

	svc := NewContractService(contractRepo, templateRepo, signatureRepo)

	req := &model.AcceptContractRequest{
		IPAddress:        "192.168.1.1",
		UserAgent:        "Mozilla/5.0",
		SessionTokenHash: "session123",
	}

	_, err := svc.AcceptContract(context.Background(), contractID, userID, req)
	if err == nil {
		t.Error("Expected error for expired contract")
	}
	if err.Error() != "contract expired" {
		t.Errorf("Expected 'contract expired' error, got: %s", err.Error())
	}
}

func TestHashChain(t *testing.T) {
	contractRepo := &mockContractRepo{contracts: make(map[uuid.UUID]*model.Contract)}
	templateRepo := &mockTemplateRepo{templates: make(map[string]*model.ContractTemplate)}
	signatureRepo := &mockSignatureRepo{signatures: make(map[uuid.UUID]*model.ContractSignature)}

	svc := NewContractService(contractRepo, templateRepo, signatureRepo).(*contractService)

	sig1 := &model.ContractSignature{
		ID:               uuid.New(),
		ContractID:       uuid.New(),
		UserID:           uuid.New(),
		IPAddress:        "192.168.1.1",
		SessionTokenHash: "session1",
		ContentHash:      "hash1",
		PrevHash:         nil,
	}
	sig1.RecordHash = svc.calculateRecordHash(sig1)

	sig2 := &model.ContractSignature{
		ID:               uuid.New(),
		ContractID:       uuid.New(),
		UserID:           uuid.New(),
		IPAddress:        "192.168.1.2",
		SessionTokenHash: "session2",
		ContentHash:      "hash2",
		PrevHash:         &sig1.RecordHash,
	}
	sig2.RecordHash = svc.calculateRecordHash(sig2)

	if sig2.PrevHash == nil || *sig2.PrevHash != sig1.RecordHash {
		t.Error("Hash chain broken: sig2.PrevHash should equal sig1.RecordHash")
	}

	if sig2.RecordHash == sig1.RecordHash {
		t.Error("Record hashes should be unique")
	}
}
