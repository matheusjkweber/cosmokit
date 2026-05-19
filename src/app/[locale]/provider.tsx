"use client";

import { useParams } from "next/navigation";
import { I18nProvider } from "@/lib/i18n";

export function LocaleProvider({ children }: { children: React.ReactNode }) {
  const params = useParams<{ locale: string }>();
  const locale = params.locale ?? "en";

  return <I18nProvider locale={locale}>{children}</I18nProvider>;
}
