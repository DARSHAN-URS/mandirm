'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAdminAuth } from '@/components/auth/AdminAuthGuard';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

interface NavItemDef {
  nameEn: string;
  nameHi: string;
  href: string;
  icon: string;
  badgeEn?: string;
  badgeHi?: string;
  badgeColor?: string;
}

const NAV_GROUPS: { groupEn: string; groupHi: string; items: NavItemDef[] }[] = [
  {
    groupEn: 'CORE OVERVIEW',
    groupHi: 'मुख्य अवलोकन',
    items: [
      { nameEn: 'Dashboard', nameHi: 'डैशबोर्ड', href: '/', icon: '📊' },
      { nameEn: 'Financials & Dakshina', nameHi: 'वित्तीय एवं दक्षिणा', href: '/transactions', icon: '💳' },
    ],
  },
  {
    groupEn: 'TEMPLE & RITUALS',
    groupHi: 'मंदिर एवं अनुष्ठान',
    items: [
      {
        nameEn: 'Temples & Sanctums',
        nameHi: 'पवित्र मंदिर एवं दर्शन',
        href: '/temples',
        icon: '🛕',
        badgeEn: 'Live',
        badgeHi: 'लाइव',
        badgeColor: 'bg-emerald-500 text-white',
      },
      { nameEn: 'Puja Ceremonies', nameHi: 'पूजा अनुष्ठान सेवाएँ', href: '/puja-services', icon: '🪔' },
      {
        nameEn: 'Bookings & Sankalps',
        nameHi: 'भक्त बुकिंग एवं संकल्प',
        href: '/bookings',
        icon: '📜',
        badgeEn: 'Queue',
        badgeHi: 'कतार',
        badgeColor: 'bg-amber-500 text-white',
      },
      { nameEn: 'Chadhawa Offerings', nameHi: 'चढ़ावा अर्पण', href: '/chadhawa', icon: '🌸' },
    ],
  },
  {
    groupEn: 'PANDITS & ASTROLOGY',
    groupHi: 'पंडित एवं ज्योतिष',
    items: [
      {
        nameEn: 'Pandits & Astrologers',
        nameHi: 'पंडित एवं ज्योतिषी',
        href: '/astrologers',
        icon: '🧘‍♂️',
        badgeEn: 'Verify',
        badgeHi: 'सत्यापित',
        badgeColor: 'bg-indigo-500 text-white',
      },
      {
        nameEn: 'Consultations & Chat',
        nameHi: 'परामर्श एवं संवाद',
        href: '/consultations',
        icon: '💬',
        badgeEn: 'Live',
        badgeHi: 'लाइव',
        badgeColor: 'bg-emerald-500 text-white',
      },
    ],
  },
  {
    groupEn: 'COMMERCE & LOGISTICS',
    groupHi: 'स्टोर एवं वितरण',
    items: [
      { nameEn: 'Spiritual Shop Items', nameHi: 'आध्यात्मिक स्टोर सामग्री', href: '/products', icon: '🛍️' },
      { nameEn: 'Prasad & Order Dispatch', nameHi: 'प्रसाद एवं ऑर्डर वितरण', href: '/orders', icon: '📦' },
    ],
  },
  {
    groupEn: 'CONTENT & GOVERNANCE',
    groupHi: 'सामग्री एवं प्रशासन',
    items: [
      { nameEn: 'Devotee Registry', nameHi: 'भक्त पंजिका', href: '/users', icon: '👥' },
      { nameEn: 'Sacred Certificates', nameHi: 'सहभागिता प्रमाण पत्र', href: '/certificates', icon: '📜' },
      { nameEn: 'FAQs Management', nameHi: 'प्रश्नोत्तरी प्रबंधन', href: '/faqs', icon: '❓' },
      { nameEn: 'Platform Settings', nameHi: 'प्लेटफॉर्म सेटिंग्स', href: '/settings', icon: '⚙️' },
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
  const { isHindi } = useAdminLanguage();

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
              {isHindi ? 'प्रशासक गर्भगृह' : 'Admin Sanctum'}
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

      {/* Navigation Group List */}
      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-6 scrollbar-thin scrollbar-thumb-amber-800/40">
        {NAV_GROUPS.map((group, idx) => (
          <div key={idx} className="space-y-1">
            <h3 className="px-3 text-[11px] font-bold text-amber-300/60 uppercase tracking-widest">
              {isHindi ? group.groupHi : group.groupEn}
            </h3>
            <div className="space-y-0.5 pt-1">
              {group.items.map((item) => {
                const isActive = pathname === item.href;
                const label = isHindi ? item.nameHi : item.nameEn;
                const badge = isHindi ? item.badgeHi : item.badgeEn;

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    onClick={handleLinkClick}
                    className={`flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-medium transition-all group ${
                      isActive
                        ? 'bg-gradient-to-r from-amber-500 to-amber-600 text-mandir-maroon-deep font-bold shadow-md shadow-amber-900/40 scale-[1.02]'
                        : 'text-amber-100/80 hover:bg-white/10 hover:text-white'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-base group-hover:scale-110 transition-transform">
                        {item.icon}
                      </span>
                      <span>{label}</span>
                    </div>

                    {badge && (
                      <span
                        className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                          item.badgeColor || 'bg-amber-400 text-mandir-maroon'
                        }`}
                      >
                        {badge}
                      </span>
                    )}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Footer Info */}
      <div className="p-3 border-t border-white/10 bg-black/20 shrink-0 flex items-center justify-between text-[11px] text-amber-300/70">
        <span className="flex items-center gap-1.5">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
          <span>{isHindi ? 'सुपाबेस कनेक्टेड' : 'Supabase v2.4 Live'}</span>
        </span>
        <button
          onClick={lockConsole}
          className="hover:text-red-300 transition-colors font-semibold px-2 py-0.5 rounded bg-white/5 hover:bg-red-500/20"
        >
          {isHindi ? 'लॉगआउट' : 'Lock'}
        </button>
      </div>
    </aside>
  );
}
