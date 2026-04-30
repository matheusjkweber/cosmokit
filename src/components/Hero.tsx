"use client";

import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { Apple, ArrowDown, Terminal } from "lucide-react";
import { useTranslations } from "@/lib/i18n";

const APP_STORE_URL =
  "https://apps.apple.com/br/app/cosmokit-tools/id6756494471?mt=12";

export function Hero() {
  const t = useTranslations("Hero");

  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center text-center px-4 pt-20 pb-0 overflow-hidden">
      {/* Deep dark background */}
      <div className="absolute inset-0 bg-[#08050e]" />

      {/* Ambient violet glow behind text */}
      <div className="absolute top-[15%] left-1/2 -translate-x-1/2 w-[800px] h-[500px] bg-violet-DEFAULT/[0.06] rounded-full blur-[160px]" />

      {/* Grid pattern */}
      <div className="absolute inset-0 grid-bg opacity-25" />

      {/* Noise */}
      <div className="absolute inset-0 noise-bg" />

      {/* ─── Text Content ─── */}
      <div className="relative z-10 max-w-3xl mx-auto space-y-6 mb-12">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1, ease: [0.22, 1, 0.36, 1] }}
        >
          <span className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full text-[11px] font-semibold uppercase tracking-wider bg-violet-DEFAULT/8 text-violet-light/90 border border-violet-DEFAULT/15 backdrop-blur-sm">
            <span className="relative flex h-1.5 w-1.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-violet-light opacity-75" />
              <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-violet-light" />
            </span>
            {t("badge")}
          </span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
          className="text-[2.75rem] sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-[-0.035em] text-foreground leading-[1.08]"
        >
          {t("title1")}
          <br />
          <span className="gradient-text">{t("title2")}</span>
        </motion.h1>

        {/* Description */}
        <motion.p
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.35, ease: [0.22, 1, 0.36, 1] }}
          className="text-base md:text-lg text-muted-foreground max-w-xl mx-auto leading-relaxed"
        >
          {t("description")}
        </motion.p>

        {/* Terminal hint */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4, delay: 0.45 }}
          className="flex items-center justify-center gap-2 text-sm text-muted-foreground/50"
        >
          <Terminal className="h-3.5 w-3.5" />
          <span>
            {t.rich("terminalHint", {
              command: () => (
                <code className="px-1.5 py-0.5 rounded bg-violet-DEFAULT/8 font-mono text-xs text-violet-light/70">
                  xcrun simctl
                </code>
              ),
            })}
          </span>
        </motion.div>

        {/* CTAs */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.5, ease: [0.22, 1, 0.36, 1] }}
          className="flex flex-col sm:flex-row gap-3 justify-center pt-1"
        >
          <Button
            asChild
            size="lg"
            className="gap-2.5 px-7 h-12 text-base font-semibold bg-violet-DEFAULT hover:bg-violet-deep shadow-lg shadow-violet-DEFAULT/25 transition-all duration-300 hover:shadow-violet-DEFAULT/40 hover:scale-[1.02] active:scale-[0.98]"
          >
            <Link
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
            >
              <Apple className="h-5 w-5" />
              {t("ctaDownload")}
            </Link>
          </Button>
          <Button
            asChild
            variant="outline"
            size="lg"
            className="gap-2 px-7 h-12 text-base border-violet-DEFAULT/15 text-muted-foreground hover:text-foreground hover:bg-violet-DEFAULT/5 hover:border-violet-DEFAULT/25 transition-all duration-300 hover:scale-[1.02] active:scale-[0.98]"
          >
            <Link href="#features">
              {t("ctaFeatures")}
              <ArrowDown className="h-4 w-4" />
            </Link>
          </Button>
        </motion.div>

        {/* Subtext */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.4, delay: 0.65 }}
          className="text-xs text-muted-foreground/40"
        >
          {t("subtext")}
        </motion.p>
      </div>

      {/* ─── Hero Image — full-width promo ─── */}
      <motion.div
        initial={{ opacity: 0, y: 50, scale: 0.96 }}
        animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{
          duration: 1,
          delay: 0.55,
          ease: [0.22, 1, 0.36, 1],
        }}
        className="relative z-10 w-full max-w-6xl px-4"
      >
        <div className="relative rounded-2xl overflow-hidden ring-1 ring-white/[0.06] shadow-2xl shadow-violet-deep/20">
          <Image
            src={t("heroImage")}
            alt={t("heroImageAlt")}
            width={2400}
            height={1500}
            className="w-full h-auto"
            priority
          />
          {/* Edge vignette to blend into background */}
          <div className="absolute inset-0 pointer-events-none rounded-2xl shadow-[inset_0_0_80px_rgba(8,5,14,0.4)]" />
        </div>
        {/* Glow beneath */}
        <div className="absolute -bottom-16 left-1/2 -translate-x-1/2 w-3/4 h-32 bg-violet-DEFAULT/8 rounded-full blur-[60px]" />
      </motion.div>

      {/* Bottom fade into next section */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-background to-transparent z-[2]" />
    </section>
  );
}
