package email

import "strings"

// MaskEmail masks the local part of an email address, preserving the domain.
func MaskEmail(addr string) string {
	if addr == "" {
		return ""
	}
	at := strings.LastIndex(addr, "@")
	if at <= 0 {
		return addr
	}
	local := addr[:at]
	domain := addr[at:]

	if len(local) <= 3 {
		return "***" + domain
	}
	return local[:3] + "***" + domain
}
