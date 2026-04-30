"use client";

import { Navbar } from "@/components/Navbar";
import { Hero } from "@/components/Hero";
import { Features } from "@/components/Features";
import { ScreenshotsGallery } from "@/components/ScreenshotsGallery";
import { Pricing } from "@/components/Pricing";
import { PlatformDownloads } from "@/components/PlatformDownloads";
import { FAQ } from "@/components/FAQ";
import { Footer } from "@/components/Footer";

function SectionDivider() {
  return <div className="section-divider max-w-5xl mx-auto" />;
}

export default function Home() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <Navbar />
      <main>
        <Hero />
        <SectionDivider />
        <Features />
        <SectionDivider />
        <ScreenshotsGallery />
        <SectionDivider />
        <Pricing />
        <SectionDivider />
        <PlatformDownloads />
        <SectionDivider />
        <FAQ />
      </main>
      <Footer />
    </div>
  );
}
