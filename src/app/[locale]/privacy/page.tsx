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
          <p>Last updated: March 23, 2026</p>
          <h2>1. Introduction</h2>
          <p>Welcome to CosmoKit. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our website (regardless of where you visit it from) and tell you about your privacy rights and how the law protects you.</p>
          <h2>2. Data We Collect</h2>
          <p>We may collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:</p>
          <ul>
            <li><b>Identity Data</b> includes first name, last name, username or similar identifier.</li>
            <li><b>Contact Data</b> includes billing address, delivery address, email address and telephone numbers.</li>
            <li><b>Technical Data</b> includes internet protocol (IP) address, your login data, browser type and version, time zone setting and location, browser plug-in types and versions, operating system and platform and other technology on the devices you use to access this website.</li>
            <li><b>Usage Data</b> includes information about how you use our website, products and services.</li>
          </ul>
          <h2>3. How We Use Your Data</h2>
          <p>We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:</p>
          <ul>
            <li>Where we need to perform the contract we are about to enter into or have entered into with you.</li>
            <li>Where it is necessary for our legitimate interests (or those of a third party) and your interests and fundamental rights do not override those interests.</li>
            <li>Where we need to comply with a legal or regulatory obligation.</li>
          </ul>
          <h2>4. Data Security</h2>
          <p>We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorised way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know. They will only process your personal data on our instructions and they are subject to a duty of confidentiality.</p>
          <h2>5. Your Legal Rights</h2>
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
          <h2>6. Contact</h2>
          <p>For any questions about this privacy policy, please contact us at <a href="mailto:contato@usecosmoskittool.com" className="text-violet-light hover:underline">contato@usecosmoskittool.com</a>.</p>
        </div>
      </main>
      <Footer />
    </div>
  );
}
