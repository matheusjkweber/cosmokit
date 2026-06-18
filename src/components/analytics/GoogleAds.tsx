"use client";

// Google Ads global site tag (gtag.js) + conversion tracking.
// The base tag enables Google Ads to verify the site, build remarketing
// audiences and feed Smart Bidding. Because CosmoKit is purchased off-site on
// the Mac App Store, the "conversion" event is fired when a visitor clicks any
// App Store link (the only meaningful on-site conversion action) — a delegated
// document listener so every CTA across the site is covered without touching
// each component.
import Script from "next/script";
import { useEffect } from "react";

const AW_ID = "AW-18227085442";
const CONVERSION_SEND_TO = "AW-18227085442/-AkpCNjBh7wcEIKBrfND";

export function GoogleAds() {
  useEffect(() => {
    const onClick = (e: Event) => {
      const target = e.target as HTMLElement | null;
      const link = target?.closest?.('a[href*="apps.apple.com"]');
      if (!link) return;
      const w = window as unknown as { gtag?: (...args: unknown[]) => void };
      if (typeof w.gtag !== "function") return;
      w.gtag("event", "conversion", {
        send_to: CONVERSION_SEND_TO,
        value: 1.0,
        currency: "BRL",
      });
    };
    document.addEventListener("click", onClick, true);
    return () => document.removeEventListener("click", onClick, true);
  }, []);

  return (
    <>
      <Script
        src={`https://www.googletagmanager.com/gtag/js?id=${AW_ID}`}
        strategy="afterInteractive"
      />
      <Script id="gtag-init" strategy="afterInteractive">
        {`window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', '${AW_ID}');`}
      </Script>
    </>
  );
}
