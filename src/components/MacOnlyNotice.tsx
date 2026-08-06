"use client";

// Most paid traffic cannot install this product.
//
// CosmoKit is a Mac-only app, but of the visitors this site received in its
// first ten days roughly nine in ten arrived on Android, iOS, Linux or Windows
// (phrase-matched ad keywords like "ios simulator" also match "ios simulator
// for windows"). Every one of them saw a Mac App Store button that does nothing
// useful on their device, and left.
//
// This tells them plainly that it is a Mac app and gives them the one action
// that can still convert: send the link to the Mac they actually develop on.
import { useEffect, useState } from "react";
import { Laptop, Check, Copy } from "lucide-react";
import { useTranslations } from "@/lib/i18n";

type PostHogClient = {
  capture: (event: string, properties?: Record<string, unknown>) => void;
};

function posthog(): PostHogClient | null {
  if (typeof window === "undefined") return null;
  const w = window as unknown as { posthog?: PostHogClient };
  return typeof w.posthog?.capture === "function" ? w.posthog : null;
}

/// `null` until the platform is known, so server and client render the same
/// markup on the first pass and the static export does not hydrate-mismatch.
function useIsMac(): boolean | null {
  const [isMac, setIsMac] = useState<boolean | null>(null);

  useEffect(() => {
    const nav = window.navigator;
    // userAgentData is the modern signal; userAgent/platform cover the rest.
    // An iPad reports "MacIntel" in some configurations, so an explicit touch
    // check keeps tablets out of the Mac bucket.
    const uaData = (nav as unknown as { userAgentData?: { platform?: string } })
      .userAgentData;
    const platform = uaData?.platform ?? nav.platform ?? "";
    const ua = nav.userAgent ?? "";
    const looksMac = /mac/i.test(platform) || /macintosh|mac os x/i.test(ua);
    const looksTouch = nav.maxTouchPoints > 1 || /iphone|ipad|ipod/i.test(ua);
    setIsMac(looksMac && !looksTouch);
  }, []);

  return isMac;
}

export function MacOnlyNotice() {
  const t = useTranslations("MacOnly");
  const isMac = useIsMac();
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (isMac === false) {
      posthog()?.capture("non_mac_visitor", {
        path: window.location.pathname,
      });
    }
  }, [isMac]);

  // Mac visitors (and the pre-hydration pass) see nothing: the normal
  // App Store button above already works for them.
  if (isMac !== false) return null;

  const onCopy = async () => {
    const url = window.location.origin + "/download/";
    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2500);
    } catch {
      // Clipboard is blocked in some in-app browsers (this site gets a lot of
      // Facebook webview traffic). Selecting the text is the fallback.
      window.prompt(t("copyFallback"), url);
    }
    posthog()?.capture("send_to_mac_click", { path: window.location.pathname });
  };

  return (
    <div className="mx-auto mt-6 max-w-md rounded-xl border border-violet-DEFAULT/20 bg-violet-DEFAULT/5 px-4 py-3 text-left">
      <p className="flex items-start gap-2 text-sm text-foreground/80">
        <Laptop className="mt-0.5 h-4 w-4 shrink-0 text-violet-light" />
        <span>{t("body")}</span>
      </p>
      <button
        type="button"
        onClick={onCopy}
        className="mt-3 inline-flex items-center gap-2 rounded-lg bg-violet-DEFAULT px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-violet-deep"
      >
        {copied ? (
          <Check className="h-4 w-4" />
        ) : (
          <Copy className="h-4 w-4" />
        )}
        {copied ? t("copied") : t("copyLink")}
      </button>
    </div>
  );
}
