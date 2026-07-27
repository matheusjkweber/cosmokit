import type { Metadata } from "next";
import { HomeClient } from "@/components/HomeClient";
import en from "../../../messages/en.json";
import es from "../../../messages/es.json";
import ptBR from "../../../messages/pt-BR.json";

const SITE = "https://usecosmoskittool.com";

const messages: Record<string, typeof en> = {
  en,
  es,
  "pt-BR": ptBR,
};

const localeMeta: Record<string, { title: string; description: string; og: string }> = {
  en: {
    title: "CosmoKit | iOS Simulator Toolkit for Mac",
    description:
      "Control the iOS Simulator from one native Mac app: screenshots, video recording, push notifications, deep links, GPS simulation and network proxy. Free tier available.",
    og: "en_US",
  },
  "pt-BR": {
    title: "CosmoKit | Ferramentas do Simulador iOS para Mac",
    description:
      "Controle o Simulador iOS em um app nativo para Mac: capturas de tela, gravação de vídeo, notificações push, deep links, simulação de GPS e proxy de rede. Plano gratuito disponível.",
    og: "pt_BR",
  },
  es: {
    title: "CosmoKit | Herramientas del Simulador iOS para Mac",
    description:
      "Controla el Simulador iOS desde una app nativa para Mac: capturas, grabación de video, notificaciones push, deep links, simulación GPS y proxy de red. Plan gratuito disponible.",
    og: "es_ES",
  },
};

export function generateStaticParams() {
  return [{ locale: "en" }, { locale: "pt-BR" }, { locale: "es" }];
}

export async function generateMetadata({
  params,
}: {
  params: { locale: string };
}): Promise<Metadata> {
  const meta = localeMeta[params.locale] ?? localeMeta.en;
  return {
    title: meta.title,
    description: meta.description,
    alternates: {
      canonical: `${SITE}/${params.locale}/`,
      languages: {
        en: `${SITE}/en/`,
        "pt-BR": `${SITE}/pt-BR/`,
        es: `${SITE}/es/`,
        "x-default": `${SITE}/en/`,
      },
    },
    openGraph: {
      title: meta.title,
      description: meta.description,
      locale: meta.og,
      url: `${SITE}/${params.locale}/`,
      // Next replaces the root layout's openGraph wholesale rather than merging
      // into it, so everything the root sets has to be repeated here. Leaving
      // images out cost every locale its og:image, which is the field Facebook,
      // Instagram, LinkedIn, WhatsApp, Slack and iMessage read: shares of this
      // site rendered as a bare text card with no picture.
      type: "website",
      siteName: "CosmoKit",
      images: [
        {
          url: "/screenshots/macos-2.png",
          width: 1200,
          height: 750,
          alt: "CosmoKit App Screenshot",
        },
      ],
    },
  };
}

export default function Home({ params }: { params: { locale: string } }) {
  const m = messages[params.locale] ?? en;
  const faqItems = Object.values(
    (m.FAQ?.items ?? {}) as Record<string, { question: string; answer: string }>
  );

  const faqJsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqItems.map((item) => ({
      "@type": "Question",
      name: item.question,
      acceptedAnswer: { "@type": "Answer", text: item.answer },
    })),
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
      />
      <HomeClient />
    </>
  );
}
