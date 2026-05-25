package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"net/mail"
	"strings"

	appkitemail "github.com/cosmohq/appkit-go/email"
)

const (
	maxNameLen    = 120
	maxSubjectLen = 200
	maxBodyLen    = 8000
)

type Handlers struct {
	Sender       appkitemail.Sender
	ContactEmail string
	ContactName  string
	AppName      string
	Content      Content
}

type contactRequest struct {
	Name    string `json:"name"`
	Email   string `json:"email"`
	Subject string `json:"subject"`
	Message string `json:"message"`
}

type suggestRequest struct {
	Name    string `json:"name"`
	Email   string `json:"email"`
	Title   string `json:"title"`
	Idea    string `json:"idea"`
	Locale  string `json:"locale"`
}

type errorResponse struct {
	Error string `json:"error"`
}

type okResponse struct {
	OK bool `json:"ok"`
}

func (h *Handlers) Contact(w http.ResponseWriter, r *http.Request) {
	var req contactRequest
	if !decode(w, r, &req) {
		return
	}

	name := strings.TrimSpace(req.Name)
	email := strings.TrimSpace(req.Email)
	subject := strings.TrimSpace(req.Subject)
	message := strings.TrimSpace(req.Message)

	if err := validateContact(name, email, subject, message); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	mailSubject := "[CosmoKit Support] " + subject
	text := "From: " + name + " <" + email + ">\nSubject: " + subject + "\n\n" + message

	if err := h.send(r.Context(), email, name, mailSubject, text, []string{"cosmokit", "support"}); err != nil {
		respondSendError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, okResponse{OK: true})
}

func (h *Handlers) Suggest(w http.ResponseWriter, r *http.Request) {
	var req suggestRequest
	if !decode(w, r, &req) {
		return
	}

	name := strings.TrimSpace(req.Name)
	email := strings.TrimSpace(req.Email)
	title := strings.TrimSpace(req.Title)
	idea := strings.TrimSpace(req.Idea)
	locale := strings.TrimSpace(req.Locale)

	if err := validateSuggest(name, email, title, idea); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	mailSubject := "[CosmoKit Feature] " + title
	var b strings.Builder
	b.WriteString("From: ")
	b.WriteString(name)
	b.WriteString(" <")
	b.WriteString(email)
	b.WriteString(">\n")
	if locale != "" {
		b.WriteString("Locale: ")
		b.WriteString(locale)
		b.WriteString("\n")
	}
	b.WriteString("Title: ")
	b.WriteString(title)
	b.WriteString("\n\n")
	b.WriteString(idea)

	if err := h.send(r.Context(), email, name, mailSubject, b.String(), []string{"cosmokit", "feature-request"}); err != nil {
		respondSendError(w, err)
		return
	}

	writeJSON(w, http.StatusOK, okResponse{OK: true})
}

func (h *Handlers) Health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, okResponse{OK: true})
}

func (h *Handlers) send(ctx context.Context, replyToEmail, replyToName, subject, text string, tags []string) error {
	msg := appkitemail.Message{
		To: []appkitemail.Address{{
			Name:  h.ContactName,
			Email: h.ContactEmail,
		}},
		From: appkitemail.Address{
			Name:  h.AppName,
			Email: h.ContactEmail,
		},
		ReplyTo: &appkitemail.Address{
			Name:  replyToName,
			Email: replyToEmail,
		},
		Subject: subject,
		Text:    text,
		Tags:    tags,
	}
	if err := h.Sender.Send(ctx, msg); err != nil {
		slog.Error("send failed", "err", err, "subject", subject)
		return err
	}
	slog.Info("sent", "to", appkitemail.MaskEmail(h.ContactEmail), "subject", subject)
	return nil
}

func validateContact(name, email, subject, message string) error {
	if name == "" || len(name) > maxNameLen {
		return errors.New("name is required (max " + itoa(maxNameLen) + " chars)")
	}
	if _, err := mail.ParseAddress(email); err != nil {
		return errors.New("valid email is required")
	}
	if subject == "" || len(subject) > maxSubjectLen {
		return errors.New("subject is required (max " + itoa(maxSubjectLen) + " chars)")
	}
	if message == "" || len(message) > maxBodyLen {
		return errors.New("message is required (max " + itoa(maxBodyLen) + " chars)")
	}
	return nil
}

func validateSuggest(name, email, title, idea string) error {
	if name == "" || len(name) > maxNameLen {
		return errors.New("name is required (max " + itoa(maxNameLen) + " chars)")
	}
	if _, err := mail.ParseAddress(email); err != nil {
		return errors.New("valid email is required")
	}
	if title == "" || len(title) > maxSubjectLen {
		return errors.New("title is required (max " + itoa(maxSubjectLen) + " chars)")
	}
	if idea == "" || len(idea) > maxBodyLen {
		return errors.New("idea is required (max " + itoa(maxBodyLen) + " chars)")
	}
	return nil
}

func decode(w http.ResponseWriter, r *http.Request, dst any) bool {
	dec := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<16))
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		writeError(w, http.StatusBadRequest, "invalid JSON body")
		return false
	}
	return true
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, errorResponse{Error: msg})
}

func respondSendError(w http.ResponseWriter, err error) {
	if errors.Is(err, appkitemail.ErrEmailNotConfigured) {
		writeError(w, http.StatusServiceUnavailable, "email service not configured")
		return
	}
	if errors.Is(err, appkitemail.ErrInvalidMessage) {
		writeError(w, http.StatusBadRequest, "invalid message")
		return
	}
	writeError(w, http.StatusBadGateway, "delivery failed")
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	neg := n < 0
	if neg {
		n = -n
	}
	var buf [20]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	if neg {
		i--
		buf[i] = '-'
	}
	return string(buf[i:])
}
