import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { GoogleAds } from "@/components/analytics/GoogleAds";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-sans",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://usecosmoskittool.com"),
  title: "CosmoKit | Simulator Testing Made Easy",
  description:
    "The ultimate macOS companion for iOS developers. Take full control of your simulator workflow with screenshot capture, video recording, push notifications, deep links, GPS simulation, network proxy, and more.",
  keywords: [
    "iOS Simulator",
    "macOS",
    "developer tools",
    "Xcode",
    "simulator management",
    "screenshot",
    "video recording",
    "push notifications",
    "deep links",
    "GPS simulation",
    "network proxy",
    "xcrun simctl",
  ],
  authors: [{ name: "CosmoHQ" }],
  openGraph: {
    title: "CosmoKit | Simulator Testing Made Easy",
    description:
      "The ultimate macOS companion for iOS developers. Control your simulator workflow with powerful tools.",
    type: "website",
    locale: "en_US",
    siteName: "CosmoKit",
    images: [
      {
        url: "/screenshots/macos-2.png",
        width: 1200,
        height: 750,
        alt: "CosmoKit App Screenshot",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "CosmoKit | Simulator Testing Made Easy",
    description:
      "The ultimate macOS companion for iOS developers. Control your simulator workflow with powerful tools.",
    images: ["/screenshots/macos-2.png"],
  },
};

const appJsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "CosmoKit Tools",
  operatingSystem: "macOS 14.7 or later",
  applicationCategory: "DeveloperApplication",
  description:
    "Native macOS toolkit for the iOS Simulator: screenshots, video recording, push notifications, deep links, GPS simulation and network proxy.",
  url: "https://usecosmoskittool.com",
  downloadUrl:
    "https://apps.apple.com/br/app/cosmokit-tools/id6756494471?mt=12",
  image: "https://usecosmoskittool.com/screenshots/macos-1.png",
  author: { "@type": "Organization", name: "CosmoHQ" },
  offers: {
    "@type": "AggregateOffer",
    lowPrice: "0",
    highPrice: "69.99",
    priceCurrency: "USD",
    offerCount: 4,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html className="dark">
      <body className={`${inter.variable} ${jetbrainsMono.variable} font-sans`}>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(appJsonLd) }}
        />
        <GoogleAds />
        {children}
      </body>
    </html>
  );
}
