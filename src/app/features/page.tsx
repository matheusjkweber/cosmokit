import type { Metadata } from "next";
import {
  MarketingShell,
  PageHero,
  BulletList,
  AppStoreButton,
  FEATURES,
} from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Features — CosmoKit for iOS Simulator",
  description:
    "Everything CosmoKit brings to your iOS Simulator workflow: simulator control, screen capture & recording, network proxy, push notifications, GPS simulation and deep links.",
  alternates: { canonical: "https://usecosmoskittool.com/features" },
};

export default function FeaturesPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="Features"
        title="Everything you need to"
        highlight="test simulators faster"
        subtitle="CosmoKit is the native macOS companion for iOS developers — control, capture and inspect any simulator without touching the terminal."
      />

      <div className="container mx-auto px-4 pb-8">
        <div className="max-w-4xl mx-auto divide-y divide-border/40">
          {FEATURES.map((f, i) => {
            const Icon = f.icon;
            return (
              <section
                key={f.id}
                id={f.id}
                className="scroll-mt-24 py-12 md:py-16 grid md:grid-cols-2 gap-8 items-start"
              >
                <div className={i % 2 === 1 ? "md:order-2" : ""}>
                  <div className="flex items-center gap-3 mb-3">
                    <span className="p-2.5 rounded-xl bg-violet-DEFAULT/10 text-violet-light">
                      <Icon className="h-5 w-5" />
                    </span>
                    <h2 className="text-2xl font-bold">{f.title}</h2>
                  </div>
                  <p className="text-sm font-medium text-violet-light/80 mb-3">
                    {f.tagline}
                  </p>
                  <p className="text-[15px] text-muted-foreground leading-relaxed">
                    {f.description}
                  </p>
                </div>
                <div
                  className={`rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-6 ${
                    i % 2 === 1 ? "md:order-1" : ""
                  }`}
                >
                  <BulletList items={f.bullets} />
                </div>
              </section>
            );
          })}
        </div>

        <div className="max-w-2xl mx-auto text-center mt-12 rounded-2xl border border-border/60 bg-card/40 p-10">
          <h2 className="text-2xl md:text-3xl font-bold mb-3">
            Ready to take control of your simulator?
          </h2>
          <p className="text-muted-foreground mb-6">
            Download CosmoKit on the Mac App Store and ship faster today.
          </p>
          <div className="flex justify-center">
            <AppStoreButton />
          </div>
        </div>
      </div>
    </MarketingShell>
  );
}
