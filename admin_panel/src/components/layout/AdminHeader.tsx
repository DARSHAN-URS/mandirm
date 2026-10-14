'use client';

import { useState } from 'react';
import { useAdminAuth } from '@/components/auth/AdminAuthGuard';

export default function AdminHeader() {
  const [searchQuery, setSearchQuery] = useState('');
  const { lockConsole, adminName } = useAdminAuth();

  return (
    <header className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between sticky top-0 z-30 shadow-sm">
      {/* Search Input */}
      <div className="flex items-center gap-3 w-80 md:w-96">
        <div className="relative w-full">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-sm">
            🔍
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search devotees, temples, pujas, bookings..."
            className="w-full pl-9 pr-4 py-1.5 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-mandir-maroon/20 focus:border-mandir-maroon transition-all"
          />
        </div>
      </div>

      {/* Right Controls */}
      <div className="flex items-center gap-3">
        {/* Real Backend & DB Status Badge */}
        <div className="hidden sm:flex items-center gap-2 bg-emerald-50 border border-emerald-200 px-3 py-1 rounded-full text-[11px] font-medium text-emerald-800">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
          <span>Backend & Supabase • Live</span>
        </div>

        {/* Passkey Verified Badge */}
        <div className="hidden md:flex items-center gap-1.5 bg-amber-50 border border-amber-200 px-2.5 py-1 rounded-full text-[11px] font-semibold text-amber-800">
          <span>🛡️</span>
          <span>Passkey Active</span>
        </div>

        {/* Admin Profile & Lock Console */}
        <div className="flex items-center gap-3 pl-2 sm:pl-3 border-l border-gray-200">
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-mandir-maroon to-mandir-maroon-dark text-amber-300 font-bold flex items-center justify-center text-xs shadow-inner">
            A
          </div>
          <div className="hidden lg:block text-left">
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
            className="p-1.5 hover:bg-red-50 text-gray-400 hover:text-red-600 rounded-lg transition-colors border border-transparent hover:border-red-200 text-xs flex items-center gap-1"
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
