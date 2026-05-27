package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/matheusjkweber/cosmokit/backend/internal/content"
)

type fakeContent struct {
	entry            *content.WhatsNewEntry
	notes            []content.NotificationEntry
	helper           content.HelperInfo
	flags            content.FeatureFlags
	proxyEnabledFor  map[string]bool
	gotVersion       string
	gotProxyDeviceID string
}

func (f *fakeContent) LatestWhatsNew(v string) *content.WhatsNewEntry {
	f.gotVersion = v
	return f.entry
}
func (f *fakeContent) Notifications() []content.NotificationEntry { return f.notes }
func (f *fakeContent) Helper() content.HelperInfo                 { return f.helper }
func (f *fakeContent) FeatureFlags() content.FeatureFlags         { return f.flags }
func (f *fakeContent) ResolveProxyEnabled(deviceID string) bool {
	f.gotProxyDeviceID = deviceID
	if f.proxyEnabledFor == nil {
		return f.flags.Proxy.Enabled
	}
	return f.proxyEnabledFor[deviceID]
}

func TestWhatsNew_LocalePicked(t *testing.T) {
	fc := &fakeContent{
		entry: &content.WhatsNewEntry{
			Version: "1.0.4",
			Title:   content.Localized{"en": "Hello", "pt": "Ola"},
			Items: []content.WhatsNewItem{{
				Icon:      "star",
				IconColor: "blue",
				Localizations: map[string]content.WhatsNewItemContent{
					"en": {Title: "T-en", Description: "D-en"},
					"pt": {Title: "T-pt", Description: "D-pt"},
				},
			}},
		},
	}
	h := &Handlers{Content: fc}

	req := httptest.NewRequest(http.MethodGet, "/v1/whats-new?locale=pt-BR&version=1.0.4", nil)
	w := httptest.NewRecorder()
	h.WhatsNew(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", w.Code)
	}
	var got whatsNewResponse
	if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if got.Title != "Ola" {
		t.Fatalf("title = %q, want pt", got.Title)
	}
	if len(got.Items) != 1 || got.Items[0].Title != "T-pt" {
		t.Fatalf("item title = %q, want T-pt", got.Items[0].Title)
	}
	if fc.gotVersion != "1.0.4" {
		t.Fatalf("forwarded version = %q", fc.gotVersion)
	}
}

func TestWhatsNew_FallsBackToEnglish(t *testing.T) {
	fc := &fakeContent{
		entry: &content.WhatsNewEntry{
			Version: "1.0.4",
			Title:   content.Localized{"en": "Hello"},
			Items: []content.WhatsNewItem{{
				Localizations: map[string]content.WhatsNewItemContent{
					"en": {Title: "T-en", Description: "D-en"},
				},
			}},
		},
	}
	h := &Handlers{Content: fc}

	req := httptest.NewRequest(http.MethodGet, "/v1/whats-new?locale=ja", nil)
	w := httptest.NewRecorder()
	h.WhatsNew(w, req)

	var got whatsNewResponse
	_ = json.NewDecoder(w.Body).Decode(&got)
	if got.Title != "Hello" || got.Items[0].Title != "T-en" {
		t.Fatalf("expected English fallback, got %+v", got)
	}
}

func TestNotifications_EmptyWhenContentMissing(t *testing.T) {
	h := &Handlers{}
	req := httptest.NewRequest(http.MethodGet, "/v1/notifications", nil)
	w := httptest.NewRecorder()
	h.Notifications(w, req)
	if w.Code != http.StatusOK {
		t.Fatalf("status = %d", w.Code)
	}
	if strings.TrimSpace(w.Body.String()) != "[]" {
		t.Fatalf("body = %q, want []", w.Body.String())
	}
}

func TestHelperLatest_ReturnsInfo(t *testing.T) {
	fc := &fakeContent{
		helper: content.HelperInfo{
			LatestVersion: "1.0.4",
			DownloadURL:   "https://example.com/x.pkg",
			BlockProxy:    true,
			ReleaseNotes:  content.Localized{"en": "notes"},
		},
	}
	h := &Handlers{Content: fc}
	req := httptest.NewRequest(http.MethodGet, "/v1/helper/latest", nil)
	w := httptest.NewRecorder()
	h.HelperLatest(w, req)

	var got helperResponse
	if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if got.LatestVersion != "1.0.4" || !got.BlockProxy || got.ReleaseNotes != "notes" {
		t.Fatalf("got %+v", got)
	}
}

