package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/middleware"
	"github.com/institutoitinerante/contract-service/internal/model"
)

// fixedUserID é o UUID fixo usado nos testes para simular o dono do contrato
var fixedUserID = uuid.MustParse("00000000-0000-0000-0000-000000000001")

type mockContractService struct{}

func (m *mockContractService) CreateContract(ctx context.Context, req *model.CreateContractRequest) (*model.CreateContractResponse, error) {
	return &model.CreateContractResponse{
		ContractID:  uuid.New(),
		ContentHTML: "<h1>Test Contract</h1>",
		ExpiresAt:   time.Now().Add(60 * time.Minute),
	}, nil
}

func (m *mockContractService) AcceptContract(ctx context.Context, contractID uuid.UUID, userID uuid.UUID, req *model.AcceptContractRequest) (*model.AcceptContractResponse, error) {
	return &model.AcceptContractResponse{
		SignatureID: uuid.New(),
		AcceptedAt:  time.Now(),
		PDFUrl:      nil,
	}, nil
}

func (m *mockContractService) GetContract(ctx context.Context, id uuid.UUID) (*model.Contract, error) {
	return &model.Contract{
		ID:          id,
		UserID:      fixedUserID,
		ProductType: "brio",
		Status:      model.ContractStatusPending,
	}, nil
}

func (m *mockContractService) ListUserContracts(ctx context.Context, userID uuid.UUID, limit, offset int) ([]model.Contract, int, error) {
	return []model.Contract{}, 0, nil
}

func TestCreateContractHandler(t *testing.T) {
	app := fiber.New()
	handler := NewContractHandler(&mockContractService{})

	// Rota com middleware simulado que injeta o claim JWT (SEC-002)
	app.Post("/contracts", func(c *fiber.Ctx) error {
		c.Locals("user", &middleware.Claims{UserID: fixedUserID.String()})
		return handler.CreateContract(c)
	})

	reqBody := map[string]any{
		"product_type": "brio",
		"variables":    map[string]any{"user_name": "Test User"},
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/contracts", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}

	if resp.StatusCode != fiber.StatusCreated {
		t.Errorf("Expected status 201, got %d", resp.StatusCode)
	}
}

func TestAcceptContractHandler(t *testing.T) {
	app := fiber.New()
	handler := NewContractHandler(&mockContractService{})

	contractID := uuid.New()

	app.Post("/contracts/:id/accept", func(c *fiber.Ctx) error {
		c.Locals("user", &middleware.Claims{UserID: uuid.New().String()})
		return handler.AcceptContract(c)
	})

	reqBody := map[string]string{
		"ip_address":         "192.168.1.1",
		"user_agent":         "Mozilla/5.0",
		"session_token_hash": "session123",
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/contracts/"+contractID.String()+"/accept", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("Request failed: %v", err)
	}

	if resp.StatusCode != fiber.StatusOK {
		t.Errorf("Expected status 200, got %d", resp.StatusCode)
	}
}
