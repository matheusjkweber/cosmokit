"use client";

import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col">
      <Navbar />
      <main className="flex-grow container mx-auto px-4 py-20">
        <h1 className="text-5xl font-bold text-foreground mb-8 text-center">Terms of Service</h1>
        <div className="prose prose-invert lg:prose-xl mx-auto text-muted-foreground">
          <p>Last updated: March 23, 2026</p>
          <h2>1. Introduction</h2>
          <p>Welcome to CosmoKit. These Terms of Service (&quot;Terms&quot;) govern your access to and use of the CosmoKit website, products, and services (&quot;Services&quot;). Please read these Terms carefully before using our Services.</p>
          <h2>2. Acceptance of Terms</h2>
          <p>By accessing or using our Services, you agree to be bound by these Terms and by our Privacy Policy. If you do not agree to these Terms, do not use our Services.</p>
          <h2>3. Changes to Terms</h2>
          <p>We may modify these Terms at any time, in our sole discretion. If we do so, we will let you know either by posting the modified Terms on the Site or through other communications. It's important that you review the Terms whenever we modify them because if you continue to use the Services after we have posted modified Terms on the Site, you are indicating to us that you agree to be bound by the modified Terms. If you don't agree to be bound by the modified Terms, then you may not use the Services anymore.</p>
          <h2>4. Your Responsibilities</h2>
          <p>You agree not to use the Services for any unlawful purpose or any purpose prohibited by these Terms. You agree not to use the Services in any way that could damage, disable, overburden, or impair the Services or interfere with any other party's use and enjoyment of the Services.</p>
          <h2>5. Intellectual Property</h2>
          <p>All intellectual property rights in the Services and its content (excluding content provided by users) are owned by CosmoKit or its licensors. You may not use any of our intellectual property without our prior written consent.</p>
          <h2>6. Termination</h2>
          <p>We may terminate your access to and use of the Services, at our sole discretion, at any time and without notice to you.</p>
          <h2>7. Disclaimer of Warranties</h2>
          <p>The Services are provided &quot;as is,&quot; without warranty of any kind, either express or implied. Without limiting the foregoing, we explicitly disclaim any warranties of merchantability, fitness for a particular purpose, non-infringement, and any warranties arising out of course of dealing or usage of trade.</p>
          <h2>8. Limitation of Liability</h2>
          <p>To the maximum extent permitted by law, CosmoKit shall not be liable for any indirect, incidental, special, consequential or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from (a) your access to or use of or inability to access or use the Services; (b) any conduct or content of any third party on the Services; or (c) unauthorized access, use or alteration of your transmissions or content.</p>
          <h2>9. Governing Law</h2>
          <p>These Terms shall be governed by the laws of the country where CosmoKit is headquartered, without regard to its conflict of law provisions.</p>
          <h2>10. Contact Information</h2>
          <p>If you have any questions about these Terms, please contact us at <a href="mailto:contato@usecosmoskittool.com" className="text-violet-light hover:underline">contato@usecosmoskittool.com</a>.</p>
        </div>
      </main>
      <Footer />
    </div>
  );
}
