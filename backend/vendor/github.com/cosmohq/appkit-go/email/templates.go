package email

import (
	"bytes"
	"embed"
	"errors"
	"fmt"
	htmltmpl "html/template"
	texttmpl "text/template"
)

// ErrUnknownTemplate is returned when Render receives an unknown template name.
var ErrUnknownTemplate = errors.New("UNKNOWN_EMAIL_TEMPLATE")

//go:embed templates/*.txt templates/*.html
var templateFS embed.FS

// TemplateVars holds the variables available to all email templates.
type TemplateVars struct {
	AppName       string
	ActionURL     string
	RecipientName string
	ExtraFields   map[string]string
}

// Render renders a named template set into plain text and HTML bodies.
func Render(name string, vars TemplateVars) (textBody string, htmlBody string, err error) {
	switch name {
	case "verification", "password_reset":
	default:
		return "", "", fmt.Errorf("%w: %s", ErrUnknownTemplate, name)
	}

	textTmpl, err := texttmpl.ParseFS(templateFS, "templates/"+name+".txt")
	if err != nil {
		return "", "", fmt.Errorf("email: parse text template %q: %w", name, err)
	}

	htmlTmpl, err := htmltmpl.ParseFS(templateFS, "templates/"+name+".html")
	if err != nil {
		return "", "", fmt.Errorf("email: parse html template %q: %w", name, err)
	}

	var textBuf bytes.Buffer
	if err := textTmpl.Execute(&textBuf, vars); err != nil {
		return "", "", fmt.Errorf("email: execute text template %q: %w", name, err)
	}

	var htmlBuf bytes.Buffer
	if err := htmlTmpl.Execute(&htmlBuf, vars); err != nil {
		return "", "", fmt.Errorf("email: execute html template %q: %w", name, err)
	}

	return textBuf.String(), htmlBuf.String(), nil
}
