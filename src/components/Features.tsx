"use client";

import { motion } from "framer-motion";
import Image from "next/image";
import {
  Camera,
  Video,
  Bell,
  Link2,
  MapPin,
  Shield,
  Globe,
  AppWindow,
  Settings2,
  Palette,
  ScanFace,
  KeyRound,
} from "lucide-react";
import { type LucideIcon } from "lucide-react";
import { useTranslations } from "@/lib/i18n";

interface FeatureDef {
  icon: LucideIcon;
  key: string;
  screenshot?: string;
  span: "lg" | "sm";
}

const featureDefs: FeatureDef[] = [
  // Row 1: large (2 cols) + small (1 col) = 3
  { icon: Camera, key: "screenshot", screenshot: "/screenshots/macos-3.png", span: "lg" },
  { icon: Bell, key: "push", span: "sm" },
  // Row 2: large + small = 3
  { icon: Video, key: "video", screenshot: "/screenshots/macos-11.png", span: "lg" },
  { icon: Link2, key: "deeplinks", span: "sm" },
  // Row 3: large + small = 3
  { icon: Globe, key: "proxy", screenshot: "/screenshots/macos-12.png", span: "lg" },
  { icon: MapPin, key: "gps", span: "sm" },
  // Row 4-5: 6 small cards = 2 rows of 3
  { icon: AppWindow, key: "apps", span: "sm" },
  { icon: Palette, key: "appearance", span: "sm" },
  { icon: Settings2, key: "statusbar", span: "sm" },
  { icon: Shield, key: "permissions", span: "sm" },
  { icon: ScanFace, key: "faceid", span: "sm" },
  { icon: KeyRound, key: "keychain", span: "sm" },
];

const containerVariants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.05,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 24 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: [0.22, 1, 0.36, 1] as const },
  },
};

export function Features() {
  const t = useTranslations("Features");

  return (
    <section id="features" className="py-24 md:py-32 relative">
      <div className="container mx-auto px-4">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="text-center mb-16 md:mb-20"
        >
          <p className="text-sm font-medium text-violet-light tracking-wider uppercase mb-3">
            {t("label")}
          </p>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-foreground mb-4">
            {t.rich("title", {
              highlight: () => (
                <span className="gradient-text">{t("titleHighlight")}</span>
              ),
            })}
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            {t.rich("subtitle", {
              command: () => (
                <code className="text-xs px-1.5 py-0.5 rounded bg-violet-DEFAULT/10 font-mono text-violet-light/70">
                  xcrun simctl
                </code>
              ),
            })}
          </p>
        </motion.div>

        {/* Bento grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, amount: 0.05 }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4"
        >
          {featureDefs.map((feature) => {
            const Icon = feature.icon;
            const isLarge = feature.span === "lg";
            const title = t(`items.${feature.key}.title`);
            const description = t(`items.${feature.key}.description`);

            if (isLarge) {
              return (
                <motion.div
                  key={feature.key}
                  variants={itemVariants}
                  className="group relative md:col-span-2 lg:col-span-2 rounded-2xl overflow-hidden transition-all duration-400"
                >
                  <div className="absolute -inset-[1px] rounded-2xl bg-gradient-to-br from-violet-DEFAULT/20 via-violet-light/10 to-violet-DEFAULT/20 opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-[0.5px]" />
                  <div className="absolute inset-0 rounded-2xl border border-border/60 group-hover:border-transparent transition-colors duration-500" />

                  <div className="relative rounded-2xl bg-card/40 backdrop-blur-sm overflow-hidden h-full group-hover:bg-card/70 transition-colors duration-400">
                    <div className="absolute inset-0 bg-gradient-to-br from-violet-DEFAULT/[0.04] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

                    <div className="relative p-6 flex flex-col md:flex-row md:items-center gap-6 h-full">
                      <div className="flex-1 min-w-0 flex flex-col justify-center">
                        <div className="flex items-center gap-3 mb-3">
                          <div className="flex-shrink-0 p-2.5 rounded-xl bg-violet-DEFAULT/10 text-violet-light group-hover:bg-violet-DEFAULT/15 transition-colors duration-300">
                            <Icon className="h-5 w-5" />
                          </div>
                          <h3 className="text-lg font-semibold text-foreground group-hover:text-violet-light transition-colors duration-300">
                            {title}
                          </h3>
                        </div>
                        <p className="text-sm text-muted-foreground leading-relaxed md:max-w-sm">
                          {description}
                        </p>
                      </div>

                      {feature.screenshot && (
                        <div className="flex-1 min-w-0 rounded-xl overflow-hidden border border-border/30 group-hover:border-violet-DEFAULT/20 transition-colors duration-500">
                          <Image
                            src={feature.screenshot}
                            alt={title}
                            width={800}
                            height={500}
                            className="w-full h-auto transition-transform duration-700 group-hover:scale-[1.03]"
                          />
                        </div>
                      )}
                    </div>
                  </div>
                </motion.div>
              );
            }

            return (
              <motion.div
                key={feature.key}
                variants={itemVariants}
                className="group relative rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm overflow-hidden transition-all duration-400 hover:border-violet-DEFAULT/25 hover:bg-card/70"
              >
                <div className="absolute inset-0 bg-gradient-to-br from-violet-DEFAULT/[0.04] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

                <div className="relative p-6">
                  <div className="flex items-start gap-3.5">
                    <div className="flex-shrink-0 p-2 rounded-xl bg-violet-DEFAULT/10 text-violet-light group-hover:bg-violet-DEFAULT/15 transition-colors duration-300">
                      <Icon className="h-5 w-5" />
                    </div>
                    <div>
                      <h3 className="text-[15px] font-semibold text-foreground mb-1 group-hover:text-violet-light transition-colors duration-300">
                        {title}
                      </h3>
                      <p className="text-sm text-muted-foreground leading-relaxed">
                        {description}
                      </p>
                    </div>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </motion.div>
      </div>
    </section>
  );
}
