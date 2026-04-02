package handler

import (
	"crypto/sha256"
	"encoding/hex"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/middleware"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/institutoitinerante/contract-service/internal/service"
)

type ContractHandler struct {
	service  service.ContractService
	validate *validator.Validate
}

func NewContractHandler(service service.ContractService) *ContractHandler {
	return &ContractHandler{
		service:  service,
		validate: validator.New(),
	}
}

func (h *ContractHandler) CreateContract(c *fiber.Ctx) error {
	claims := c.Locals("user").(*middleware.Claims)
	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	var req model.CreateContractRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	// Sobrescreve o user_id do body com o do JWT para evitar IDOR (SEC-002)
	req.UserID = userID

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	response, err := h.service.CreateContract(c.Context(), &req)
	if err != nil {
		status := fiber.StatusInternalServerError
		if err.Error() == "no active template found for product type: "+req.ProductType {
			status = fiber.StatusNotFound
		}
		return c.Status(status).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(response)
}

func (h *ContractHandler) AcceptContract(c *fiber.Ctx) error {
	contractID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid contract id"})
	}

	claims := c.Locals("user").(*middleware.Claims)
	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	var req model.AcceptContractRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if req.IPAddress == "" {
		req.IPAddress = c.IP()
	}
	if req.UserAgent == "" {
		req.UserAgent = c.Get("User-Agent")
	}
	if req.SessionTokenHash == "" {
		// Gera hash do token JWT para registro de auditoria
		authHeader := c.Get("Authorization")
		if len(authHeader) > 7 {
			token := authHeader[7:] // Remove "Bearer "
			hash := sha256.Sum256([]byte(token))
			req.SessionTokenHash = hex.EncodeToString(hash[:])
		}
	}

	response, err := h.service.AcceptContract(c.Context(), contractID, userID, &req)
	if err != nil {
		status := fiber.StatusInternalServerError
		errMsg := err.Error()
		switch errMsg {
		case "contract not found":
			status = fiber.StatusNotFound
		case "unauthorized: contract belongs to different user":
			status = fiber.StatusForbidden
		case "contract already accepted":
			status = fiber.StatusConflict
		case "contract expired":
			status = fiber.StatusGone
		}
		return c.Status(status).JSON(fiber.Map{"error": errMsg})
	}

	return c.JSON(response)
}

func (h *ContractHandler) GetContract(c *fiber.Ctx) error {
	contractID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid contract id"})
	}

	claims := c.Locals("user").(*middleware.Claims)
	requesterID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	contract, err := h.service.GetContract(c.Context(), contractID)
	if err != nil {
		status := fiber.StatusInternalServerError
		if err.Error() == "contract not found" {
			status = fiber.StatusNotFound
		}
		return c.Status(status).JSON(fiber.Map{"error": err.Error()})
	}

	// Valida ownership para evitar IDOR (SEC-011)
	if contract.UserID != requesterID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": "acesso negado"})
	}

	return c.JSON(contract)
}

func (h *ContractHandler) ListUserContracts(c *fiber.Ctx) error {
	claims := c.Locals("user").(*middleware.Claims)
	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	limit := c.QueryInt("limit", 20)
	offset := c.QueryInt("offset", 0)

	contracts, total, err := h.service.ListUserContracts(c.Context(), userID, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"contracts": contracts,
		"total":     total,
		"limit":     limit,
		"offset":    offset,
	})
}
