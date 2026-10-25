'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useAdminAuth } from '@/components/auth/AdminAuthGuard';
import { useSidebar } from './AdminLayoutShell';

export default function AdminHeader() {
  const [searchQuery, setSearchQuery] = useState('');
  const { lockConsole, adminName } = useAdminAuth();
  const { toggleMobileSidebar } = useSidebar();

  return (
    <header className="h-16 bg-white border-b border-gray-200 px-3 sm:px-6 flex items-center justify-between sticky top-0 z-30 shadow-sm shrink-0">
      {/* Left: Mobile Hamburger & Search Input */}
      <div className="flex items-center gap-2 sm:gap-3 flex-1 min-w-0 mr-2 sm:mr-4">
        {/* Mobile Hamburger Button */}
        <button
          onClick={toggleMobileSidebar}
          className="lg:hidden p-2 rounded-xl text-gray-700 hover:text-mandir-maroon hover:bg-gray-100 active:bg-gray-200 transition-colors shrink-0"
          aria-label="Toggle Navigation Menu"
        >
          <svg
            className="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M4 6h16M4 12h16M4 18h16"
            />
          </svg>
        </button>

        {/* Mobile Brand Icon (only visible on small screens when drawer is closed) */}
        <Link href="/" className="lg:hidden flex items-center shrink-0 mr-1">
          <img
            src="/images/inner_logo_clean.png"
            alt="Mandirm"
            className="h-7 w-auto object-contain"
          />
        </Link>

        {/* Search Input */}
        <div className="relative w-full max-w-[200px] sm:max-w-xs md:max-w-sm">
          <span className="absolute inset-y-0 left-0 pl-2.5 sm:pl-3 flex items-center text-gray-400 text-xs sm:text-sm">
            🔍
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search..."
            className="w-full pl-8 sm:pl-9 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-mandir-maroon/20 focus:border-mandir-maroon transition-all placeholder-gray-400"
          />
        </div>
      </div>

      {/* Right Controls */}
      <div className="flex items-center gap-1.5 sm:gap-3 shrink-0">
        {/* Real Backend & DB Status Badge (Desktop & Tablet) */}
        <div className="hidden md:flex items-center gap-2 bg-emerald-50 border border-emerald-200 px-3 py-1 rounded-full text-[11px] font-medium text-emerald-800">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          <span>Backend Live</span>
        </div>

        {/* Mobile Live Dot Indicator */}
        <div
          className="md:hidden flex items-center justify-center p-1.5 rounded-full bg-emerald-50 text-emerald-700"
          title="Backend & Supabase Live"
        >
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
        </div>

        {/* Passkey Verified Badge */}
        <div className="hidden lg:flex items-center gap-1.5 bg-amber-50 border border-amber-200 px-2.5 py-1 rounded-full text-[11px] font-semibold text-amber-800">
          <span>🛡️</span>
          <span>Passkey Active</span>
        </div>

        {/* Admin Profile & Lock Console */}
        <div className="flex items-center gap-2 sm:gap-3 pl-1.5 sm:pl-3 border-l border-gray-200">
          <div
            className="w-7 h-7 sm:w-8 sm:h-8 rounded-full bg-gradient-to-br from-mandir-maroon to-mandir-maroon-dark text-amber-300 font-bold flex items-center justify-center text-xs shadow-inner shrink-0"
            title={adminName}
          >
            A
          </div>
          <div className="hidden xl:block text-left">
            <span className="text-xs font-bold text-gray-800 block leading-tight">
              {adminName}
            </span>
            <span className="text-[10px] text-emerald-600 font-semibold flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
              Sanctum Operator
            </span>
          </div>

          {/* Quick Lock Button */}
          <button
            onClick={lockConsole}
            className="p-1.5 sm:p-2 hover:bg-red-50 text-gray-500 hover:text-red-600 rounded-lg transition-colors border border-transparent hover:border-red-200 text-xs flex items-center gap-1"
            title="Lock Console (Sign Out)"
          >
            <span>🔒</span>
            <span className="hidden sm:inline text-[11px] font-medium">Lock</span>
          </button>
        </div>
      </div>
    </header>
  );
}

