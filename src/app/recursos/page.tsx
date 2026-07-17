import type { Metadata } from "next";
import {
  MarketingShell,
  PageHero,
  BulletList,
  AppStoreButton,
  FEATURES,
} from "@/components/marketing/marketing";

// Portuguese-named alias of /features so the "Recursos" ad sitelink resolves
// (200) instead of 404. Same content as /features; canonical points there to
// avoid duplicate-content penalties.
export const metadata: Metadata = {
  title: "Recursos | CosmoKit para o Simulador iOS",
  description:
    "Tudo o que o CosmoKit traz para o seu fluxo no Simulador do iOS: controle do simulador, captura e gravação de tela, proxy de rede, notificações push, simulação de GPS e deep links.",
  alternates: { canonical: "https://usecosmoskittool.com/features" },
};

export default function RecursosPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="Recursos"
        title="Tudo o que você precisa para"
        highlight="testar simuladores mais rápido"
        subtitle="O CosmoKit é o companheiro nativo para macOS de quem desenvolve para iOS: controle, capture e inspecione qualquer simulador sem tocar no terminal."
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
            Pronto para assumir o controle do seu simulador?
          </h2>
          <p className="text-muted-foreground mb-6">
            Baixe o CosmoKit na Mac App Store e desenvolva mais rápido hoje
            mesmo.
          </p>
          <div className="flex justify-center">
            <AppStoreButton />
          </div>
        </div>
      </div>
    </MarketingShell>
  );
}
