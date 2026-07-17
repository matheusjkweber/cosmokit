import type { Metadata } from "next";
import { FeaturePage } from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Network Proxy & Inspection | CosmoKit",
  description:
    "Route your iOS Simulator through CosmoKit's built-in proxy to inspect HTTPS traffic, debug API calls and test offline and slow-network behaviour.",
  alternates: { canonical: "https://usecosmoskittool.com/network" },
};

export default function NetworkPage() {
  return <FeaturePage featureId="network" />;
}