func TestFeatureFlags_DefaultDisabled(t *testing.T) {
	fc := &fakeContent{
		flags: content.FeatureFlags{
			Proxy: content.ProxyFeatureFlag{
				Enabled:         false,
				DisabledMessage: content.Localized{"en": "Proxy is paused.", "pt": "Proxy pausado."},
			},
		},
	}
	h := &Handlers{Content: fc}
	req := httptest.NewRequest(http.MethodGet, "/v1/feature-flags?locale=pt", nil)
	w := httptest.NewRecorder()
	h.FeatureFlags(w, req)

	var got featureFlagsResponse
	if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if got.Proxy.Enabled {
		t.Fatalf("expected proxy disabled by default")
	}
	if got.Proxy.DisabledMessage != "Proxy pausado." {
		t.Fatalf("expected pt message, got %q", got.Proxy.DisabledMessage)
	}
	if got.Proxy.HTTPSMitmEnabled {
		t.Fatal("expected HTTPS MITM disabled by default")
	}
	if got.Proxy.HTTPSMitmBackend != "off" {
		t.Fatalf("expected empty HTTPS MITM backend to default to off, got %q", got.Proxy.HTTPSMitmBackend)
	}
}

func TestFeatureFlags_DeviceOverride(t *testing.T) {
	fc := &fakeContent{
		flags: content.FeatureFlags{
			Proxy: content.ProxyFeatureFlag{
				Enabled:         false,
				DisabledMessage: content.Localized{"en": "off"},
			},
		},
		proxyEnabledFor: map[string]bool{"allowed-device": true},
	}
	h := &Handlers{Content: fc}
	req := httptest.NewRequest(http.MethodGet, "/v1/feature-flags?deviceId=allowed-device", nil)
	w := httptest.NewRecorder()
	h.FeatureFlags(w, req)

	var got featureFlagsResponse
	_ = json.NewDecoder(w.Body).Decode(&got)
	if !got.Proxy.Enabled {
		t.Fatalf("expected override to enable proxy for allowed-device")
	}
	if fc.gotProxyDeviceID != "allowed-device" {
		t.Fatalf("device id not forwarded: %q", fc.gotProxyDeviceID)
	}
}

func TestFeatureFlags_ReturnsHTTPSMITMFields(t *testing.T) {
	fc := &fakeContent{
		flags: content.FeatureFlags{
			Proxy: content.ProxyFeatureFlag{
				Enabled:          true,
				HTTPSMitmEnabled: true,
				HTTPSMitmBackend: "nio",
				DisabledMessage:  content.Localized{"en": "on"},
			},
		},
	}
	h := &Handlers{Content: fc}
	req := httptest.NewRequest(http.MethodGet, "/v1/feature-flags?deviceId=test&locale=en", nil)
	w := httptest.NewRecorder()
	h.FeatureFlags(w, req)

	var got featureFlagsResponse
	if err := json.NewDecoder(w.Body).Decode(&got); err != nil {
		t.Fatalf("decode: %v", err)
	}
	if !got.Proxy.HTTPSMitmEnabled {
		t.Fatal("expected HTTPS MITM enabled")
	}
	if got.Proxy.HTTPSMitmBackend != "nio" {
		t.Fatalf("https MITM backend = %q, want nio", got.Proxy.HTTPSMitmBackend)
	}
}

func TestContentStore_LoadsEmbeddedData(t *testing.T) {
	s, err := content.Load()
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if s.Helper().LatestVersion == "" {
		t.Fatal("helper latestVersion is empty in embedded data")
	}
	if entry := s.LatestWhatsNew(""); entry == nil || entry.Version == "" {
		t.Fatal("expected at least one whats-new entry")
	}
	if notes := s.Notifications(); len(notes) == 0 {
		t.Fatal("expected at least one notification")
	}
}
