package handlers

import (
	"net/http"

	"github.com/matheusjkweber/cosmokit/backend/internal/content"
)

// Content is the read-only accessor for embedded What's New / Notifications /
// Helper metadata served to the macOS app.
type Content interface {
	LatestWhatsNew(appVersion string) *content.WhatsNewEntry
	Notifications() []content.NotificationEntry
	Helper() content.HelperInfo
	FeatureFlags() content.FeatureFlags
	ResolveProxyEnabled(deviceID string) bool
}

type whatsNewResponse struct {
	Version     string                 `json:"version"`
	Title       string                 `json:"title"`
	Items       []whatsNewItemResponse `json:"items"`
	PublishedAt string                 `json:"publishedAt"`
}

type whatsNewItemResponse struct {
	Icon        string `json:"icon"`
	IconColor   string `json:"iconColor"`
	Title       string `json:"title"`
	Description string `json:"description"`
}

type notificationResponse struct {
	ID               string  `json:"id"`
	Severity         string  `json:"severity"`
	Category         string  `json:"category"`
	PublishedAt      string  `json:"publishedAt"`
	ExpiresAt        *string `json:"expiresAt"`
	MinHelperVersion *string `json:"minHelperVersion,omitempty"`
	MinAppVersion    *string `json:"minAppVersion,omitempty"`
	MaxAppVersion    *string `json:"maxAppVersion,omitempty"`
	Title            string  `json:"title"`
	Body             string  `json:"body"`
	ActionLabel      string  `json:"actionLabel"`
	ActionURL        string  `json:"actionUrl,omitempty"`
}

type helperResponse struct {
	LatestVersion      string  `json:"latestVersion"`
	DownloadURL        string  `json:"downloadUrl"`
	BlockProxy         bool    `json:"blockProxy"`
	MinRequiredVersion *string `json:"minRequiredVersion"`
	ReleaseNotes       string  `json:"releaseNotes"`
}

// WhatsNew returns the resolved entry for the caller's locale + app version.
// Query params: ?version=X.Y.Z&locale=pt-BR (both optional).
func (h *Handlers) WhatsNew(w http.ResponseWriter, r *http.Request) {
	if h.Content == nil {
		writeError(w, http.StatusServiceUnavailable, "content not configured")
		return
	}
	locale := r.URL.Query().Get("locale")
	entry := h.Content.LatestWhatsNew(r.URL.Query().Get("version"))
	if entry == nil {
		writeJSON(w, http.StatusOK, struct{}{})
		return
	}

	resp := whatsNewResponse{
		Version:     entry.Version,
		Title:       entry.Title.Pick(locale),
		PublishedAt: entry.PublishedAt,
		Items:       make([]whatsNewItemResponse, 0, len(entry.Items)),
	}
	for _, it := range entry.Items {
		loc := it.Localizations[locale]
		if loc.Title == "" && loc.Description == "" {
			loc = pickItemLocale(it.Localizations, locale)
		}
		resp.Items = append(resp.Items, whatsNewItemResponse{
			Icon:        it.Icon,
			IconColor:   it.IconColor,
			Title:       loc.Title,
			Description: loc.Description,
		})
	}
	writeJSON(w, http.StatusOK, resp)
}

// Notifications returns all active notifications resolved for the caller's locale.
// Query params: ?locale=pt-BR (optional).
func (h *Handlers) Notifications(w http.ResponseWriter, r *http.Request) {
	if h.Content == nil {
		writeJSON(w, http.StatusOK, []notificationResponse{})
		return
	}
	locale := r.URL.Query().Get("locale")
	all := h.Content.Notifications()
	resp := make([]notificationResponse, 0, len(all))
	for _, n := range all {
		loc := pickNotificationLocale(n.Localizations, locale)
		resp = append(resp, notificationResponse{
			ID:               n.ID,
			Severity:         n.Severity,
			Category:         n.Category,
			PublishedAt:      n.PublishedAt,
			ExpiresAt:        n.ExpiresAt,
			MinHelperVersion: n.MinHelperVersion,
			MinAppVersion:    n.MinAppVersion,
			MaxAppVersion:    n.MaxAppVersion,
			Title:            loc.Title,
			Body:             loc.Body,
			ActionLabel:      loc.ActionLabel,
			ActionURL:        n.ActionURL,
		})
	}
	writeJSON(w, http.StatusOK, resp)
}

