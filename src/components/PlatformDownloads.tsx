"use client";

import { motion } from "framer-motion";
import { Apple, ArrowDownToLine, ArrowRight, ShieldCheck } from "lucide-react";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { useTranslations } from "@/lib/i18n";

const APP_STORE_URL =
  "https://apps.apple.com/br/app/cosmokit-tools/id6756494471?mt=12";
const PROXY_HELPER_URL = "/downloads/CosmoKitProxyHelper.pkg";

export function PlatformDownloads() {
  const t = useTranslations("Downloads");

  return (
    <section id="download" className="py-24 md:py-32 relative overflow-hidden">
      {/* Background */}
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-violet-DEFAULT/[0.03] to-transparent" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[400px] bg-violet-DEFAULT/[0.05] rounded-full blur-[150px]" />

      <div className="container mx-auto px-4 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="max-w-3xl mx-auto text-center"
        >
          <div className="inline-flex items-center justify-center w-16 h-16 mb-6 rounded-2xl bg-violet-DEFAULT/10 border border-violet-DEFAULT/20">
            <Apple className="h-8 w-8 text-violet-light" />
          </div>

          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-foreground mb-4">
            {t("title1")}
            <br />
            <span className="gradient-text">{t("title2")}</span>
          </h2>

          <p className="text-lg text-muted-foreground mb-10 max-w-xl mx-auto">
            {t("subtitle")}
          </p>

          <div className="mx-auto grid max-w-2xl gap-4 sm:grid-cols-[1fr_0.92fr]">
            <Button
              asChild
              size="lg"
              className="gap-2.5 px-8 h-14 text-base bg-violet-DEFAULT hover:bg-violet-deep shadow-lg shadow-violet-DEFAULT/25 transition-all duration-300 hover:shadow-violet-DEFAULT/40 hover:scale-[1.02] active:scale-[0.98]"
            >
              <Link
                href={APP_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
              >
                <Apple className="h-5 w-5" />
                {t("cta")}
                <ArrowRight className="h-4 w-4" />
              </Link>
            </Button>

            <Button
              asChild
              size="lg"
              variant="outline"
              className="gap-2.5 px-6 h-14 text-base border-violet-DEFAULT/35 bg-violet-DEFAULT/5 text-foreground hover:bg-violet-DEFAULT/10 hover:border-violet-DEFAULT/55 transition-all duration-300 hover:scale-[1.02] active:scale-[0.98]"
            >
              <Link href={PROXY_HELPER_URL}>
                <ArrowDownToLine className="h-5 w-5 text-violet-light" />
                {t("helperCta")}
              </Link>
            </Button>
          </div>

          <div className="mt-5 mx-auto max-w-2xl rounded-2xl border border-violet-DEFAULT/20 bg-card/60 p-4 text-left shadow-sm shadow-violet-DEFAULT/10 backdrop-blur-sm">
            <div className="flex items-start gap-3">
              <div className="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-violet-DEFAULT/10 text-violet-light">
                <ShieldCheck className="h-4 w-4" />
              </div>
              <div>
                <p className="text-sm font-semibold text-foreground">
                  {t("helperTitle")}
                </p>
                <p className="mt-1 text-sm leading-6 text-muted-foreground">
                  {t("helperDescription")}
                </p>
              </div>
            </div>
          </div>

          <div className="mt-8 flex items-center justify-center gap-6 text-sm text-muted-foreground/60">
            <span>{t("info1")}</span>
            <span className="w-1 h-1 rounded-full bg-muted-foreground/20" />
            <span>{t("info2")}</span>
            <span className="w-1 h-1 rounded-full bg-muted-foreground/20" />
            <span>{t("info3")}</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
