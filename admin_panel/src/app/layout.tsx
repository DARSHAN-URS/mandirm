import type { Metadata } from 'next';
import './globals.css';
import AdminSidebar from '@/components/layout/AdminSidebar';
import AdminHeader from '@/components/layout/AdminHeader';

export const metadata: Metadata = {
  title: 'Mandirm — Unified Admin & Operations Console',
  description: 'Control center for Temples, Puja Bookings, Chadhawa, Astrologers, WhatsApp Chat Moderation, and Commerce.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50 flex min-h-screen text-gray-900 font-sans antialiased">
        {/* Persistent Side Navigation */}
        <AdminSidebar />

        {/* Main Content Area */}
        <div className="flex-1 flex flex-col min-w-0">
          <AdminHeader />
          <main className="flex-1 p-6 overflow-y-auto">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
