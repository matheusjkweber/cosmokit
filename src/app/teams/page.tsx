// Volume licensing enquiry page. Deliberately no code in the app: seats are
// fulfilled with the existing Lifetime product through Apple Business Manager's
// volume purchase programme, so this is a landing page and a mailto.
import type { Metadata } from "next";
import { Check, Mail } from "lucide-react";
import { MarketingShell, PageHero } from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "CosmoKit for Teams | Volume licensing",
  description:
    "Buy CosmoKit Pro for a whole iOS team with one invoice. Volume Lifetime seats through Apple Business Manager, no per-seat subscription admin.",
  alternates: { canonical: "https://usecosmoskittool.com/teams" },
};

const POINTS = [
  "Lifetime seats, so there is no renewal to chase every year",
  "One invoice for the whole team, paid through Apple Business Manager",
  "Every Pro feature: network proxy, unlimited simulators, no watermarks",
  "Seats are redeemed by your developers with a code, no account system to manage",
];

const MAILTO =
  "mailto:contato@usecosmoskittool.com" +
  "?subject=" +
  encodeURIComponent("CosmoKit for Teams enquiry") +
  "&body=" +
  encodeURIComponent(
    "Hi,\n\nWe would like CosmoKit Pro for our team.\n\nCompany:\nNumber of seats:\nCountry (for invoicing):\n\nThanks,"
  );

export default function TeamsPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="For teams"
        title="CosmoKit Pro for"
        highlight="your whole team"
        subtitle="One invoice, Lifetime seats, and no subscription admin. Tell us how many developers you have and we will send a quote."
      />

      <section className="container mx-auto px-4 pb-24">
        <div className="max-w-2xl mx-auto rounded-2xl border border-border/60 bg-card/40 p-8">
          <ul className="space-y-3 mb-8">
            {POINTS.map((point) => (
              <li key={point} className="flex items-start gap-3 text-sm">
                <Check className="h-4 w-4 mt-0.5 shrink-0 text-violet-light" />
                <span>{point}</span>
              </li>
            ))}
          </ul>

          <div className="text-center">
            <a
              href={MAILTO}
              className="inline-flex items-center gap-2 rounded-xl bg-violet-DEFAULT hover:bg-violet-deep transition-colors px-5 py-2.5 text-sm font-medium text-white shadow-md shadow-violet-DEFAULT/20"
            >
              <Mail className="h-4 w-4" /> Request a quote
            </a>
            <p className="mt-4 text-xs text-muted-foreground/70">
              We usually reply within one business day.
            </p>
          </div>
        </div>
      </section>
    </MarketingShell>
  );
}
