package config

import (
	"errors"
	"os"
	"strings"
)

type Config struct {
	Port           string
	Env            string
	ContactEmail   string
	ContactName    string
	AllowedOrigins []string
}

func Load() (Config, error) {
	cfg := Config{
		Port:         envOr("PORT", "8091"),
		Env:          envOr("APP_ENV", "development"),
		ContactEmail: envOr("CONTACT_EMAIL", "contato@usecosmoskittool.com"),
		ContactName:  envOr("CONTACT_NAME", "CosmoKit Support"),
	}

	origins := envOr("ALLOWED_ORIGINS", "http://localhost:3000,https://usecosmoskittool.com,https://www.usecosmoskittool.com")
	for _, o := range strings.Split(origins, ",") {
		if v := strings.TrimSpace(o); v != "" {
			cfg.AllowedOrigins = append(cfg.AllowedOrigins, v)
		}
	}
	if len(cfg.AllowedOrigins) == 0 {
		return cfg, errors.New("ALLOWED_ORIGINS must list at least one origin")
	}

	return cfg, nil
}

func envOr(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
