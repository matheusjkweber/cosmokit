// Self-contained marketing pages used as Google Ads sitelink destinations.
// These are locale-less top-level routes (/features, /capture, ...) so the ad
// sitelink URLs resolve with real content. They deliberately do NOT use
// next-intl (they live outside the [locale] segment) and render statically
// under `output: export`.
import Link from "next/link";
import Image from "next/image";
import { MacOnlyNotice } from "@/components/MacOnlyNotice";
import {
  Apple,
  ArrowLeft,
  ArrowRight,
  Check,
  AppWindow,
  Camera,
  Globe,
  Bell,
  MapPin,
  Link2,
  type LucideIcon,
} from "lucide-react";

export const APP_STORE_URL =
  "https://apps.apple.com/app/cosmokit-tools/id6756494471?mt=12";
export const HOME_URL = "/en/";

export type Feature = {
  id: string;
  path?: string; // dedicated top-level page, when one exists
  icon: LucideIcon;
  title: string;
  tagline: string;
  description: string;
  bullets: string[];
  proQualifier?: string; // Pro-gated feature disclaimer shown inline (e.g. "Network Proxy is part of CosmoKit Pro (free trial included).")
};

export const FEATURES: Feature[] = [
  {
    id: "control",
    icon: AppWindow,
    title: "Simulator control",
    tagline: "Run every iOS Simulator without the terminal",
    description:
      "Boot, shut down, erase and manage every iOS Simulator from one native macOS app. No more memorizing xcrun simctl commands.",
    bullets: [
      "Boot and manage multiple simulators side by side",
      "Erase, reset and reboot in a single click",
      "Override appearance, status bar and permissions",
      "Install and launch any app instantly",
    ],
  },
  {
    id: "capture",
    path: "/capture/",
    icon: Camera,
    title: "Screen capture & recording",
    tagline: "Screenshots and video, ready for QA and marketing",
    description:
      "Capture pixel-perfect screenshots and record video of any simulator for bug reports, App Store assets and marketing, straight from the menu bar.",
    bullets: [
      "High-resolution screenshots in one tap",
      "Smooth screen recordings",
      "Perfect for QA, bug reports and store assets",
      "Save and share in seconds",
    ],
  },
  {
    id: "network",
    path: "/network/",
    icon: Globe,
    title: "Network proxy & inspection",
    tagline: "See and shape your simulator's traffic",
    description:
      "Route your simulator through CosmoKit's built-in proxy to inspect HTTPS requests, debug API calls and test how your app behaves on flaky networks.",
    bullets: [
      "Inspect HTTPS requests and responses",
      "Debug API integrations fast",
      "Test offline and slow-network behaviour",
      "One-click proxy setup",
    ],
    proQualifier: "Network Proxy is part of CosmoKit Pro (free trial included).",
  },
  {
    id: "push",
    path: "/push/",
    icon: Bell,
    title: "Push notifications",
    tagline: "Fire test pushes in one click",
    description:
      "Send fully custom push notification payloads to the simulator to test deep links, badges and notification UI, without a backend or a physical device.",
    bullets: [
      "Custom JSON payloads",
      "Test notification taps and deep links",
      "No server or device required",
      "Reusable templates",
    ],
  },
  {
    id: "location",
    path: "/location/",
    icon: MapPin,
    title: "Location & GPS simulation",
    tagline: "Put your app anywhere on Earth",
    description:
      "Set any GPS coordinate or simulate movement to test maps, geofencing and location-aware features without leaving your desk.",
    bullets: [
      "Drop the simulator on any coordinate",
      "Test geofencing and map features",
      "Simulate movement and routes",
      "Save favourite locations",
    ],
  },
  {
    id: "deeplinks",
    icon: Link2,
    title: "Deep links",
    tagline: "Open any URL scheme instantly",
    description:
      "Trigger universal links and custom URL schemes directly, so you can test routing and onboarding flows in seconds.",
    bullets: [
      "Open custom URL schemes",
      "Test universal links",
      "Validate routing and onboarding",
      "Reusable link history",
    ],
  },
];

export function featureHref(f: Feature): string {
  return f.path ?? `/features/#${f.id}`;
}

export function AppStoreButton({ label = "Get CosmoKit" }: { label?: string }) {
  return (
    <Link
      href={APP_STORE_URL}
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-2 rounded-xl bg-violet-DEFAULT hover:bg-violet-deep transition-colors px-5 py-2.5 text-sm font-medium text-white shadow-md shadow-violet-DEFAULT/20"
    >
      <Apple className="h-4 w-4" /> {label}
    </Link>
  );
}

