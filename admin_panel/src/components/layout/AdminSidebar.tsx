'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAdminAuth } from '@/components/auth/AdminAuthGuard';

interface NavItem {
  name: string;
  href: string;
  icon: string;
  badge?: string;
  badgeColor?: string;
}

const NAV_GROUPS: { group: string; items: NavItem[] }[] = [
  {
    group: 'CORE OVERVIEW',
    items: [
      { name: 'Dashboard', href: '/', icon: '📊' },
      { name: 'Financials & Dakshina', href: '/transactions', icon: '💳' },
    ],
  },
  {
    group: 'TEMPLE & RITUALS',
    items: [
      { name: 'Temples & Live Darshan', href: '/temples', icon: '🛕', badge: 'Live', badgeColor: 'bg-emerald-500 text-white' },
      { name: 'Puja Ceremonies', href: '/puja-services', icon: '🪔' },
      { name: 'Bookings & Sankalps', href: '/bookings', icon: '📜', badge: 'Queue', badgeColor: 'bg-amber-500 text-white' },
      { name: 'Chadhawa Offerings', href: '/chadhawa', icon: '🌸' },
    ],
  },
  {
    group: 'ASTROLOGY & LIVE CHAT',
    items: [
      { name: 'Astrologers & KYC', href: '/astrologers', icon: '🧘‍♂️', badge: 'Verify', badgeColor: 'bg-indigo-500 text-white' },
      { name: 'Consultations & Chat', href: '/consultations', icon: '💬', badge: 'Shield', badgeColor: 'bg-red-500 text-white' },
    ],
  },
  {
    group: 'COMMERCE & LOGISTICS',
    items: [
      { name: 'Spiritual Shop Items', href: '/products', icon: '🛍️' },
      { name: 'Prasad & Order Dispatch', href: '/orders', icon: '📦' },
    ],
  },
  {
    group: 'CONTENT & GOVERNANCE',
    items: [
      { name: 'Devotee Registry', href: '/users', icon: '👥' },
      { name: 'Sacred Certificates', href: '/certificates', icon: '📜' },
      { name: 'FAQs Management', href: '/faqs', icon: '❓' },
      { name: 'Platform Settings', href: '/settings', icon: '⚙️' },
    ],
  },
];

interface AdminSidebarProps {
  isMobile?: boolean;
  onClose?: () => void;
}

export default function AdminSidebar({ isMobile, onClose }: AdminSidebarProps) {
  const pathname = usePathname();
  const { lockConsole } = useAdminAuth();

  const handleLinkClick = () => {
    if (isMobile && onClose) {
      onClose();
    }
  };

  return (
    <aside className="w-full h-full lg:w-64 bg-mandir-maroon-deep text-white border-r border-amber-900/30 flex flex-col select-none shadow-2xl relative z-40">
      {/* Brand Logo Header */}
      <div className="h-20 px-4 border-b border-white/10 flex items-center justify-between bg-gradient-to-r from-mandir-maroon to-mandir-maroon-dark shrink-0">
        <Link href="/" onClick={handleLinkClick} className="flex items-center gap-2.5 group">
          <div className="h-11 w-11 rounded-xl bg-black/30 border border-amber-400/20 p-1 flex items-center justify-center shadow-md group-hover:scale-105 transition-transform shrink-0">
            <img
              src="/images/inner_logo_clean.png"
              alt="Mandirm मंदिरम्"
              className="h-9 w-auto object-contain"
            />
          </div>
          <div>
            <span className="font-cinzel font-bold text-base tracking-wider text-amber-200 block leading-tight">
              MANDIRM
            </span>
            <span className="text-[10px] uppercase font-semibold text-amber-300/80 tracking-widest block">
              Admin Sanctum
            </span>
          </div>
        </Link>

        {/* Close Button for Mobile Drawer */}
        {isMobile && (
          <button
            onClick={onClose}
            className="w-9 h-9 rounded-xl bg-white/10 hover:bg-white/20 active:bg-white/30 text-amber-200 flex items-center justify-center transition-colors text-base"
            aria-label="Close sidebar menu"
          >
            ✕
          </button>
        )}
      </div>

      {/* Nav List */}
      <div className="flex-1 overflow-y-auto py-4 px-3 space-y-6">
        {NAV_GROUPS.map((group) => (
          <div key={group.group}>
            <div className="px-3 mb-2 text-[10px] font-bold tracking-wider text-amber-300/50 uppercase">
              {group.group}
            </div>
            <div className="space-y-1">
              {group.items.map((item) => {
                const isActive = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href));
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={handleLinkClick}
                    className={`flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-medium transition-all min-h-[42px] ${
                      isActive
                        ? 'bg-amber-500/25 text-amber-300 font-semibold border border-amber-500/40 shadow-sm'
                        : 'text-amber-100/75 hover:bg-white/5 hover:text-white active:bg-white/10'
                    }`}
                  >
                    <div className="flex items-center gap-2.5">
                      <span className="text-base">{item.icon}</span>
                      <span>{item.name}</span>
                    </div>
                    {item.badge && (
                      <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded-full ${item.badgeColor || 'bg-amber-400 text-black'}`}>
                        {item.badge}
                      </span>
                    )}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Passkey Security & Lock */}
      <div className="px-3 pb-2 shrink-0">
        <button
          onClick={() => {
            if (isMobile && onClose) onClose();
            lockConsole();
          }}
          className="w-full py-2.5 px-3 rounded-xl bg-red-950/40 hover:bg-red-900/60 border border-red-500/30 text-red-200 text-xs font-semibold flex items-center justify-center gap-2 transition-all active:scale-[0.98]"
          title="Lock Admin Console"
        >
          <span>🔒</span>
          <span>Lock Sanctum (Passkey)</span>
        </button>
      </div>

      {/* Safety Compliance Footer */}
      <div className="p-3 border-t border-white/10 bg-black/20 text-xs shrink-0">
        <div className="flex items-center justify-between text-amber-200/80 mb-1">
          <span className="flex items-center gap-1.5 text-[11px] font-medium">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            Mandirm Engine Live
          </span>
          <span className="text-[10px] text-amber-300/60 font-mono">v1.2.0</span>
        </div>
        <p className="text-[10px] text-amber-200/50 leading-tight">
          Protected with Trust & Safety Shield.
        </p>
      </div>
    </aside>
  );
}

