"use client";

import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col">
      <Navbar />
      <main className="flex-grow container mx-auto px-4 py-20">
        <h1 className="text-5xl font-bold text-foreground mb-8 text-center">Privacy Policy</h1>
        <div className="prose prose-invert lg:prose-xl mx-auto text-muted-foreground">
          <p>Last updated: July 17, 2026</p>
          <h2>1. Introduction</h2>
          <p>Welcome to CosmoKit. We respect your privacy and are committed to protecting your personal data. This privacy policy covers both the CosmoKit macOS app and this website, and tells you about your privacy rights and how the law protects you.</p>
          <h2>2. Data Collected by the CosmoKit App</h2>
          <p>The CosmoKit app collects a limited amount of data to help us understand how the app is used, keep it stable, and manage subscriptions:</p>
          <ul>
            <li><b>Usage Analytics</b> (via PostHog): anonymous events about which features are used (for example, opening a tool or completing a capture), app version, macOS version, and a pseudonymous installation identifier. This data is not linked to your name or email.</li>
            <li><b>Diagnostics</b> (via Sentry): crash reports and error diagnostics, including device model, macOS version, and the state of the app at the time of the error.</li>
            <li><b>Purchase Data</b> (via RevenueCat and Apple): subscription status and a pseudonymous app user identifier used to validate your CosmoKit Pro entitlement. All payments are processed by Apple; we never see or store your payment details.</li>
          </ul>
          <h2>3. What Stays on Your Mac</h2>
          <p>Everything you create or capture with CosmoKit stays local to your Mac. Screenshots, recordings, simulator content, network traffic inspected through the proxy, and your saved entries (deep links, push payloads, locations, routes and overrides) are never uploaded to us or to any third party by the app.</p>
          <h2>4. Data Collected by This Website</h2>
          <p>When you visit this website we may collect:</p>
          <ul>
            <li><b>Technical Data</b> includes internet protocol (IP) address, browser type and version, time zone setting and location, browser plug-in types and versions, operating system and platform and other technology on the devices you use to access this website.</li>
            <li><b>Usage Data</b> includes information about how you use our website.</li>
            <li><b>Contact Data</b> includes your email address, if you contact us through the support form.</li>
          </ul>
          <h2>5. How We Use Your Data</h2>
          <p>We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:</p>
          <ul>
            <li>To provide and improve the app: understanding which features matter, fixing crashes, and prioritizing development.</li>
            <li>To manage your subscription and validate CosmoKit Pro access.</li>
            <li>Where we need to comply with a legal or regulatory obligation.</li>
          </ul>
          <h2>6. Data Security</h2>
          <p>We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorised way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know. They will only process your personal data on our instructions and they are subject to a duty of confidentiality.</p>
          <h2>7. Your Legal Rights</h2>
          <p>Under certain circumstances, you have rights under data protection laws in relation to your personal data. These include the right to:</p>
          <ul>
            <li>Request access to your personal data.</li>
            <li>Request correction of your personal data.</li>
            <li>Request erasure of your personal data.</li>
            <li>Object to processing of your personal data.</li>
            <li>Request restriction of processing your personal data.</li>
            <li>Request transfer of your personal data.</li>
            <li>Withdraw consent at any time.</li>
          </ul>
          <p>If you wish to exercise any of the rights set out above, please contact us at <a href="mailto:contato@usecosmoskittool.com" className="text-violet-light hover:underline">contato@usecosmoskittool.com</a>.</p>
          <h2>8. Contact</h2>
          <p>For any questions about this privacy policy, please contact us at <a href="mailto:contato@usecosmoskittool.com" className="text-violet-light hover:underline">contato@usecosmoskittool.com</a>.</p>
        </div>
      </main>
      <Footer />
    </div>
  );
}
