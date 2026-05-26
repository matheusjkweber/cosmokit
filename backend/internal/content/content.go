package content

import (
	_ "embed"
	"encoding/json"
	"fmt"
)

//go:embed data.json
var rawData []byte

// Localized holds a string per locale code. Use Pick to resolve.
type Localized map[string]string

// Pick returns the string for the requested locale, falling back to the
// language root (pt-BR -> pt), then English, then any value, then "".
func (l Localized) Pick(locale string) string {
	if v, ok := l[locale]; ok && v != "" {
		return v
	}
	for i, c := range locale {
		if c == '-' || c == '_' {
			if v, ok := l[locale[:i]]; ok && v != "" {
				return v
			}
			break
		}
	}
	if v, ok := l["en"]; ok && v != "" {
		return v
	}
	for _, v := range l {
		if v != "" {
			return v
		}
	}
	return ""
}

type WhatsNewItem struct {
	Icon          string                          `json:"icon"`
	IconColor     string                          `json:"iconColor"`
	Localizations map[string]WhatsNewItemContent  `json:"localizations"`
}

type WhatsNewItemContent struct {
	Title       string `json:"title"`
	Description string `json:"description"`
}

type WhatsNewEntry struct {
	Version     string         `json:"version"`
	Title       Localized      `json:"title"`
	Items       []WhatsNewItem `json:"items"`
	PublishedAt string         `json:"publishedAt"`
}

type NotificationEntry struct {
	ID               string                            `json:"id"`
	Severity         string                            `json:"severity"`
	Category         string                            `json:"category"`
	PublishedAt      string                            `json:"publishedAt"`
	ExpiresAt        *string                           `json:"expiresAt"`
	MinHelperVersion *string                           `json:"minHelperVersion,omitempty"`
	MinAppVersion    *string                           `json:"minAppVersion,omitempty"`
	Localizations    map[string]NotificationLocalized  `json:"localizations"`
	ActionURL        string                            `json:"actionUrl,omitempty"`
}

type NotificationLocalized struct {
	Title       string `json:"title"`
	Body        string `json:"body"`
	ActionLabel string `json:"actionLabel"`
}

type HelperInfo struct {
	LatestVersion      string    `json:"latestVersion"`
	DownloadURL        string    `json:"downloadUrl"`
	BlockProxy         bool      `json:"blockProxy"`
	MinRequiredVersion *string   `json:"minRequiredVersion"`
	ReleaseNotes       Localized `json:"releaseNotes"`
}

type ProxyFeatureFlag struct {
	Enabled           bool      `json:"enabled"`
	EnabledForDevices []string  `json:"enabledForDevices"`
	DisabledMessage   Localized `json:"disabledMessage"`
}

type FeatureFlags struct {
	Proxy ProxyFeatureFlag `json:"proxy"`
}

type data struct {
	WhatsNew      []WhatsNewEntry     `json:"whatsNew"`
	Notifications []NotificationEntry `json:"notifications"`
	FeatureFlags  FeatureFlags        `json:"featureFlags"`
	Helper        HelperInfo          `json:"helper"`
}

// Store is the in-memory accessor for embedded content.
type Store struct {
	d data
}

// Load parses the embedded JSON. Returns an error if the data is malformed.
func Load() (*Store, error) {
	var d data
	if err := json.Unmarshal(rawData, &d); err != nil {
		return nil, fmt.Errorf("content: parse data.json: %w", err)
	}
	return &Store{d: d}, nil
}

// LatestWhatsNew returns the entry for the requested app version, or the
// newest entry if no exact match exists. Returns nil when there's nothing.
func (s *Store) LatestWhatsNew(appVersion string) *WhatsNewEntry {
	if len(s.d.WhatsNew) == 0 {
		return nil
	}
	if appVersion != "" {
		for i := range s.d.WhatsNew {
			if s.d.WhatsNew[i].Version == appVersion {
				return &s.d.WhatsNew[i]
			}
		}
	}
	return &s.d.WhatsNew[len(s.d.WhatsNew)-1]
}

// Notifications returns every active notification (no expiry filtering yet).
func (s *Store) Notifications() []NotificationEntry {
	return s.d.Notifications
}

// Helper returns the current helper release info.
func (s *Store) Helper() HelperInfo {
	return s.d.Helper
}

// FeatureFlags returns the raw flags including per-device overrides.
func (s *Store) FeatureFlags() FeatureFlags {
	return s.d.FeatureFlags
}

// ResolveProxyEnabled computes whether the proxy feature should be available
// for the given device id. Returns the global default unless the device id
// appears in the per-device allowlist.
func (s *Store) ResolveProxyEnabled(deviceID string) bool {
	flag := s.d.FeatureFlags.Proxy
	if flag.Enabled {
		return true
	}
	if deviceID == "" {
		return false
	}
	for _, allowed := range flag.EnabledForDevices {
		if allowed == deviceID {
			return true
		}
	}
	return false
}