export function MarketingShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-50 bg-background/70 backdrop-blur-2xl border-b border-border/40">
        <div className="container mx-auto flex items-center justify-between h-16 px-4">
          <Link href={HOME_URL} className="flex items-center gap-2.5 group">
            <Image
              src="/icon.png"
              alt="CosmoKit"
              width={32}
              height={32}
              className="rounded-lg transition-transform duration-300 group-hover:scale-110"
            />
            <span className="text-lg font-semibold tracking-tight">
              CosmoKit
            </span>
          </Link>
          <nav className="hidden sm:flex items-center gap-1 text-sm">
            <Link
              href="/features/"
              className="px-3 py-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-violet-glow transition-colors"
            >
              Features
            </Link>
            <Link
              href="/pricing/"
              className="px-3 py-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-violet-glow transition-colors"
            >
              Pricing
            </Link>
            <Link
              href="/download/"
              className="px-3 py-2 rounded-lg text-muted-foreground hover:text-foreground hover:bg-violet-glow transition-colors"
            >
              Download
            </Link>
          </nav>
          <AppStoreButton />
        </div>
      </header>

      <main>{children}</main>

      <footer className="border-t border-border/40 mt-24 relative">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[400px] h-[1px] bg-gradient-to-r from-transparent via-violet-DEFAULT/30 to-transparent" />
        <div className="container mx-auto px-4 py-10 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <Link
            href={HOME_URL}
            className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-violet-light transition-colors"
          >
            <ArrowLeft className="h-3.5 w-3.5" /> Back to home
          </Link>
          <div className="flex flex-wrap items-center gap-x-5 gap-y-2 text-sm text-muted-foreground">
            <Link href="/features/" className="hover:text-violet-light transition-colors">
              Features
            </Link>
            <Link href="/download/" className="hover:text-violet-light transition-colors">
              Download
            </Link>
            <Link href="/pricing/" className="hover:text-violet-light transition-colors">
              Pricing
            </Link>
            <Link href="/en/support/" className="hover:text-violet-light transition-colors">
              Support
            </Link>
            <Link href="/en/privacy/" className="hover:text-violet-light transition-colors">
              Privacy
            </Link>
          </div>
          <p className="text-xs text-muted-foreground/50">© 2026 CosmoKit</p>
        </div>
      </footer>
    </div>
  );
}

export function PageHero({
  eyebrow,
  title,
  highlight,
  subtitle,
}: {
  eyebrow: string;
  title: string;
  highlight?: string;
  subtitle: string;
}) {
  return (
    <section className="container mx-auto px-4 pt-20 pb-12 md:pt-28 md:pb-16 text-center">
      <p className="text-sm font-medium text-violet-light tracking-wider uppercase mb-3">
        {eyebrow}
      </p>
      <h1 className="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight mb-5">
        {title} {highlight && <span className="gradient-text">{highlight}</span>}
      </h1>
      <p className="text-lg text-muted-foreground max-w-2xl mx-auto mb-8">
        {subtitle}
      </p>
      <div className="flex flex-wrap items-center justify-center gap-3">
        <AppStoreButton />
        <Link
          href="/features/"
          className="inline-flex items-center gap-2 rounded-xl border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow transition-colors px-5 py-2.5 text-sm font-medium"
        >
          Explore all features <ArrowRight className="h-4 w-4" />
        </Link>
      </div>
    </section>
  );
}

export function BulletList({ items }: { items: string[] }) {
  return (
    <ul className="space-y-3">
      {items.map((b) => (
        <li key={b} className="flex items-start gap-3">
          <span className="mt-0.5 flex-shrink-0 p-1 rounded-md bg-violet-DEFAULT/10 text-violet-light">
            <Check className="h-4 w-4" />
          </span>
          <span className="text-[15px] text-muted-foreground leading-relaxed">{b}</span>
        </li>
      ))}
    </ul>
  );
}

// A focused single-feature page (used by /capture, /network, /push, /location).
export function FeaturePage({ featureId }: { featureId: string }) {
  const f = FEATURES.find((x) => x.id === featureId)!;
  const Icon = f.icon;
  const related = FEATURES.filter((x) => x.id !== f.id);
  return (
    <MarketingShell>
      <section className="container mx-auto px-4 pt-20 pb-12 md:pt-28">
        <div className="max-w-3xl mx-auto text-center">
          <div className="inline-flex items-center justify-center p-3 rounded-2xl bg-violet-DEFAULT/10 text-violet-light mb-5">
            <Icon className="h-7 w-7" />
          </div>
          <p className="text-sm font-medium text-violet-light tracking-wider uppercase mb-3">
            {f.tagline}
          </p>
          <h1 className="text-4xl sm:text-5xl font-bold tracking-tight mb-5">
            {f.title}
          </h1>
          <p className="text-lg text-muted-foreground mb-8">{f.description}</p>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <AppStoreButton />
            <Link
              href="/features/"
              className="inline-flex items-center gap-2 rounded-xl border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow transition-colors px-5 py-2.5 text-sm font-medium"
            >
              All features <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
          <p className="mt-4 text-xs text-muted-foreground/60">
            Requires macOS 14+, Xcode and the iOS Simulator.
          </p>
          {/* Non-Mac visitors: the App Store button above is a dead end */}
          <MacOnlyNotice />
          {f.proQualifier && (
            <p className="mt-2 text-sm text-violet-light/80 font-medium">
              {f.proQualifier}
            </p>
          )}
        </div>

        <div className="max-w-xl mx-auto mt-14 rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-8">
          <BulletList items={f.bullets} />
        </div>
      </section>

      <section className="container mx-auto px-4 pb-8">
        <h2 className="text-center text-sm font-medium text-muted-foreground/70 tracking-wider uppercase mb-6">
          More in CosmoKit
        </h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-4xl mx-auto">
          {related.map((r) => {
            const RIcon = r.icon;
            return (
              <Link
                key={r.id}
                href={featureHref(r)}
                className="group rounded-2xl border border-border/60 bg-card/40 hover:bg-card/70 hover:border-violet-DEFAULT/25 transition-all p-5"
              >
                <div className="flex items-center gap-3 mb-2">
                  <span className="p-2 rounded-xl bg-violet-DEFAULT/10 text-violet-light">
                    <RIcon className="h-4 w-4" />
                  </span>
                  <h3 className="text-[15px] font-semibold group-hover:text-violet-light transition-colors">
                    {r.title}
                  </h3>
                </div>
                <p className="text-sm text-muted-foreground leading-relaxed">
                  {r.tagline}
                </p>
              </Link>
            );
          })}
        </div>
      </section>
    </MarketingShell>
  );
}
