'use client';

import { useState } from 'react';

export default function AdminHeader() {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <header className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between sticky top-0 z-30 shadow-sm">
      {/* Search Input */}
      <div className="flex items-center gap-3 w-96">
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
      <div className="flex items-center gap-4">
        {/* Environment Badge */}
        <div className="flex items-center gap-2 bg-emerald-50 border border-emerald-200 px-3 py-1 rounded-full text-[11px] font-medium text-emerald-800">
          <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
          <span>Railway API • Online</span>
        </div>

        {/* Quick Help / Policies */}
        <a
          href="/child_safety_policy.html"
          target="_blank"
          className="text-xs text-gray-500 hover:text-mandir-maroon transition-colors flex items-center gap-1 font-medium"
        >
          <span>🛡️ Safety Policy</span>
        </a>

        {/* Admin Profile */}
        <div className="flex items-center gap-3 pl-3 border-l border-gray-200">
          <div className="w-8 h-8 rounded-full bg-mandir-maroon text-amber-200 font-bold flex items-center justify-center text-xs shadow-inner">
            A
          </div>
          <div className="hidden md:block text-left">
            <span className="text-xs font-bold text-gray-800 block leading-tight">
              Platform Admin
            </span>
            <span className="text-[10px] text-gray-400 font-medium">
              Super Administrator
            </span>
          </div>
        </div>
      </div>
    </header>
  );
}
