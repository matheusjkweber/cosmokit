"use client";

// PostHog web analytics for the marketing site.
//
// This reports to the same PostHog project the Mac app already uses, so a visit
// here and an activation inside the app land in one funnel instead of two tools
// that cannot see each other.
//
// Loaded the same way as the Google Ads tag next door: a plain script through
// next/script, no npm dependency, which keeps the static export unchanged.
import Script from "next/script";
import { usePathname } from "next/navigation";
import { useEffect, useRef } from "react";

const KEY = process.env.NEXT_PUBLIC_POSTHOG_KEY ?? "";
const HOST = process.env.NEXT_PUBLIC_POSTHOG_HOST ?? "https://us.i.posthog.com";

// PostHog serves the library from a sibling host of the ingestion API.
const ASSETS_HOST = HOST.replace(".i.posthog.com", "-assets.i.posthog.com");

type PostHogClient = {
  init: (key: string, config: Record<string, unknown>) => void;
  capture: (event: string, properties?: Record<string, unknown>) => void;
};

function client(): PostHogClient | null {
  if (typeof window === "undefined") return null;
  const w = window as unknown as { posthog?: PostHogClient };
  return typeof w.posthog?.capture === "function" ? w.posthog : null;
}

export function PostHogAnalytics() {
  const pathname = usePathname();
  const seenFirstPath = useRef(false);

  // App Router navigations never reload the page, so PostHog only ever sees the
  // page the visitor landed on. Every move after that has to be sent by hand.
  // The first run is skipped because init already sent that one.
  useEffect(() => {
    if (!KEY) return;
    if (!seenFirstPath.current) {
      seenFirstPath.current = true;
      return;
    }
    client()?.capture("$pageview");
  }, [pathname]);

  // The one action on this site that means anything: leaving for the Mac App
  // Store. Delegated from the document so every CTA is covered without each
  // component having to know about analytics.
  useEffect(() => {
    if (!KEY) return;
    const onClick = (event: Event) => {
      const target = event.target as HTMLElement | null;
      const link = target?.closest?.('a[href*="apps.apple.com"]') as HTMLAnchorElement | null;
      if (!link) return;
      client()?.capture("app_store_click", {
        href: link.href,
        path: window.location.pathname,
      });
    };
    document.addEventListener("click", onClick, true);
    return () => document.removeEventListener("click", onClick, true);
  }, []);

  // With no key configured the site ships no analytics at all, rather than a
  // half-loaded tag that throws on every page.
  if (!KEY) return null;

  return (
    <Script
      src={`${ASSETS_HOST}/static/array.js`}
      strategy="afterInteractive"
      onLoad={() => {
        const posthog = client();
        if (!posthog) return;
        posthog.init(KEY, {
          api_host: HOST,
          // person_profiles: only create a profile once someone does something
          // worth attributing, so anonymous browsing stays cheap and anonymous.
          person_profiles: "identified_only",
          capture_pageview: true,
          capture_pageleave: true,
        });
        // The PostHog project is shared by several products (and by the Mac
        // app), and every query filters on cosmohq_app. Landing events shipped
        // without it for the first ten days and were unattributable — register
        // stamps it on every event, with a marker separating web from app
        // traffic. Registered (not $set) so anonymous visitors stay anonymous.
        (posthog as unknown as {
          register?: (props: Record<string, unknown>) => void;
        }).register?.({
          cosmohq_app: "cosmokit",
          cosmohq_surface: "landing",
        });
      }}
    />
  );
}
