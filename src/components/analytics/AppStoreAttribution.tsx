"use client";

// Stamps Apple's `pt`/`ct` tokens onto every outbound Mac App Store link.
//
// Done from the document rather than inside each CTA for the same reason the
// Google Ads and PostHog tags next door delegate their click listeners: there
// are seven hardcoded listing URLs across the site, and the ones on the Google
// Ads sitelink pages (/features, /network, ...) live in a server component
// that cannot call a hook. One layer in the root layout covers all of them,
// plus anything added later.
import { usePathname } from "next/navigation";
import { useEffect } from "react";
import {
  CAMPAIGN_TOKEN_STORAGE_KEY,
  campaignTokenFrom,
  withAppleAttribution,
} from "@/lib/appStore";

const APP_STORE_LINKS = 'a[href*="apps.apple.com"]';

// sessionStorage, not localStorage: a `ct` describes how someone arrived on
// this visit. Carrying it into an unrelated visit weeks later would credit the
// wrong campaign. Private-mode Safari throws on access, hence the guards.
function readStoredToken(): string | null {
  try {
    return window.sessionStorage.getItem(CAMPAIGN_TOKEN_STORAGE_KEY);
  } catch {
    return null;
  }
}

function storeToken(token: string): void {
  try {
    window.sessionStorage.setItem(CAMPAIGN_TOKEN_STORAGE_KEY, token);
  } catch {
    // Attribution is best-effort; a blocked store must never break a download.
  }
}

export function AppStoreAttribution() {
  // App Router navigations drop the query string, so a visitor who lands on
  // /?ct=reddit-462 and then clicks through to /pricing has no `ct` left in the
  // URL. The stored token is what keeps that install attributed.
  const pathname = usePathname();

  useEffect(() => {
    const token = campaignTokenFrom(window.location.search, readStoredToken());
    storeToken(token);

    const stamp = () => {
      document
        .querySelectorAll<HTMLAnchorElement>(APP_STORE_LINKS)
        .forEach((link) => {
          const next = withAppleAttribution(link.href, token);
          if (next !== link.href) link.setAttribute("href", next);
        });
    };

    stamp();

    // CTAs appear after the first paint too — the mobile menu, and every
    // section framer-motion reveals on scroll. Observing childList only (never
    // attributes) is what stops our own setAttribute from re-triggering this.
    //
    // Coalesced on a microtask rather than a frame: a link opened in a
    // background tab (cmd-click, the normal way someone opens a link from a
    // Reddit thread) never gets a frame, so requestAnimationFrame left those
    // CTAs unstamped until the tab was looked at — caught in the browser.
    let queued = false;
    const observer = new MutationObserver(() => {
      if (queued) return;
      queued = true;
      queueMicrotask(() => {
        queued = false;
        stamp();
      });
    });
    observer.observe(document.body, { childList: true, subtree: true });

    return () => observer.disconnect();
  }, [pathname]);

  return null;
}
