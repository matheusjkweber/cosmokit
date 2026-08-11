import type { Metadata } from "next";
import { FeaturePage } from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Push Notifications Testing | CosmoKit",
  description:
    "Send fully custom push notification payloads to the iOS Simulator to test deep links, badges and notification UI, without a backend or a physical device.",
  alternates: { canonical: "https://usecosmoskittool.com/push" },
};

export default function PushPage() {
  return <FeaturePage featureId="push" />;
}
