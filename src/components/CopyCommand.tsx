"use client";

// A shell command the visitor is meant to run, with one-click copy.
//
// The command stays visible and selectable rather than hiding behind the
// button: clipboard writes are blocked in some in-app browsers (this site gets
// a lot of Facebook webview traffic), and a command you cannot read is worse
// than one you have to select by hand.
import { useState } from "react";
import { Check, Copy } from "lucide-react";

type PostHogClient = {
  capture: (event: string, properties?: Record<string, unknown>) => void;
};

function posthog(): PostHogClient | null {
  if (typeof window === "undefined") return null;
  const w = window as unknown as { posthog?: PostHogClient };
  return typeof w.posthog?.capture === "function" ? w.posthog : null;
}

export function CopyCommand({ command }: { command: string }) {
  const [copied, setCopied] = useState(false);

  const onCopy = async () => {
    try {
      await navigator.clipboard.writeText(command);
      setCopied(true);
      window.setTimeout(() => setCopied(false), 2500);
    } catch {
      window.prompt("Copy this command", command);
    }
    posthog()?.capture("cli_install_command_copied", {
      surface: "landing",
      path: window.location.pathname,
    });
  };

  return (
    <div className="flex items-stretch gap-2 rounded-xl border border-border/60 bg-card/40 p-2">
      <code className="flex-1 overflow-x-auto whitespace-nowrap px-3 py-2.5 font-mono text-sm text-violet-light">
        {command}
      </code>
      <button
        type="button"
        onClick={onCopy}
        aria-label="Copy install command"
        className="inline-flex shrink-0 items-center gap-2 rounded-lg bg-violet-DEFAULT px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-violet-deep"
      >
        {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
        <span className="hidden sm:inline">{copied ? "Copied" : "Copy"}</span>
      </button>
    </div>
  );
}
