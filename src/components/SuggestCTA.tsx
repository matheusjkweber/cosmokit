"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { Lightbulb, Sparkles, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useTranslations, useLocale } from "@/lib/i18n";

export function SuggestCTA() {
  const t = useTranslations("SuggestCTA");
  const locale = useLocale();

  return (
    <section id="suggest" className="py-20 md:py-28 relative">
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[400px] bg-violet-DEFAULT/[0.08] rounded-full blur-[160px]" />

      <div className="container mx-auto px-4 relative z-10">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="max-w-3xl mx-auto"
        >
          <div className="relative rounded-3xl overflow-hidden border border-violet-DEFAULT/30 bg-gradient-to-br from-violet-DEFAULT/10 via-violet-deep/5 to-transparent backdrop-blur-sm">
            <div className="absolute inset-0 bg-gradient-to-br from-violet-DEFAULT/[0.04] via-transparent to-violet-light/[0.06] pointer-events-none" />
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[200px] h-[1px] bg-gradient-to-r from-transparent via-violet-light/60 to-transparent" />

            <div className="relative p-8 sm:p-12 text-center">
              <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-violet-DEFAULT/15 border border-violet-DEFAULT/30 mb-6 shadow-lg shadow-violet-DEFAULT/10">
                <Lightbulb className="h-7 w-7 text-violet-light" />
              </div>

              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-semibold uppercase tracking-[0.18em] bg-violet-DEFAULT/15 text-violet-light border border-violet-DEFAULT/25 mb-5">
                <Sparkles className="h-3 w-3" />
                {t("badge")}
              </span>

              <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-foreground mb-4 tracking-tight">
                {t("title")}
              </h2>
              <p className="text-base sm:text-lg text-muted-foreground max-w-xl mx-auto mb-8 leading-relaxed">
                {t("subtitle")}
              </p>

              <Button
                asChild
                size="lg"
                className="gap-2 bg-violet-DEFAULT hover:bg-violet-deep transition-all duration-300 shadow-lg shadow-violet-DEFAULT/30 hover:shadow-violet-DEFAULT/40 hover:scale-[1.02]"
              >
                <Link href={`/${locale}/suggest`}>
                  <Lightbulb className="h-4 w-4" />
                  {t("cta")}
                  <ArrowRight className="h-4 w-4" />
                </Link>
              </Button>

              <p className="mt-5 text-xs text-muted-foreground/70">
                {t("footnote")}
              </p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
