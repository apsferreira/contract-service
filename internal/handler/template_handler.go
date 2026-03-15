package handler

import (
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/institutoitinerante/contract-service/internal/model"
	"github.com/institutoitinerante/contract-service/internal/service"
)

type TemplateHandler struct {
	service  service.TemplateService
	validate *validator.Validate
}

func NewTemplateHandler(service service.TemplateService) *TemplateHandler {
	return &TemplateHandler{
		service:  service,
		validate: validator.New(),
	}
}

func (h *TemplateHandler) CreateTemplate(c *fiber.Ctx) error {
	var req model.CreateTemplateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	if err := h.validate.Struct(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	template, err := h.service.CreateTemplate(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(template)
}

func (h *TemplateHandler) GetTemplate(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid template id"})
	}

	template, err := h.service.GetTemplate(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(template)
}

func (h *TemplateHandler) ListTemplates(c *fiber.Ctx) error {
	productType := c.Query("product_type")
	limit := c.QueryInt("limit", 20)
	offset := c.QueryInt("offset", 0)

	var productTypePtr *string
	if productType != "" {
		productTypePtr = &productType
	}

	templates, total, err := h.service.ListTemplates(c.Context(), productTypePtr, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"templates": templates,
		"total":     total,
		"limit":     limit,
		"offset":    offset,
	})
}

func (h *TemplateHandler) UpdateTemplate(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid template id"})
	}

	var req model.UpdateTemplateRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	template, err := h.service.UpdateTemplate(c.Context(), id, &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(template)
}

func (h *TemplateHandler) ActivateTemplate(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid template id"})
	}

	if err := h.service.ActivateTemplate(c.Context(), id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{"message": "template activated"})
}
