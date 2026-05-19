"use client";

import { createContext, useContext, type ReactNode } from "react";

import enMessages from "../../messages/en.json";
import ptBRMessages from "../../messages/pt-BR.json";
import esMessages from "../../messages/es.json";

type Messages = typeof enMessages;
type NestedKeyOf<T> = T extends object
  ? { [K in keyof T]: K extends string ? (T[K] extends object ? `${K}.${NestedKeyOf<T[K]>}` : K) : never }[keyof T]
  : never;

const allMessages: Record<string, Messages> = {
  en: enMessages,
  "pt-BR": ptBRMessages,
  es: esMessages,
};

export const locales = ["en", "pt-BR", "es"] as const;
export const defaultLocale = "en";

const I18nContext = createContext<{ locale: string; messages: Messages }>({
  locale: "en",
  messages: enMessages,
});

export function I18nProvider({ locale, children }: { locale: string; children: ReactNode }) {
  const messages = allMessages[locale] ?? enMessages;
  return <I18nContext.Provider value={{ locale, messages }}>{children}</I18nContext.Provider>;
}

function getNestedValue(obj: Record<string, unknown>, path: string): string {
  const parts = path.split(".");
  let current: unknown = obj;
  for (const part of parts) {
    if (current == null || typeof current !== "object") return path;
    current = (current as Record<string, unknown>)[part];
  }
  return typeof current === "string" ? current : path;
}

export function useTranslations(namespace: string) {
  const { messages } = useContext(I18nContext);
  const section = (messages as Record<string, unknown>)[namespace] ?? {};

  function t(key: string, values?: Record<string, string | number>): string {
    const raw = getNestedValue(section as Record<string, unknown>, key);
    if (!values) return raw;
    return Object.entries(values).reduce(
      (str, [k, v]) => str.replace(`{${k}}`, String(v)),
      raw
    );
  }

  t.rich = (key: string, components: Record<string, (chunks?: string) => ReactNode>): ReactNode => {
    const raw = getNestedValue(section as Record<string, unknown>, key);
    // Split on {componentName} patterns
    const parts: ReactNode[] = [];
    let remaining = raw;
    for (const [name, render] of Object.entries(components)) {
      const placeholder = `{${name}}`;
      if (remaining.includes(placeholder)) {
        const [before, after] = remaining.split(placeholder);
        if (before) parts.push(before);
        parts.push(render());
        remaining = after ?? "";
      }
    }
    if (remaining) parts.push(remaining);
    return parts.length === 1 ? parts[0] : parts;
  };

  return t;
}

export function useLocale(): string {
  const { locale } = useContext(I18nContext);
  return locale;
}
