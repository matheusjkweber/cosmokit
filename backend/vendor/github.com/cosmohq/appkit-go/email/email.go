// Package email provides Brevo-backed transactional email sending.
package email

import (
	"context"
	"errors"
	"fmt"
	"net/mail"
	"strings"
)

// ErrEmailNotConfigured is returned when required sender configuration is
// missing or invalid.
var ErrEmailNotConfigured = errors.New("EMAIL_NOT_CONFIGURED")

// ErrInvalidMessage is returned when a message is missing required fields.
var ErrInvalidMessage = errors.New("INVALID_EMAIL_MESSAGE")

// Sender sends transactional email messages.
type Sender interface {
	Send(ctx context.Context, msg Message) error
}

// Address represents a named email address.
type Address struct {
	Name  string
	Email string
}

// Message is a transactional email to one or more recipients.
type Message struct {
	To      []Address
	From    Address
	ReplyTo *Address
	Subject string
	Text    string
	HTML    string
	Tags    []string
}

// Validate checks that the message has at least one valid recipient, a valid
// sender, a non-empty subject, and at least one body.
func (m Message) Validate() error {
	if len(m.To) == 0 {
		return fmt.Errorf("%w: at least one recipient required", ErrInvalidMessage)
	}
	for i, addr := range m.To {
		if _, err := mail.ParseAddress(addr.Email); err != nil {
			return fmt.Errorf("%w: invalid recipient address at index %d (%q): %v", ErrInvalidMessage, i, addr.Email, err)
		}
	}
	if _, err := mail.ParseAddress(m.From.Email); err != nil {
		return fmt.Errorf("%w: invalid sender address %q: %v", ErrInvalidMessage, m.From.Email, err)
	}
	if m.ReplyTo != nil {
		if _, err := mail.ParseAddress(m.ReplyTo.Email); err != nil {
			return fmt.Errorf("%w: invalid reply-to address %q: %v", ErrInvalidMessage, m.ReplyTo.Email, err)
		}
	}
	if strings.TrimSpace(m.Subject) == "" {
		return fmt.Errorf("%w: subject is required", ErrInvalidMessage)
	}
	if strings.TrimSpace(m.Text) == "" && strings.TrimSpace(m.HTML) == "" {
		return fmt.Errorf("%w: at least one of Text or HTML is required", ErrInvalidMessage)
	}
	return nil
}
