import type { Metadata } from "next";
import Link from "next/link";
import { Apple, Check, ArrowRight } from "lucide-react";
import {
  MarketingShell,
  AppStoreButton,
  APP_STORE_URL,
} from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Download CosmoKit for macOS",
  description:
    "Download CosmoKit free on the Mac App Store and start controlling, capturing and inspecting your iOS Simulator in seconds. Built for macOS and Xcode.",
  alternates: { canonical: "https://usecosmoskittool.com/download" },
};

const requirements = [
  "macOS 13 Ventura or later",
  "Xcode with the iOS Simulator installed",
  "Apple Silicon or Intel Mac",
  "Free to download, upgrade in-app anytime",
];

const steps = [
  "Download CosmoKit from the Mac App Store.",
  "Open the app and it detects your installed simulators automatically.",
  "Pick a simulator and start capturing, pushing or inspecting traffic.",
];

export default function DownloadPage() {
  return (
    <MarketingShell>
      <section className="container mx-auto px-4 pt-20 pb-12 md:pt-28 text-center">
        <div className="inline-flex items-center justify-center p-3 rounded-2xl bg-violet-DEFAULT/10 text-violet-light mb-5">
          <Apple className="h-7 w-7" />
        </div>
        <p className="text-sm font-medium text-violet-light tracking-wider uppercase mb-3">
          Download
        </p>
        <h1 className="text-4xl sm:text-5xl md:text-6xl font-bold tracking-tight mb-5">
          Get CosmoKit for <span className="gradient-text">macOS</span>
        </h1>
        <p className="text-lg text-muted-foreground max-w-2xl mx-auto mb-8">
          The native companion for iOS developers. Download free on the Mac App
          Store, no sign-up required.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-3">
          <AppStoreButton label="Download on the Mac App Store" />
          <Link
            href="/features/"
            className="inline-flex items-center gap-2 rounded-xl border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow transition-colors px-5 py-2.5 text-sm font-medium"
          >
            See all features <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </section>

      <section className="container mx-auto px-4 pb-8">
        <div className="grid md:grid-cols-2 gap-4 max-w-4xl mx-auto">
          <div className="rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-8">
            <h2 className="text-xl font-bold mb-5">Requirements</h2>
            <ul className="space-y-3">
              {requirements.map((r) => (
                <li key={r} className="flex items-start gap-3">
                  <span className="mt-0.5 flex-shrink-0 p-1 rounded-md bg-violet-DEFAULT/10 text-violet-light">
                    <Check className="h-4 w-4" />
                  </span>
                  <span className="text-[15px] text-muted-foreground leading-relaxed">
                    {r}
                  </span>
                </li>
              ))}
            </ul>
          </div>
          <div className="rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-8">
            <h2 className="text-xl font-bold mb-5">Get started in 3 steps</h2>
            <ol className="space-y-4">
              {steps.map((s, i) => (
                <li key={s} className="flex items-start gap-3">
                  <span className="flex-shrink-0 w-6 h-6 rounded-full bg-violet-DEFAULT/15 text-violet-light text-sm font-semibold flex items-center justify-center">
                    {i + 1}
                  </span>
                  <span className="text-[15px] text-muted-foreground leading-relaxed">
                    {s}
                  </span>
                </li>
              ))}
            </ol>
          </div>
        </div>

        <div className="max-w-2xl mx-auto text-center mt-10">
          <Link
            href={APP_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-muted-foreground/70 hover:text-violet-light transition-colors"
          >
            View CosmoKit on the Mac App Store →
          </Link>
        </div>
      </section>
    </MarketingShell>
  );
}
