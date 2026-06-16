import type { Metadata } from "next";
import Link from "next/link";
import { Check } from "lucide-react";
import {
  MarketingShell,
  PageHero,
  APP_STORE_URL,
} from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Pricing — CosmoKit",
  description:
    "Start free, upgrade when you need more. CosmoKit plans: Free, Monthly $2.99, Yearly $19.99 (save 44%) and Lifetime $69.99 — all managed through the Mac App Store.",
  alternates: { canonical: "https://usecosmoskittool.com/pricing" },
};

const plans = [
  {
    name: "Free",
    price: "$0",
    period: "",
    description: "Essential tools to get started",
    features: [
      "1 simulator",
      "Screenshot & video capture (watermarked)",
      "Push notifications & deep links",
      "GPS location simulation",
    ],
    highlight: false,
    cta: "Download Free",
  },
  {
    name: "Monthly",
    price: "$2.99",
    period: "/mo",
    description: "Full access, cancel anytime",
    features: [
      "Everything in Free",
      "No watermarks",
      "Network proxy & app tools",
      "Unlimited simulators & saved entries",
    ],
    highlight: false,
    cta: "Start Monthly",
  },
  {
    name: "Yearly",
    price: "$19.99",
    period: "/yr",
    description: "Best value — save 44%",
    features: [
      "Everything in Monthly",
      "Device frames, bezels & touch indicators",
      "Audio recording & custom aspect ratio",
      "Location routes",
    ],
    highlight: true,
    badge: "Save 44%",
    cta: "Start Yearly",
  },
  {
    name: "Lifetime",
    price: "$69.99",
    period: "once",
    description: "Pay once, own it forever",
    features: [
      "Everything in Yearly",
      "All future updates included",
      "One-time payment",
      "No subscription",
    ],
    highlight: false,
    badge: "Best Deal",
    cta: "Buy Lifetime",
  },
];

export default function PricingPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="Pricing"
        title="Simple, transparent"
        highlight="pricing"
        subtitle="Start free, upgrade when you need more. All plans include every future update and are managed through the Mac App Store."
      />

      <div className="container mx-auto px-4 pb-8">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 max-w-6xl mx-auto items-start">
          {plans.map((plan) => (
            <div
              key={plan.name}
              className={`relative rounded-2xl border p-6 flex flex-col ${
                plan.highlight
                  ? "border-violet-DEFAULT/40 bg-violet-DEFAULT/[0.06] shadow-xl shadow-violet-DEFAULT/10"
                  : "border-border/60 bg-card/40 backdrop-blur-sm"
              }`}
            >
              {plan.badge && (
                <span className="absolute -top-2.5 left-1/2 -translate-x-1/2 text-xs px-3 py-0.5 rounded-full bg-violet-DEFAULT text-white border border-violet-DEFAULT shadow-md shadow-violet-DEFAULT/30">
                  {plan.badge}
                </span>
              )}
              <h3 className="text-lg font-semibold mb-1">{plan.name}</h3>
              <p className="text-sm text-muted-foreground mb-5">
                {plan.description}
              </p>
              <div className="mb-5">
                <span className="text-4xl font-bold">{plan.price}</span>
                {plan.period && (
                  <span className="text-sm text-muted-foreground ml-1.5">
                    {plan.period}
                  </span>
                )}
              </div>
              <ul className="space-y-2.5 mb-8 flex-1">
                {plan.features.map((f) => (
                  <li
                    key={f}
                    className="flex items-start gap-2 text-sm text-muted-foreground"
                  >
                    <Check className="h-4 w-4 text-violet-light flex-shrink-0 mt-0.5" />
                    <span>{f}</span>
                  </li>
                ))}
              </ul>
              <Link
                href={APP_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className={`w-full text-center rounded-xl px-4 py-2.5 text-sm font-medium transition-colors ${
                  plan.highlight
                    ? "bg-violet-DEFAULT hover:bg-violet-deep text-white shadow-md shadow-violet-DEFAULT/20"
                    : "border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow"
                }`}
              >
                {plan.cta}
              </Link>
            </div>
          ))}
        </div>

        <p className="text-center text-sm text-muted-foreground/70 mt-10">
          All plans are managed through the Mac App Store. Cancel or switch
          anytime.
        </p>
      </div>
    </MarketingShell>
  );
}
