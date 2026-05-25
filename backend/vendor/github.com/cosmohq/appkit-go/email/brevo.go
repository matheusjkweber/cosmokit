package email

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"
)

const brevoEndpoint = "https://api.brevo.com/v3/smtp/email"

type brevoPayload struct {
	Sender      brevoSenderInfo  `json:"sender"`
	To          []brevoRecipient `json:"to"`
	Subject     string           `json:"subject"`
	TextContent string           `json:"textContent,omitempty"`
	HTMLContent string           `json:"htmlContent,omitempty"`
	Tags        []string         `json:"tags,omitempty"`
	ReplyTo     *brevoSenderInfo `json:"replyTo,omitempty"`
}

type brevoSenderInfo struct {
	Name  string `json:"name,omitempty"`
	Email string `json:"email"`
}

type brevoRecipient struct {
	Email string `json:"email"`
	Name  string `json:"name,omitempty"`
}

type brevoSender struct {
	cfg  Config
	from Address
}

func newBrevoSender(cfg Config, from Address) Sender {
	return &brevoSender{cfg: cfg, from: from}
}

func (s *brevoSender) FromAddress() Address {
	return s.from
}

// Send sends a transactional email via Brevo. It calls msg.Validate() first
// and returns the validation error without making any HTTP request if the
// message is invalid.
func (s *brevoSender) Send(ctx context.Context, msg Message) error {
	if err := msg.Validate(); err != nil {
		return fmt.Errorf("email: invalid message: %w", err)
	}

	payload := s.buildPayload(msg)
	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("email: marshal payload: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, brevoEndpoint, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("email: create request: %w", err)
	}
	req.Header.Set("api-key", s.cfg.BrevoAPIKey)
	req.Header.Set("content-type", "application/json")
	req.Header.Set("accept", "application/json")

	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("email: brevo request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		slog.Info("email: sent via Brevo",
			"status", resp.StatusCode,
			"recipients", len(msg.To),
			"tags", msg.Tags,
		)
		return nil
	}

	respBody, _ := io.ReadAll(io.LimitReader(resp.Body, 512))
	slog.Warn("email: brevo returned non-2xx",
		"status", resp.StatusCode,
		"body", string(respBody),
	)
	return fmt.Errorf("email: brevo returned status %d: %s", resp.StatusCode, string(respBody))
}

func (s *brevoSender) buildPayload(msg Message) brevoPayload {
	p := brevoPayload{
		Sender: brevoSenderInfo{
			Name:  msg.From.Name,
			Email: msg.From.Email,
		},
		Subject:     msg.Subject,
		TextContent: msg.Text,
		HTMLContent: msg.HTML,
		Tags:        msg.Tags,
	}

	p.To = make([]brevoRecipient, len(msg.To))
	for i, addr := range msg.To {
		p.To[i] = brevoRecipient{
			Email: addr.Email,
			Name:  addr.Name,
		}
	}

	if msg.ReplyTo != nil {
		p.ReplyTo = &brevoSenderInfo{
			Name:  msg.ReplyTo.Name,
			Email: msg.ReplyTo.Email,
		}
	}

	return p
}

type devSender struct {
	cfg  Config
	from Address
}

func (s *devSender) FromAddress() Address {
	return s.from
}

func (s *devSender) Send(ctx context.Context, msg Message) error {
	if err := msg.Validate(); err != nil {
		return fmt.Errorf("email: invalid message: %w", err)
	}

	for _, addr := range msg.To {
		slog.Info("email: dev sink would send email",
			"to", MaskEmail(addr.Email),
			"from", MaskEmail(msg.From.Email),
			"subject", msg.Subject,
			"tags", msg.Tags,
		)
	}
	return nil
}
