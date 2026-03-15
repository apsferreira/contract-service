package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/fiber/v2/middleware/requestid"
	"github.com/institutoitinerante/contract-service/internal/config"
	"github.com/institutoitinerante/contract-service/internal/database"
	"github.com/institutoitinerante/contract-service/internal/handler"
	"github.com/institutoitinerante/contract-service/internal/middleware"
	"github.com/institutoitinerante/contract-service/internal/repository"
	"github.com/institutoitinerante/contract-service/internal/service"
	"github.com/institutoitinerante/contract-service/internal/telemetry"
)

func main() {
	shutdownTelemetry := telemetry.Init("contract-service")
	defer shutdownTelemetry()

	cfg := config.Load()

	if cfg.DatabaseURL == "" {
		log.Fatal("DATABASE_URL environment variable is required")
	}
	if cfg.JWTSecret == "" {
		log.Println("⚠️  JWT_SECRET not set — authentication will be insecure")
	}

	dbPool, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer dbPool.Close()
	log.Println("✅ PostgreSQL connected")

	templateRepo := repository.NewTemplateRepository(dbPool)
	contractRepo := repository.NewContractRepository(dbPool)
	signatureRepo := repository.NewSignatureRepository(dbPool)

	templateSvc := service.NewTemplateService(templateRepo)
	contractSvc := service.NewContractService(contractRepo, templateRepo, signatureRepo)

	templateHandler := handler.NewTemplateHandler(templateSvc)
	contractHandler := handler.NewContractHandler(contractSvc)

	app := fiber.New(fiber.Config{
		AppName:      "contract-service",
		ErrorHandler: customErrorHandler,
	})

	app.Use(requestid.New())
	app.Use(logger.New())
	app.Use(recover.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PUT,DELETE,OPTIONS",
		AllowHeaders: "Accept,Authorization,Content-Type,X-CSRF-Token",
	}))

	telemetry.RegisterMetrics(app)

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "service": "contract-service"})
	})

	api := app.Group("/api/v1")

	templates := api.Group("/templates")
	templates.Post("/", templateHandler.CreateTemplate)
	templates.Get("/", templateHandler.ListTemplates)
	templates.Get("/:id", templateHandler.GetTemplate)
	templates.Put("/:id", templateHandler.UpdateTemplate)
	templates.Post("/:id/activate", templateHandler.ActivateTemplate)

	contracts := api.Group("/contracts")
	contracts.Post("/", contractHandler.CreateContract)
	contracts.Get("/:id", contractHandler.GetContract)
	
	contractsAuth := contracts.Use(middleware.JWTMiddleware(cfg.JWTSecret))
	contractsAuth.Post("/:id/accept", contractHandler.AcceptContract)
	contractsAuth.Get("/", contractHandler.ListUserContracts)

	go func() {
		addr := ":" + cfg.Port
		log.Printf("🚀 Contract Service starting on %s", addr)
		if err := app.Listen(addr); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
	if err := app.Shutdown(); err != nil {
		log.Printf("Server shutdown error: %v", err)
	} else {
		log.Println("Server shut down gracefully")
	}
}

func customErrorHandler(c *fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
	}
	return c.Status(code).JSON(fiber.Map{"error": err.Error()})
}
