import type { Metadata } from "next";
import { FeaturePage } from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Screen Capture & Recording | CosmoKit",
  description:
    "Capture high-resolution screenshots and record video of any iOS Simulator for QA, bug reports and App Store assets, straight from the macOS menu bar.",
  alternates: { canonical: "https://usecosmoskittool.com/capture" },
};

export default function CapturePage() {
  return <FeaturePage featureId="capture" />;
}
