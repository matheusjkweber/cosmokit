// Roughly nine in ten paid clicks came from people on Android, iOS, Linux or
// Windows: the phrase-matched "ios simulator" keywords also match "ios
// simulator for windows". Negative keywords stop paying for that traffic; this
// page captures the organic version of the same question, answers it honestly,
// and routes the few readers who do own a Mac to the product.
import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, Check, X } from "lucide-react";
import {
  MarketingShell,
  PageHero,
  AppStoreButton,
} from "@/components/marketing/marketing";
import { MacOnlyNotice } from "@/components/MacOnlyNotice";

export const metadata: Metadata = {
  title: "Can you run the iOS Simulator on Windows? Honest answer",
  description:
    "The iOS Simulator ships inside Xcode and Xcode is macOS only, so it cannot run on Windows or Linux. Here is what actually works, what does not, and what to use if you do have a Mac.",
  alternates: {
    canonical: "https://usecosmoskittool.com/ios-simulator-on-windows",
  },
};

const WORKS = [
  "A Mac (any Apple silicon or Intel Mac running macOS 14 or later) with Xcode installed",
  "A rented Mac in the cloud, then remote into it",
  "A CI service with macOS runners, for automated test runs",
  "Cross-platform frameworks with their own preview tooling, for layout work only",
];

const DOES_NOT_WORK = [
  "Emulators claiming to run the real iOS Simulator on Windows",
  "Browser-based 'iPhone simulators', which only resize a web page",
  "Running Xcode in a virtual machine on non-Apple hardware, which breaks Apple's licence terms",
  "Android emulators, which run Android and cannot run an iOS build",
];

export default function IOSSimulatorOnWindowsPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="Straight answer"
        title="Can you run the iOS Simulator"
        highlight="on Windows?"
        subtitle="No. The iOS Simulator ships inside Xcode, Xcode runs only on macOS, and Apple does not license it for other platforms. Here is what genuinely works instead."
      />

      <section className="container mx-auto px-4 pb-16">
        <div className="grid gap-6 md:grid-cols-2 max-w-4xl mx-auto">
          <div className="rounded-2xl border border-border/60 bg-card/40 p-6">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Check className="h-4 w-4 text-green-400" /> What works
            </h2>
            <ul className="space-y-3">
              {WORKS.map((item) => (
                <li key={item} className="flex items-start gap-3 text-sm">
                  <Check className="h-4 w-4 mt-0.5 shrink-0 text-green-400" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>
          <div className="rounded-2xl border border-border/60 bg-card/40 p-6">
            <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <X className="h-4 w-4 text-red-400" /> What does not
            </h2>
            <ul className="space-y-3">
              {DOES_NOT_WORK.map((item) => (
                <li key={item} className="flex items-start gap-3 text-sm">
                  <X className="h-4 w-4 mt-0.5 shrink-0 text-red-400" />
                  <span>{item}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      <section className="container mx-auto px-4 pb-24 text-center">
        <div className="max-w-2xl mx-auto rounded-2xl border border-border/60 bg-card/40 p-8">
          <h2 className="text-2xl font-bold mb-3">
            If you do have a Mac, CosmoKit makes the Simulator much faster
          </h2>
          <p className="text-muted-foreground mb-6">
            Boot and control simulators without the terminal, capture
            screenshots and video, send test pushes, open deep links, simulate
            GPS and inspect network traffic. Free to start.
          </p>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <AppStoreButton />
            <Link
              href="/features/"
              className="inline-flex items-center gap-2 rounded-xl border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow transition-colors px-5 py-2.5 text-sm font-medium"
            >
              See what it does <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
          <p className="mt-4 text-xs text-muted-foreground/60">
            Requires macOS 14+, Xcode and the iOS Simulator.
          </p>
          <MacOnlyNotice />
        </div>
      </section>
    </MarketingShell>
  );
}
