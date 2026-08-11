"use client";

import { useEffect } from "react";

export default function RootPage() {
  useEffect(() => {
    // Detect browser language and redirect
    const lang = navigator.language;
    if (lang.startsWith("pt")) {
      window.location.replace("/pt-BR/");
    } else if (lang.startsWith("es")) {
      window.location.replace("/es/");
    } else {
      window.location.replace("/en/");
    }
  }, []);

  // Crawlable fallback: search engines (and no-JS visitors) land here, so give
  // them real content and links instead of a blank page while the JS redirect
  // does its job for everyone else.
  return (
    <main className="min-h-screen bg-background text-foreground flex flex-col items-center justify-center gap-6 px-4 text-center">
      <h1 className="text-3xl font-bold">CosmoKit | iOS Simulator Toolkit for Mac</h1>
      <p className="max-w-xl text-muted-foreground">
        Control the iOS Simulator from one native Mac app: screenshots, video
        recording, push notifications, deep links, GPS simulation and network
        proxy.
      </p>
      <nav className="flex gap-6 text-violet-light">
        <a href="/en/" className="hover:underline">English</a>
        <a href="/pt-BR/" className="hover:underline">Português</a>
        <a href="/es/" className="hover:underline">Español</a>
      </nav>
    </main>
  );
}