// HelperLatest reports the currently-published proxy helper version.
// Query params: ?locale=pt-BR (optional, for release notes).
func (h *Handlers) HelperLatest(w http.ResponseWriter, r *http.Request) {
	if h.Content == nil {
		writeError(w, http.StatusServiceUnavailable, "content not configured")
		return
	}
	info := h.Content.Helper()
	writeJSON(w, http.StatusOK, helperResponse{
		LatestVersion:      info.LatestVersion,
		DownloadURL:        info.DownloadURL,
		BlockProxy:         info.BlockProxy,
		MinRequiredVersion: info.MinRequiredVersion,
		ReleaseNotes:       info.ReleaseNotes.Pick(r.URL.Query().Get("locale")),
	})
}

type featureFlagsResponse struct {
	Proxy proxyFlagResponse `json:"proxy"`
}

type proxyFlagResponse struct {
	Enabled          bool                `json:"enabled"`
	DisabledMessage  string              `json:"disabledMessage"`
	HTTPSMitmEnabled bool                `json:"httpsMitmEnabled"`
	HTTPSMitmBackend string              `json:"httpsMitmBackend"`
	Notice           proxyNoticeResponse `json:"notice"`
}

type proxyNoticeResponse struct {
	ID            string  `json:"id"`
	Show          bool    `json:"show"`
	Severity      string  `json:"severity"`
	Message       string  `json:"message"`
	MinAppVersion *string `json:"minAppVersion,omitempty"`
	MaxAppVersion *string `json:"maxAppVersion,omitempty"`
}

// FeatureFlags returns the per-device resolved feature flags. The deviceId
// query param decides whether the proxy override applies for this caller.
// Query params: ?deviceId=<uuid>&locale=pt-BR (both optional but recommended).
func (h *Handlers) FeatureFlags(w http.ResponseWriter, r *http.Request) {
	if h.Content == nil {
		writeError(w, http.StatusServiceUnavailable, "content not configured")
		return
	}
	deviceID := r.URL.Query().Get("deviceId")
	locale := r.URL.Query().Get("locale")
	flags := h.Content.FeatureFlags()
	enabled := h.Content.ResolveProxyEnabled(deviceID)
	httpsMitmBackend := flags.Proxy.HTTPSMitmBackend
	if httpsMitmBackend == "" {
		httpsMitmBackend = "off"
	}

	writeJSON(w, http.StatusOK, featureFlagsResponse{
		Proxy: proxyFlagResponse{
			Enabled:          enabled,
			DisabledMessage:  flags.Proxy.DisabledMessage.Pick(locale),
			HTTPSMitmEnabled: flags.Proxy.HTTPSMitmEnabled,
			HTTPSMitmBackend: httpsMitmBackend,
			Notice: proxyNoticeResponse{
				ID:            flags.Proxy.Notice.ID,
				Show:          flags.Proxy.Notice.Show,
				Severity:      flags.Proxy.Notice.Severity,
				Message:       flags.Proxy.Notice.Message.Pick(locale),
				MinAppVersion: flags.Proxy.Notice.MinAppVersion,
				MaxAppVersion: flags.Proxy.Notice.MaxAppVersion,
			},
		},
	})
}

func pickItemLocale(m map[string]content.WhatsNewItemContent, locale string) content.WhatsNewItemContent {
	if v, ok := m[locale]; ok && (v.Title != "" || v.Description != "") {
		return v
	}
	for i, c := range locale {
		if c == '-' || c == '_' {
			if v, ok := m[locale[:i]]; ok {
				return v
			}
			break
		}
	}
	if v, ok := m["en"]; ok {
		return v
	}
	for _, v := range m {
		return v
	}
	return content.WhatsNewItemContent{}
}

func pickNotificationLocale(m map[string]content.NotificationLocalized, locale string) content.NotificationLocalized {
	if v, ok := m[locale]; ok && (v.Title != "" || v.Body != "") {
		return v
	}
	for i, c := range locale {
		if c == '-' || c == '_' {
			if v, ok := m[locale[:i]]; ok {
				return v
			}
			break
		}
	}
	if v, ok := m["en"]; ok {
		return v
	}
	for _, v := range m {
		return v
	}
	return content.NotificationLocalized{}
}
