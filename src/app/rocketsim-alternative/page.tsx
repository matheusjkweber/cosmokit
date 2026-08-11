// Landing page for the "rocketsim alternative" keyword the Google campaign
// already bids on. Until now that high-intent click landed on the generic
// homepage. Comparison stays honest: it leads with what CosmoKit does and
// keeps claims about other tools to what a visitor can verify themselves.
import type { Metadata } from "next";
import Link from "next/link";
import { Check, ArrowRight } from "lucide-react";
import {
  MarketingShell,
  PageHero,
  AppStoreButton,
} from "@/components/marketing/marketing";
import { MacOnlyNotice } from "@/components/MacOnlyNotice";

export const metadata: Metadata = {
  title: "RocketSim Alternative | CosmoKit for the iOS Simulator",
  description:
    "Looking at RocketSim alternatives? CosmoKit controls the iOS Simulator with capture, push, deep links, GPS simulation, a full MITM network proxy and an App Store screenshot generator. One-time lifetime pricing available.",
  alternates: {
    canonical: "https://usecosmoskittool.com/rocketsim-alternative",
  },
};

const PILLARS = [
  {
    title: "Everything for the daily loop",
    body: "Boot and manage simulators, capture screenshots and video from the menu bar or a global shortcut, and keep your recent captures one click away.",
  },
  {
    title: "A real network proxy",
    body: "Inspect and intercept simulator traffic with CosmoKit's built-in MITM proxy. No separate proxy app, no manual certificate juggling.",
  },
  {
    title: "From capture to App Store",
    body: "Turn any capture into framed, ready-to-upload App Store screenshots with the built-in generator. Device frames included.",
  },
];

const FEATURES = [
  "Simulator control without the terminal (boot, erase, appearance, permissions, Face ID)",
  "Screenshots and video recording, with device frames and GIF export",
  "App Store screenshot generator",
  "Push notification testing",
  "Deep link testing with saved links",
  "GPS location and route simulation",
  "MITM network proxy for simulator traffic",
  "Multiple simulators side by side",
  "Menu bar quick capture and a global capture shortcut",
  "English, Spanish and Portuguese localization",
  "Free tier to start, subscription or one-time lifetime purchase for Pro",
];

export default function RocketSimAlternativePage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="RocketSim alternative"
        title="Another way to drive the"
        highlight="iOS Simulator"
        subtitle="RocketSim is a well-known tool and we respect it. If you want an alternative that adds a built-in network proxy, an App Store screenshot generator and a one-time lifetime price, CosmoKit is built for you."
      />

      <section className="container mx-auto px-4 pb-16">
        <div className="grid gap-6 md:grid-cols-3 max-w-5xl mx-auto">
          {PILLARS.map((pillar) => (
            <div
              key={pillar.title}
              className="rounded-2xl border border-border/60 bg-card/40 p-6"
            >
              <h2 className="text-lg font-semibold mb-2">{pillar.title}</h2>
              <p className="text-sm text-muted-foreground">{pillar.body}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="container mx-auto px-4 pb-16">
        <div className="max-w-3xl mx-auto rounded-2xl border border-border/60 bg-card/40 p-8">
          <h2 className="text-2xl font-bold mb-6 text-center">
            What you get with CosmoKit
          </h2>
          <ul className="space-y-3">
            {FEATURES.map((feature) => (
              <li key={feature} className="flex items-start gap-3 text-sm">
                <Check className="h-4 w-4 mt-0.5 shrink-0 text-violet-light" />
                <span>{feature}</span>
              </li>
            ))}
          </ul>
          <p className="mt-6 text-xs text-muted-foreground/70 text-center">
            Comparing tools? Both apps evolve quickly, so check the RocketSim
            site for its current feature list and pricing and decide what fits
            your workflow.
          </p>
        </div>
      </section>

      <section className="container mx-auto px-4 pb-24 text-center">
        <h2 className="text-2xl font-bold mb-3">
          Try CosmoKit free on your Mac
        </h2>
        <p className="text-muted-foreground mb-6 max-w-xl mx-auto">
          The free tier covers capture, push, deep links, GPS and simulator
          tools. Pro adds the proxy, unlimited simulators and watermark-free
          exports, as a subscription or a single lifetime purchase.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-3">
          <AppStoreButton />
          <Link
            href="/pricing/"
            className="inline-flex items-center gap-2 rounded-xl border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow transition-colors px-5 py-2.5 text-sm font-medium"
          >
            See pricing <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
        <p className="mt-4 text-xs text-muted-foreground/60">
          Requires macOS 14+, Xcode and the iOS Simulator.
        </p>
        <MacOnlyNotice />
      </section>
    </MarketingShell>
  );
}
