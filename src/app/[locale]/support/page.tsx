"use client";

import { useState } from "react";
import Link from "next/link";
import { Mail, MessageSquare, Sparkles, Send, CheckCircle2, AlertCircle, Loader2 } from "lucide-react";
import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useTranslations, useLocale } from "@/lib/i18n";
import { postJSON } from "@/lib/api";

type Status =
  | { kind: "idle" }
  | { kind: "submitting" }
  | { kind: "success" }
  | { kind: "error"; message: string };

export default function SupportPage() {
  const t = useTranslations("Support");
  const locale = useLocale();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [status, setStatus] = useState<Status>({ kind: "idle" });

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus({ kind: "submitting" });
    const result = await postJSON("/v1/contact", {
      name,
      email,
      subject,
      message,
    });
    if (result.ok) {
      setStatus({ kind: "success" });
      setName("");
      setEmail("");
      setSubject("");
      setMessage("");
    } else {
      setStatus({ kind: "error", message: result.error });
    }
  }

  const submitting = status.kind === "submitting";

  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col">
      <Navbar />
      <main className="flex-grow container mx-auto px-4 pt-32 pb-20 max-w-3xl">
        <div className="text-center mb-12">
          <p className="text-sm font-medium text-violet-light tracking-wider uppercase mb-3">
            {t("label")}
          </p>
          <h1 className="text-4xl sm:text-5xl font-bold text-foreground mb-4">
            {t("title")}
          </h1>
          <p className="text-lg text-muted-foreground max-w-xl mx-auto">
            {t("subtitle")}
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-12">
          <a
            href="mailto:contato@usecosmoskittool.com"
            className="rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-5 hover:border-violet-DEFAULT/30 transition-colors group"
          >
            <Mail className="h-5 w-5 text-violet-light mb-3" />
            <h3 className="text-sm font-semibold text-foreground mb-1">
              {t("emailCardTitle")}
            </h3>
            <p className="text-sm text-muted-foreground group-hover:text-violet-light transition-colors">
              contato@usecosmoskittool.com
            </p>
          </a>
          <Link
            href={`/${locale}/suggest`}
            className="rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-5 hover:border-violet-DEFAULT/30 transition-colors group"
          >
            <Sparkles className="h-5 w-5 text-violet-light mb-3" />
            <h3 className="text-sm font-semibold text-foreground mb-1">
              {t("suggestCardTitle")}
            </h3>
            <p className="text-sm text-muted-foreground group-hover:text-violet-light transition-colors">
              {t("suggestCardDescription")}
            </p>
          </Link>
        </div>

        <section className="rounded-2xl border border-border/60 bg-card/40 backdrop-blur-sm p-6 sm:p-8">
          <div className="flex items-center gap-2 mb-6">
            <MessageSquare className="h-5 w-5 text-violet-light" />
            <h2 className="text-xl font-semibold text-foreground">
              {t("formTitle")}
            </h2>
          </div>

          {status.kind === "success" ? (
            <div className="flex items-start gap-3 rounded-lg border border-emerald-500/30 bg-emerald-500/10 p-4">
              <CheckCircle2 className="h-5 w-5 text-emerald-400 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-foreground">
                  {t("successTitle")}
                </p>
                <p className="text-sm text-muted-foreground mt-1">
                  {t("successBody")}
                </p>
                <button
                  type="button"
                  onClick={() => setStatus({ kind: "idle" })}
                  className="text-sm text-violet-light hover:underline mt-2"
                >
                  {t("successAgain")}
                </button>
              </div>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <Field label={t("nameLabel")} htmlFor="name">
                  <Input
                    id="name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder={t("namePlaceholder")}
                    required
                    maxLength={120}
                    disabled={submitting}
                  />
                </Field>
                <Field label={t("emailLabel")} htmlFor="email">
                  <Input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder={t("emailPlaceholder")}
                    required
                    disabled={submitting}
                  />
                </Field>
              </div>
              <Field label={t("subjectLabel")} htmlFor="subject">
                <Input
                  id="subject"
                  value={subject}
                  onChange={(e) => setSubject(e.target.value)}
                  placeholder={t("subjectPlaceholder")}
                  required
                  maxLength={200}
                  disabled={submitting}
                />
              </Field>
              <Field label={t("messageLabel")} htmlFor="message">
                <textarea
                  id="message"
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder={t("messagePlaceholder")}
                  required
                  maxLength={8000}
                  disabled={submitting}
                  rows={6}
                  className="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 resize-y"
                />
              </Field>

              {status.kind === "error" && (
                <div className="flex items-start gap-2 rounded-lg border border-red-500/30 bg-red-500/10 p-3">
                  <AlertCircle className="h-4 w-4 text-red-400 flex-shrink-0 mt-0.5" />
                  <p className="text-sm text-red-200">{status.message}</p>
                </div>
              )}

              <Button
                type="submit"
                disabled={submitting}
                className="w-full sm:w-auto gap-2 bg-violet-DEFAULT hover:bg-violet-deep"
              >
                {submitting ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    {t("sending")}
                  </>
                ) : (
                  <>
                    <Send className="h-4 w-4" />
                    {t("submit")}
                  </>
                )}
              </Button>
            </form>
          )}
        </section>
      </main>
      <Footer />
    </div>
  );
}

function Field({
  label,
  htmlFor,
  children,
}: {
  label: string;
  htmlFor: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-1.5">
      <label
        htmlFor={htmlFor}
        className="block text-sm font-medium text-foreground/90"
      >
        {label}
      </label>
      {children}
    </div>
  );
}
