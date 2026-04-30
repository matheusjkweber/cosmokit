"use client";

import Image from "next/image";
import Link from "next/link";
import { Apple } from "lucide-react";
import { useTranslations } from "@/lib/i18n";

const APP_STORE_URL =
  "https://apps.apple.com/br/app/cosmokit-tools/id6756494471?mt=12";

export function Footer() {
  const t = useTranslations("Footer");
  const tNav = useTranslations("Navbar");
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-border/40 relative">
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[400px] h-[1px] bg-gradient-to-r from-transparent via-violet-DEFAULT/30 to-transparent" />

      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="md:col-span-2">
            <Link href="/" className="flex items-center gap-2.5 mb-3 group">
              <Image
                src="/icon.png"
                alt="CosmoKit"
                width={28}
                height={28}
                className="rounded-lg transition-transform duration-300 group-hover:scale-110"
              />
              <span className="text-base font-semibold text-foreground">
                CosmoKit
              </span>
            </Link>
            <p className="text-sm text-muted-foreground max-w-xs leading-relaxed mb-4">
              {t("description")}
            </p>
            <Link
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 text-xs text-muted-foreground/60 hover:text-violet-light transition-colors"
            >
              <Apple className="h-3 w-3" />
              {t("appStore")}
            </Link>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-sm font-semibold text-foreground mb-3">
              {t("product")}
            </h4>
            <ul className="space-y-2">
              <li>
                <Link
                  href="#features"
                  className="text-sm text-muted-foreground hover:text-violet-light transition-colors duration-200"
                >
                  {tNav("features")}
                </Link>
              </li>
              <li>
                <Link
                  href="#pricing"
                  className="text-sm text-muted-foreground hover:text-violet-light transition-colors duration-200"
                >
                  {tNav("pricing")}
                </Link>
              </li>
              <li>
                <Link
                  href="#faq"
                  className="text-sm text-muted-foreground hover:text-violet-light transition-colors duration-200"
                >
                  {tNav("faq")}
                </Link>
              </li>
              <li>
                <Link
                  href={APP_STORE_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm text-muted-foreground hover:text-violet-light transition-colors duration-200"
                >
                  {t("macAppStore")}
                </Link>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="text-sm font-semibold text-foreground mb-3">
              {t("legal")}
            </h4>
            <ul className="space-y-2">
              <li>
                <Link
                  href="/privacy"
                  className="text-sm text-muted-foreground hover:text-violet-light transition-colors duration-200"
                >
                  {t("privacy")}
                </Link>
              </li>
              <li>
                <Link
                  href="/terms"
                  className="text-sm text-muted-foreground hover:text-violet-light transition-colors duration-200"
                >
                  {t("terms")}
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-6 border-t border-border/30 flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-xs text-muted-foreground/50">
            {t("copyright", { year: currentYear })}
          </p>
          <p className="text-xs text-muted-foreground/50">
            {t("builtWith")}
          </p>
        </div>
      </div>
    </footer>
  );
}
