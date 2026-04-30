import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

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
  title: "CosmoKit — Simulator Testing Made Easy",
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
    title: "CosmoKit — Simulator Testing Made Easy",
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
    title: "CosmoKit — Simulator Testing Made Easy",
    description:
      "The ultimate macOS companion for iOS developers. Control your simulator workflow with powerful tools.",
    images: ["/screenshots/macos-2.png"],
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
        {children}
      </body>
    </html>
  );
}
