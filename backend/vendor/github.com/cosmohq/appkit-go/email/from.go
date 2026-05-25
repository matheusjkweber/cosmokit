package email

import (
	"fmt"
	"net/mail"
	"strings"
)

// ParseFromEmail parses an RFC-822 sender string and returns the sender
// Address with the bare email address and optional display name separated.
func ParseFromEmail(raw string) (Address, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return Address{}, fmt.Errorf("email: FROM_EMAIL is empty")
	}

	addr, err := mail.ParseAddress(raw)
	if err != nil {
		return Address{}, fmt.Errorf("email: invalid FROM_EMAIL %q: %w", raw, err)
	}

	return Address{
		Name:  addr.Name,
		Email: addr.Address,
	}, nil
}
