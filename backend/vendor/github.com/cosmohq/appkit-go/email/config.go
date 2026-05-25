package email

import (
	"log/slog"
	"os"
	"strings"
)

// Config holds transactional email sender configuration.
type Config struct {
	BrevoAPIKey string
	FromEmail   string
	AppName     string
	DevSink     string
}

// NewFromEnv reads BREVO_API_KEY, FROM_EMAIL, APP_NAME, and DEV_EMAIL_SINK
// from the process environment and returns a configured Sender.
func NewFromEnv() (Sender, error) {
	return New(Config{
		BrevoAPIKey: os.Getenv("BREVO_API_KEY"),
		FromEmail:   os.Getenv("FROM_EMAIL"),
		AppName:     os.Getenv("APP_NAME"),
		DevSink:     os.Getenv("DEV_EMAIL_SINK"),
	})
}

// New returns a configured transactional Sender.
func New(cfg Config) (Sender, error) {
	fromAddr, err := ParseFromEmail(cfg.FromEmail)
	if err != nil {
		slog.Warn("email: invalid FROM_EMAIL", "from", MaskEmail(cfg.FromEmail))
		return nil, ErrEmailNotConfigured
	}

	cfg.FromEmail = fromAddr.Email

	if strings.TrimSpace(cfg.DevSink) != "" {
		slog.Info("email: DEV_EMAIL_SINK is set, emails will be logged instead of sent")
		return &devSender{cfg: cfg, from: fromAddr}, nil
	}

	if strings.TrimSpace(cfg.BrevoAPIKey) == "" {
		slog.Warn("email: BREVO_API_KEY not set, returning ErrEmailNotConfigured")
		return nil, ErrEmailNotConfigured
	}

	return newBrevoSender(cfg, fromAddr), nil
}
