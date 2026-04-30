"use client";

import { motion } from "framer-motion";
import { Check, Sparkles, Crown } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { useTranslations } from "@/lib/i18n";

const APP_STORE_URL =
  "https://apps.apple.com/br/app/cosmokit-tools/id6756494471?mt=12";

const freeFeatureKeys = ["f1", "f2", "f3", "f4", "f5", "f6", "f7"] as const;
const proFeatureKeys = [
  "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12", "f13",
] as const;

const planKeys = ["free", "monthly", "yearly", "lifetime"] as const;

export function Pricing() {
  const t = useTranslations("Pricing");

  const plans = planKeys.map((key) => ({
    key,
    name: t(`${key}.name`),
    price: t(`${key}.price`),
    period: t(`${key}.period`),
    description: t(`${key}.description`),
    cta: t(`${key}.cta`),
    features: key === "free"
      ? freeFeatureKeys.map((fk) => t(`freeFeatures.${fk}`))
      : proFeatureKeys.map((fk) => t(`proFeatures.${fk}`)),
    highlight: key === "yearly",
    badge: key === "yearly" || key === "lifetime" ? t(`${key}.badge`) : null,
    icon: key === "yearly" ? Sparkles : key === "lifetime" ? Crown : null,
  }));

  return (
    <section id="pricing" className="py-24 md:py-32 relative">
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[400px] bg-violet-DEFAULT/[0.04] rounded-full blur-[150px]" />

      <div className="container mx-auto px-4 relative z-10">
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
            {t("subtitle")}
          </p>
        </motion.div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 max-w-6xl mx-auto items-start">
          {plans.map((plan, index) => (
            <motion.div
              key={plan.key}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0.1 }}
              transition={{
                duration: 0.5,
                delay: index * 0.08,
                ease: [0.22, 1, 0.36, 1],
              }}
              className={`group relative rounded-2xl border p-6 flex flex-col transition-all duration-400 hover:scale-[1.02] ${
                plan.highlight
                  ? "border-violet-DEFAULT/40 bg-violet-DEFAULT/[0.06] shadow-xl shadow-violet-DEFAULT/10 lg:-mt-4 lg:pb-10"
                  : "border-border/60 bg-card/40 backdrop-blur-sm hover:border-violet-DEFAULT/15"
              }`}
            >
              <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-violet-DEFAULT/[0.03] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

              {plan.badge && (
                <Badge
                  className={`absolute -top-2.5 left-1/2 -translate-x-1/2 text-xs px-3 py-0.5 ${
                    plan.highlight
                      ? "bg-violet-DEFAULT text-white border-violet-DEFAULT shadow-md shadow-violet-DEFAULT/30"
                      : "bg-violet-deep text-white border-violet-deep"
                  }`}
                >
                  {plan.badge}
                </Badge>
              )}

              <div className="relative mb-6">
                <h3 className="text-lg font-semibold text-foreground mb-1">
                  {plan.name}
                </h3>
                <p className="text-sm text-muted-foreground">
                  {plan.description}
                </p>
              </div>

              <div className="relative mb-6">
                <span className="text-4xl font-bold text-foreground">
                  {plan.price}
                </span>
                {plan.period && (
                  <span className="text-sm text-muted-foreground ml-1.5">
                    {plan.period}
                  </span>
                )}
              </div>

              <ul className="relative space-y-2.5 mb-8 flex-1">
                {plan.features.map((feature, fi) => (
                  <li
                    key={fi}
                    className="flex items-start gap-2 text-sm text-muted-foreground"
                  >
                    <Check className="h-4 w-4 text-violet-light flex-shrink-0 mt-0.5" />
                    <span>{feature}</span>
                  </li>
                ))}
              </ul>

              <Button
                asChild
                className={`relative w-full transition-all duration-300 ${
                  plan.highlight
                    ? "bg-violet-DEFAULT hover:bg-violet-deep shadow-md shadow-violet-DEFAULT/20 hover:shadow-violet-DEFAULT/30"
                    : "hover:border-violet-DEFAULT/30"
                }`}
                variant={plan.highlight ? "default" : "outline"}
              >
                <Link
                  href={APP_STORE_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  {plan.icon && <plan.icon className="h-4 w-4 mr-2" />}
                  {plan.cta}
                </Link>
              </Button>
            </motion.div>
          ))}
        </div>

        <p className="text-center text-sm text-muted-foreground/70 mt-10">
          {t("footnote")}
        </p>
      </div>
    </section>
  );
}
