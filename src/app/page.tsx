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

  return null;
}
