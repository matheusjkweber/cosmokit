// Free Pro for students and open-source maintainers. At current install
// volume this costs effectively nothing and buys the thing the product most
// lacks: reviews and word of mouth inside the exact communities that search
// for simulator tooling. Fulfilled manually with App Store offer codes.
import type { Metadata } from "next";
import { Check, Mail } from "lucide-react";
import { MarketingShell, PageHero } from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Free CosmoKit Pro for students and open source",
  description:
    "Students and open-source maintainers can get CosmoKit Pro free for a year. Send us proof of enrolment or a link to your project and we will send an App Store code.",
  alternates: { canonical: "https://usecosmoskittool.com/students" },
};

const ELIGIBLE = [
  "Enrolled students with a university email or a valid student ID",
  "Maintainers of an open-source iOS or Swift project with public commits in the last year",
  "Bootcamp participants currently enrolled in an iOS course",
];

const MAILTO =
  "mailto:contato@usecosmoskittool.com" +
  "?subject=" +
  encodeURIComponent("CosmoKit Pro for students / open source") +
  "&body=" +
  encodeURIComponent(
    "Hi,\n\nI would like free CosmoKit Pro.\n\nI am a: (student / open-source maintainer)\nProof (student email, ID, or a link to my project):\n\nThanks,"
  );

export default function StudentsPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="Students and open source"
        title="CosmoKit Pro, free for"
        highlight="a year"
        subtitle="If you are learning iOS or maintaining an open-source Swift project, you should not have to pay for better tooling. Send us a quick proof and we will send a code."
      />

      <section className="container mx-auto px-4 pb-24">
        <div className="max-w-2xl mx-auto rounded-2xl border border-border/60 bg-card/40 p-8">
          <h2 className="text-lg font-semibold mb-4">Who qualifies</h2>
          <ul className="space-y-3 mb-8">
            {ELIGIBLE.map((item) => (
              <li key={item} className="flex items-start gap-3 text-sm">
                <Check className="h-4 w-4 mt-0.5 shrink-0 text-violet-light" />
                <span>{item}</span>
              </li>
            ))}
          </ul>

          <div className="text-center">
            <a
              href={MAILTO}
              className="inline-flex items-center gap-2 rounded-xl bg-violet-DEFAULT hover:bg-violet-deep transition-colors px-5 py-2.5 text-sm font-medium text-white shadow-md shadow-violet-DEFAULT/20"
            >
              <Mail className="h-4 w-4" /> Apply by email
            </a>
            <p className="mt-4 text-xs text-muted-foreground/70">
              Codes are redeemed in the Mac App Store. Renewable each year while
              you still qualify.
            </p>
          </div>
        </div>
      </section>
    </MarketingShell>
  );
}
