package main

import (
	"context"
	"errors"
	"log/slog"
	stdhttp "net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	appkitemail "github.com/cosmohq/appkit-go/email"

	"github.com/matheusjkweber/cosmokit/backend/internal/config"
	"github.com/matheusjkweber/cosmokit/backend/internal/content"
	"github.com/matheusjkweber/cosmokit/backend/internal/handlers"
)

const Version = "0.1.0"

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	slog.SetDefault(logger)

	cfg, err := config.Load()
	if err != nil {
		slog.Error("config load failed", "err", err)
		os.Exit(1)
	}

	sender, err := appkitemail.NewFromEnv()
	if err != nil {
		slog.Error("email sender init failed", "err", err)
		os.Exit(1)
	}

	store, err := content.Load()
	if err != nil {
		slog.Error("content load failed", "err", err)
		os.Exit(1)
	}

	h := &handlers.Handlers{
		Sender:       sender,
		ContactEmail: cfg.ContactEmail,
		ContactName:  cfg.ContactName,
		AppName:      "CosmoKit",
		Content:      store,
	}

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(15 * time.Second))
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   cfg.AllowedOrigins,
		AllowedMethods:   []string{"GET", "POST", "OPTIONS"},
		AllowedHeaders:   []string{"Content-Type", "Accept"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	r.Get("/healthz", h.Health)
	r.Route("/v1", func(r chi.Router) {
		r.Post("/contact", h.Contact)
		r.Post("/suggest", h.Suggest)
		r.Get("/whats-new", h.WhatsNew)
		r.Get("/notifications", h.Notifications)
		r.Get("/helper/latest", h.HelperLatest)
	})

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	srv := &stdhttp.Server{
		Addr:              ":" + cfg.Port,
		Handler:           r,
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		slog.Info("cosmokit-api up",
			"port", cfg.Port,
			"env", cfg.Env,
			"contact", appkitemail.MaskEmail(cfg.ContactEmail),
			"version", Version,
		)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, stdhttp.ErrServerClosed) {
			slog.Error("server crashed", "err", err)
			cancel()
		}
	}()

	<-ctx.Done()
	slog.Info("shutting down")
	shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer shutdownCancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("graceful shutdown failed", "err", err)
	}
}
