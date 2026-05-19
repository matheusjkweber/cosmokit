"use client";

import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";
import { useState, useCallback, useEffect } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useTranslations } from "@/lib/i18n";

export function ScreenshotsGallery() {
  const t = useTranslations("Gallery");
  
  const screenshots = [
    { src: t("images.workspace"), key: "workspace" },
    { src: t("images.location"), key: "location" },
    { src: t("images.tools"), key: "tools" },
    { src: t("images.push"), key: "push" },
    { src: t("images.proxy"), key: "proxy" },
    { src: t("images.more"), key: "more" },
  ];

  const [activeIndex, setActiveIndex] = useState(0);

  const navigate = useCallback(
    (direction: "prev" | "next") => {
      setActiveIndex((prev) => {
        if (direction === "prev") return Math.max(0, prev - 1);
        return Math.min(screenshots.length - 1, prev + 1);
      });
    },
    []
  );

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowLeft") navigate("prev");
      if (e.key === "ArrowRight") navigate("next");
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [navigate]);

  return (
    <section id="gallery" className="py-24 md:py-32 relative overflow-hidden">
      {/* Background accent */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[500px] bg-violet-DEFAULT/[0.04] rounded-full blur-[150px]" />

      <div className="container mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="text-center mb-12 md:mb-16"
        >
          <p className="text-sm font-medium text-violet-light tracking-wider uppercase mb-3">
            {t("label")}
          </p>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-foreground mb-4">
            {t("title")}
          </h2>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            {t("subtitle")}
          </p>
        </motion.div>

        {/* Main image — fixed aspect ratio container */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.1 }}
          transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
          className="relative max-w-4xl mx-auto mb-6"
        >
          <div className="relative rounded-2xl overflow-hidden border border-violet-DEFAULT/10 shadow-2xl shadow-violet-deep/10 bg-[#0c0814] aspect-[16/10]">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeIndex}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.3 }}
                className="absolute inset-0 flex items-center justify-center p-4"
              >
                <Image
                  src={screenshots[activeIndex].src}
                  alt={t(`items.${screenshots[activeIndex].key}`)}
                  width={1400}
                  height={875}
                  className="max-w-full max-h-full w-auto h-auto object-contain rounded-lg"
                />
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Navigation arrows */}
          <div className="absolute inset-y-0 left-0 flex items-center z-10">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate("prev")}
              disabled={activeIndex === 0}
              className="ml-3 bg-background/60 backdrop-blur-md hover:bg-background/80 disabled:opacity-20 border border-border/50 h-10 w-10 rounded-xl"
              aria-label="Previous"
            >
              <ChevronLeft className="h-5 w-5" />
            </Button>
          </div>
          <div className="absolute inset-y-0 right-0 flex items-center z-10">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate("next")}
              disabled={activeIndex === screenshots.length - 1}
              className="mr-3 bg-background/60 backdrop-blur-md hover:bg-background/80 disabled:opacity-20 border border-border/50 h-10 w-10 rounded-xl"
              aria-label="Next"
            >
              <ChevronRight className="h-5 w-5" />
            </Button>
          </div>

          {/* Glow beneath */}
          <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 w-2/3 h-16 bg-violet-DEFAULT/8 rounded-full blur-3xl" />
        </motion.div>

        {/* Thumbnails */}
        <div className="max-w-4xl mx-auto">
          <div className="flex gap-2 overflow-x-auto pb-2 px-1 snap-x snap-mandatory scrollbar-hide justify-center flex-wrap">
            {screenshots.map((shot, i) => (
              <button
                key={i}
                onClick={() => setActiveIndex(i)}
                className={`flex-shrink-0 snap-center rounded-lg overflow-hidden border-2 transition-all duration-300 bg-[#0c0814] ${
                  i === activeIndex
                    ? "border-violet-DEFAULT shadow-md shadow-violet-DEFAULT/20 scale-105"
                    : "border-transparent opacity-40 hover:opacity-70"
                }`}
                aria-label={t(`items.${shot.key}`)}
              >
                <Image
                  src={shot.src}
                  alt={t(`items.${shot.key}`)}
                  width={120}
                  height={75}
                  className="w-20 sm:w-24 h-auto"
                />
              </button>
            ))}
          </div>
        </div>

        {/* Caption */}
        <motion.p
          key={activeIndex}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center text-sm text-muted-foreground mt-4"
        >
          {t(`items.${screenshots[activeIndex].key}`)}
        </motion.p>
      </div>
    </section>
  );
}
