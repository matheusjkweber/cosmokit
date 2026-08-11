// Landing page for the cosmokit CLI. Two jobs: give the free CLI somewhere to
// live so it is findable at all, and catch terminal-flavoured searches
// ("simctl wrapper", "ios simulator command line", "screenshot simulator CLI")
// that the app pages do not rank for. The CLI is free and open source, so this
// page sells nothing directly — it earns the install, and the app is the
// natural upgrade once someone is in the workflow.
import type { Metadata } from "next";
import Link from "next/link";
import { Check, ArrowRight, Terminal } from "lucide-react";
import {
  MarketingShell,
  PageHero,
  AppStoreButton,
} from "@/components/marketing/marketing";
import { CopyCommand } from "@/components/CopyCommand";

export const metadata: Metadata = {
  title: "cosmokit CLI | Drive the iOS Simulator from the command line",
  description:
    "Free, open source CLI for the iOS Simulator. Boot simulators, take screenshots, record video, set GPS coordinates and open deep links from a Makefile, a git hook or CI. Install with Homebrew.",
  alternates: {
    canonical: "https://usecosmoskittool.com/cli",
  },
};

const INSTALL_COMMAND = "brew install maththedev42/tap/cosmokit";
const REPO_URL = "https://github.com/maththedev42/cosmokit-cli";

const COMMANDS = [
  ["cosmokit list", "List available simulators"],
  ["cosmokit boot [name|udid]", "Boot a simulator"],
  ["cosmokit shutdown [name|udid]", "Shut a simulator down"],
  ["cosmokit capture [name|udid]", "Screenshot to a file"],
  ["cosmokit record [name|udid]", "Record video until Ctrl-C"],
  ["cosmokit location <lat> <lon>", "Set the simulator's GPS position"],
  ["cosmokit open <url>", "Open a deep link"],
  ["cosmokit erase [name|udid]", "Erase a simulator to a fresh install"],
];

const USES = [
  {
    title: "Screenshots in CI",
    body: "Capture every booted simulator into your repo as part of a build, so a broken layout shows up in the pull request rather than in review.",
    code: "cosmokit capture --output ./screenshots",
  },
  {
    title: "Deterministic location tests",
    body: "Put the simulator somewhere specific before the suite runs, instead of relying on whatever the last manual test left behind.",
    code: "cosmokit location -22.9068 -43.1729",
  },
  {
    title: "Deep links in a git hook",
    body: "Exercise a deep link on every commit so a malformed route is caught before it reaches anyone else.",
    code: 'cosmokit open "myapp://item/42"',
  },
  {
    title: "A clean device every run",
    body: "Erase and boot from a known state so a passing run means the same thing today as it did last week.",
    code: 'cosmokit erase "iPhone 16" && cosmokit boot "iPhone 16"',
  },
];

const FACTS = [
  "Free and open source under the MIT license",
  "Universal binary, Apple silicon and Intel",
  "No account, no telemetry, no CosmoKit Pro required",
  "Shells out to xcrun simctl, so it works with the Xcode you already have",
  "Exits non-zero on failure, so it is safe under set -e",
  "Does not require the CosmoKit app to be installed",
];

export default function CliPage() {
  return (
    <MarketingShell>
      <PageHero
        eyebrow="Free command line tool"
        title="Drive the iOS Simulator from"
        highlight="the command line"
        subtitle="cosmokit brings the simulator actions from the CosmoKit app to your Makefiles, git hooks and CI jobs. Free, open source, and it works whether or not you use the app."
      />

      <section className="container mx-auto px-4 pb-16">
        <div className="max-w-2xl mx-auto">
          <CopyCommand command={INSTALL_COMMAND} />
          <p className="mt-3 text-center text-xs text-muted-foreground/70">
            Requires macOS 13+ and Xcode&apos;s command line tools.{" "}
            <Link
              href={REPO_URL}
              className="underline underline-offset-4 hover:text-violet-light transition-colors"
            >
              Source on GitHub
            </Link>
            .
          </p>
        </div>
      </section>

      <section className="container mx-auto px-4 pb-16">
        <div className="max-w-3xl mx-auto rounded-2xl border border-border/60 bg-card/40 p-8">
          <div className="flex items-center gap-2.5 mb-6">
            <Terminal className="h-5 w-5 text-violet-light" />
            <h2 className="text-2xl font-bold">Commands</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-sm border-collapse">
              <tbody>
                {COMMANDS.map(([cmd, desc]) => (
                  <tr key={cmd} className="border-b border-border/40 last:border-0">
                    <td className="py-2.5 pr-6 font-mono text-xs whitespace-nowrap text-violet-light">
                      {cmd}
                    </td>
                    <td className="py-2.5 text-muted-foreground">{desc}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="mt-5 text-xs text-muted-foreground/70">
            Device arguments accept a UDID, an exact name or a partial name.
            Omit them to use the booted simulator. <code>--output</code> sets
            the directory for <code>capture</code> and <code>record</code>.
          </p>
        </div>
      </section>

      <section className="container mx-auto px-4 pb-16">
        <h2 className="text-2xl font-bold mb-6 text-center">
          What people use it for
        </h2>
        <div className="grid gap-5 md:grid-cols-2 max-w-4xl mx-auto">
          {USES.map((use) => (
            <div
              key={use.title}
              className="rounded-2xl border border-border/60 bg-card/40 p-6"
            >
              <h3 className="text-lg font-semibold mb-2">{use.title}</h3>
              <p className="text-sm text-muted-foreground mb-4">{use.body}</p>
              <pre className="overflow-x-auto rounded-lg bg-background/60 border border-border/40 px-3 py-2.5 text-xs font-mono text-violet-light">
                <code>{use.code}</code>
              </pre>
            </div>
          ))}
        </div>
      </section>

      <section className="container mx-auto px-4 pb-16">
        <div className="max-w-3xl mx-auto rounded-2xl border border-border/60 bg-card/40 p-8">
          <h2 className="text-2xl font-bold mb-6 text-center">Good to know</h2>
          <ul className="space-y-3">
            {FACTS.map((fact) => (
              <li key={fact} className="flex items-start gap-3 text-sm">
                <Check className="h-4 w-4 mt-0.5 shrink-0 text-violet-light" />
                <span>{fact}</span>
              </li>
            ))}
          </ul>
        </div>
      </section>

      <section className="container mx-auto px-4 pb-24 text-center">
        <h2 className="text-2xl font-bold mb-3">
          The app picks up where the CLI stops
        </h2>
        <p className="text-muted-foreground mb-6 max-w-xl mx-auto">
          The CLI covers what plain <code>simctl</code> can do. The CosmoKit app
          adds the network proxy, App Store screenshot generator, device frames,
          saved push payloads and Dev Presets, with a free tier to start.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-3">
          <AppStoreButton />
          <Link
            href="/features/"
            className="inline-flex items-center gap-2 rounded-xl border border-border/60 hover:border-violet-DEFAULT/30 hover:bg-violet-glow transition-colors px-5 py-2.5 text-sm font-medium"
          >
            See what the app adds <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </section>
    </MarketingShell>
  );
}
