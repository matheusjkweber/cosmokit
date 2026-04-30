"use client";

import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { useState, useEffect } from "react";
import { Menu, X, Download, Globe } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslations, useLocale } from "@/lib/i18n";
import { usePathname, useRouter } from "next/navigation";

const APP_STORE_URL =
  "https://apps.apple.com/br/app/cosmokit-tools/id6756494471?mt=12";

const locales = [
  { code: "en", label: "English", flag: "🇺🇸" },
  { code: "pt-BR", label: "Português", flag: "🇧🇷" },
  { code: "es", label: "Español", flag: "🇪🇸" },
];

export function Navbar() {
  const t = useTranslations("Navbar");
  const locale = useLocale();
  const pathname = usePathname();
  const router = useRouter();
  const [isOpen, setIsOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const [langOpen, setLangOpen] = useState(false);

  const navLinks = [
    { name: t("features"), href: "#features" },
    { name: t("screenshots"), href: "#gallery" },
    { name: t("pricing"), href: "#pricing" },
    { name: t("faq"), href: "#faq" },
  ];

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const switchLocale = (newLocale: string) => {
    const pathWithoutLocale = pathname.replace(/^\/(en|pt-BR|es)/, "") || "/";
    router.push(`/${newLocale}${pathWithoutLocale}`);
    setLangOpen(false);
  };

  const currentLocale = locales.find((l) => l.code === locale);

  return (
    <motion.nav
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
      className={`fixed w-full z-50 transition-all duration-500 ${
        scrolled
          ? "bg-background/70 backdrop-blur-2xl border-b border-violet-deep/10 shadow-lg shadow-violet-deep/5"
          : "bg-transparent"
      }`}
    >
      <div className="container mx-auto flex items-center justify-between h-16 px-4">
        <Link href={`/${locale}`} className="flex items-center gap-2.5 group">
          <Image
            src="/icon.png"
            alt="CosmoKit"
            width={32}
            height={32}
            className="rounded-lg transition-transform duration-300 group-hover:scale-110"
          />
          <span className="text-lg font-semibold text-foreground tracking-tight">
            CosmoKit
          </span>
        </Link>

        <div className="hidden md:flex items-center gap-1">
          {navLinks.map((link) => (
            <Link
              key={link.name}
              href={link.href}
              className="text-sm text-muted-foreground hover:text-foreground transition-colors duration-200 px-3 py-2 rounded-lg hover:bg-violet-glow"
            >
              {link.name}
            </Link>
          ))}

          {/* Language switcher */}
          <div className="relative ml-1">
            <button
              onClick={() => setLangOpen(!langOpen)}
              className="flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors duration-200 px-3 py-2 rounded-lg hover:bg-violet-glow"
              aria-label="Switch language"
            >
              <Globe className="h-3.5 w-3.5" />
              <span>{currentLocale?.flag}</span>
            </button>
            <AnimatePresence>
              {langOpen && (
                <motion.div
                  initial={{ opacity: 0, y: -4, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: -4, scale: 0.95 }}
                  transition={{ duration: 0.15 }}
                  className="absolute right-0 top-full mt-1 bg-background/95 backdrop-blur-xl border border-border/60 rounded-xl shadow-xl shadow-black/20 py-1 min-w-[140px] overflow-hidden"
                >
                  {locales.map((l) => (
                    <button
                      key={l.code}
                      onClick={() => switchLocale(l.code)}
                      className={`w-full flex items-center gap-2.5 px-3 py-2 text-sm transition-colors ${
                        l.code === locale
                          ? "text-violet-light bg-violet-DEFAULT/10"
                          : "text-muted-foreground hover:text-foreground hover:bg-violet-glow"
                      }`}
                    >
                      <span>{l.flag}</span>
                      <span>{l.label}</span>
                    </button>
                  ))}
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          <div className="ml-2">
            <Button
              asChild
              size="sm"
              className="gap-2 bg-violet-DEFAULT hover:bg-violet-deep transition-all duration-300 shadow-md shadow-violet-DEFAULT/20 hover:shadow-violet-DEFAULT/30"
            >
              <Link
                href={APP_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
              >
                <Download className="h-3.5 w-3.5" />
                {t("download")}
              </Link>
            </Button>
          </div>
        </div>

        <Button
          variant="ghost"
          size="icon"
          className="md:hidden"
          onClick={() => setIsOpen(!isOpen)}
          aria-label="Toggle navigation menu"
        >
          {isOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </Button>
      </div>

      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.25, ease: "easeInOut" }}
            className="md:hidden overflow-hidden bg-background/95 backdrop-blur-2xl border-b border-border"
          >
            <div className="container mx-auto px-4 py-4 flex flex-col gap-1">
              {navLinks.map((link) => (
                <Link
                  key={link.name}
                  href={link.href}
                  className="text-sm text-muted-foreground hover:text-foreground transition-colors py-2.5 px-3 rounded-lg hover:bg-violet-glow"
                  onClick={() => setIsOpen(false)}
                >
                  {link.name}
                </Link>
              ))}

              {/* Mobile language switcher */}
              <div className="flex gap-2 px-3 py-2">
                {locales.map((l) => (
                  <button
                    key={l.code}
                    onClick={() => {
                      switchLocale(l.code);
                      setIsOpen(false);
                    }}
                    className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm transition-colors ${
                      l.code === locale
                        ? "bg-violet-DEFAULT/10 text-violet-light border border-violet-DEFAULT/20"
                        : "text-muted-foreground hover:text-foreground hover:bg-violet-glow"
                    }`}
                  >
                    <span>{l.flag}</span>
                    <span>{l.label}</span>
                  </button>
                ))}
              </div>

              <div className="pt-2">
                <Button
                  asChild
                  size="sm"
                  className="w-full gap-2 bg-violet-DEFAULT hover:bg-violet-deep"
                >
                  <Link
                    href={APP_STORE_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    onClick={() => setIsOpen(false)}
                  >
                    <Download className="h-3.5 w-3.5" />
                    {t("ctaDownload" as "download")}
                  </Link>
                </Button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.nav>
  );
}
