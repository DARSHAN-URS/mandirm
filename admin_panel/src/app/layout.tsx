import type { Metadata, Viewport } from 'next';
import './globals.css';
import AdminLayoutShell from '@/components/layout/AdminLayoutShell';

export const metadata: Metadata = {
  title: 'Mandirm — Unified Admin & Operations Console',
  description: 'Control center for Temples, Puja Bookings, Chadhawa, Astrologers, WhatsApp Chat Moderation, and Commerce.',
  icons: {
    icon: '/images/inner_logo_clean.png',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50 text-gray-900 font-sans antialiased min-h-screen">
        <AdminLayoutShell>{children}</AdminLayoutShell>
      </body>
    </html>
  );
}

