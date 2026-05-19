"use client";

import { Card, CardContent } from "@/components/ui/card";
import { motion } from "framer-motion";

const stats = [
  { label: "Happy Users", value: "10,000+" },
  { label: "5-Star Reviews", value: "1,500+" },
  { label: "Features Shipped", value: "100+" },
];

const testimonials = [
  {
    quote: "CosmoKit has transformed my workflow. The AI tools are incredibly powerful and intuitive!",
    name: "Alice Johnson",
    title: "Product Designer",
  },
  {
    quote: "A must-have for anyone looking to boost productivity. The screen recorder is flawless.",
    name: "Bob Williams",
    title: "Software Engineer",
  },
  {
    quote: "I can't imagine working without CosmoKit now. It's truly a world-class application.",
    name: "Carol Davis",
    title: "Marketing Specialist",
  },
];

export function SocialProof() {
  return (
    <section id="social-proof" className="py-20 bg-background">
      <div className="container mx-auto px-4 text-center">
        <h2 className="text-4xl md:text-5xl font-bold text-foreground mb-4">
          Join Thousands of Happy Users
        </h2>
        <p className="text-lg text-muted-foreground mb-12 max-w-2xl mx-auto">
          See what our community loves about CosmoKit.
        </p>

        {/* Stats Counters */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
          {stats.map((stat, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              viewport={{ once: true, amount: 0.3 }}
            >
              <Card className="p-6 bg-card/60 backdrop-blur-lg border border-gray-800 shadow-md">
                <CardContent className="p-0">
                  <p className="text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-purple-600 mb-2">
                    {stat.value}
                  </p>
                  <p className="text-lg text-muted-foreground">{stat.label}</p>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </div>

        {/* Testimonials */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.15 }}
              viewport={{ once: true, amount: 0.3 }}
            >
              <Card className="h-full p-6 bg-card/60 backdrop-blur-lg border border-gray-800 shadow-md flex flex-col justify-between">
                <CardContent className="p-0 mb-6">
                  <p className="text-xl italic text-foreground leading-relaxed">
                    &ldquo;{testimonial.quote}&rdquo;
                  </p>
                </CardContent>
                <div className="text-left">
                  <p className="font-bold text-foreground">{testimonial.name}</p>
                  <p className="text-sm text-muted-foreground">{testimonial.title}</p>
                </div>
              </Card>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
