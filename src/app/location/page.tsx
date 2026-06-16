import type { Metadata } from "next";
import { FeaturePage } from "@/components/marketing/marketing";

export const metadata: Metadata = {
  title: "Location & GPS Simulation — CosmoKit",
  description:
    "Set any GPS coordinate or simulate movement on the iOS Simulator to test maps, geofencing and location-aware features without leaving your desk.",
  alternates: { canonical: "https://usecosmoskittool.com/location" },
};

export default function LocationPage() {
  return <FeaturePage featureId="location" />;
}
