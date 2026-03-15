package handler

import (
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
	var req model.CreateContractRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

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

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	response, err := h.service.AcceptContract(c.Context(), contractID, userID, &req)
	if err != nil {
		status := fiber.StatusInternalServerError
		errMsg := err.Error()
		if errMsg == "contract not found" {
			status = fiber.StatusNotFound
		} else if errMsg == "unauthorized: contract belongs to different user" {
			status = fiber.StatusForbidden
		} else if errMsg == "contract already accepted" {
			status = fiber.StatusConflict
		} else if errMsg == "contract expired" {
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

	contract, err := h.service.GetContract(c.Context(), contractID)
	if err != nil {
		status := fiber.StatusInternalServerError
		if err.Error() == "contract not found" {
			status = fiber.StatusNotFound
		}
		return c.Status(status).JSON(fiber.Map{"error": err.Error()})
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
