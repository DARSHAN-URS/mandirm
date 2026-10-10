'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

export default function AdminDashboardPage() {
  const [loading, setLoading] = useState(false);

  // Stats data
  const metrics = [
    { title: 'Gross Devotional Volume', value: '₹ 8,42,650', change: '+18.4%', icon: '🪙', color: 'from-amber-500 to-amber-600', sub: 'Puja, Chadhawa & Dakshina' },
    { title: 'Sacred Temples', value: '14 Active', change: '8 Live Streams', icon: '🛕', color: 'from-orange-500 to-orange-600', sub: 'Kashi, Mahakal, Tirupati...' },
    { title: 'Puja Bookings', value: '1,284', change: '+12% this week', icon: '🪔', color: 'from-red-600 to-red-700', sub: '24 Sankalps in Queue' },
    { title: 'Chadhawa Offerings', value: '3,890', change: '+24%', icon: '🌸', color: 'from-pink-500 to-rose-600', sub: 'Dispatched to sanctums' },
    { title: 'Vedic Astrologers', value: '48 Verified', change: '12 Online now', icon: '🧘‍♂️', color: 'from-indigo-600 to-indigo-700', sub: '3 Pending KYC Review' },
    { title: 'Live Chat & Calls', value: '742 Sessions', change: 'WhatsApp Engine', icon: '💬', color: 'from-emerald-600 to-teal-700', sub: 'Zero Safety Flags' },
    { title: 'Prasad & Samagri Orders', value: '531 Orders', change: '94% Fulfilled', icon: '📦', color: 'from-blue-600 to-blue-700', sub: 'Express temple delivery' },
    { title: 'Registered Devotees', value: '18,450', change: '+320 today', icon: '👥', color: 'from-purple-600 to-purple-700', sub: 'Across 28 states & NRI' },
  ];

  // Recent Puja Bookings with Sankalps
  const recentBookings = [
    { id: 'BK-9801', devotee: 'Sunil Kumar Sharma', gotra: 'Kashyapa', puja: 'Maha Mrityunjaya Jaap (54,000 chants)', temple: 'Mahakaleshwar Jyotirlinga, Ujjain', date: 'Today, 06:30 AM', status: 'In Progress', dakshina: '₹ 5,100' },
    { id: 'BK-9799', devotee: 'Pooja Agarwal & Family', gotra: 'Garg', puja: 'Rudrabhishek with Bilva Patra', temple: 'Kashi Vishwanath, Varanasi', date: 'Today, 08:00 AM', status: 'Priest Assigned', dakshina: '₹ 2,100' },
    { id: 'BK-9794', devotee: 'Rameshwar Iyer', gotra: 'Bharadwaja', puja: 'Navgrah Shanti & Rahu Ketu Havan', temple: 'Kalahasti Temple, Andhra', date: 'Yesterday', status: 'Completed', dakshina: '₹ 3,500' },
    { id: 'BK-9788', devotee: 'Ananya Deshmukh', gotra: 'Vashistha', puja: 'Siddhivinayak Sankat Nashan Puja', temple: 'Siddhivinayak, Mumbai', date: 'Yesterday', status: 'Completed', dakshina: '₹ 1,500' },
  ];

  // Live Consultations & Moderation Feed
  const recentConsultations = [
    { id: 'CONS-402', devotee: 'Aditya Verma', acharya: 'Pandit Radheshyam Shastri', type: 'WhatsApp Chat', duration: '14 min', status: 'Live Active', moderation: 'Clean ✓' },
    { id: 'CONS-401', devotee: 'Meenakshi Sundaram', acharya: 'Acharya Vidyadhar Vyas', type: 'Video Call (Agora)', duration: '22 min', status: 'Live Active', moderation: 'Clean ✓' },
    { id: 'CONS-398', devotee: 'Rajesh Nair', acharya: 'Dr. Jyotishacharya Devraj', type: 'WhatsApp Chat', duration: '18 min', status: 'Completed', moderation: 'Clean ✓' },
    { id: 'CONS-395', devotee: 'Kavita Chawla', acharya: 'Swami Anand Swaroop', type: 'Voice Call', duration: '11 min', status: 'Completed', moderation: 'Clean ✓' },
  ];

  return (
    <div className="space-y-6">
      {/* Welcome Banner */}
      <div className="bg-gradient-to-r from-mandir-maroon via-mandir-maroon-dark to-mandir-maroon-deep rounded-2xl p-6 text-white shadow-divine relative overflow-hidden">
        <div className="relative z-10 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <div className="inline-flex items-center gap-2 bg-amber-400/20 text-amber-200 border border-amber-400/30 px-3 py-1 rounded-full text-xs font-semibold mb-2">
              <span>🕉️ Sri Mandir Divine Ecosystem</span>
            </div>
            <h1 className="text-2xl font-bold font-cinzel text-amber-100">
              Operations & Platform Administration
            </h1>
            <p className="text-xs text-amber-200/80 max-w-2xl mt-1">
              Unified command center managing Temples, Live Darshan, Devotee Sankalps, Chadhawa dispatches, verified Astrologer consultations, and real-time WhatsApp-style chat moderation.
            </p>
          </div>

          {/* Quick Action Shortcuts */}
          <div className="flex flex-wrap gap-2">
            <Link
              href="/temples"
              className="px-3.5 py-2 bg-amber-500 hover:bg-amber-400 text-mandir-maroon-deep font-bold text-xs rounded-xl shadow-md transition-all flex items-center gap-1.5"
            >
              <span>🛕</span> Add Temple
            </Link>
            <Link
              href="/puja-services"
              className="px-3.5 py-2 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all flex items-center gap-1.5"
            >
              <span>🪔</span> New Puja
            </Link>
            <Link
              href="/astrologers"
              className="px-3.5 py-2 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all flex items-center gap-1.5"
            >
              <span>🧘‍♂️</span> Verify KYC
            </Link>
            <Link
              href="/consultations"
              className="px-3.5 py-2 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold text-xs rounded-xl shadow-md transition-all flex items-center gap-1.5"
            >
              <span>🛡️</span> Chat Shield
            </Link>
          </div>
        </div>

        {/* Ambient background ornament */}
        <div className="absolute right-0 bottom-0 translate-x-12 translate-y-12 opacity-10 text-9xl pointer-events-none select-none">
          🕉️
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {metrics.map((m) => (
          <div
            key={m.title}
            className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm hover:shadow-md transition-all group"
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-semibold text-gray-500 tracking-wide uppercase">
                {m.title}
              </span>
              <div className={`w-9 h-9 rounded-xl bg-gradient-to-br ${m.color} text-white flex items-center justify-center text-lg shadow-sm group-hover:scale-110 transition-transform`}>
                {m.icon}
              </div>
            </div>
            <div className="text-xl font-bold text-gray-900 font-cinzel">
              {m.value}
            </div>
            <div className="flex items-center justify-between mt-2 pt-2 border-t border-gray-50">
              <span className="text-[11px] font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-md">
                {m.change}
              </span>
              <span className="text-[10px] text-gray-400 font-medium">
                {m.sub}
              </span>
            </div>
          </div>
        ))}
      </div>

      {/* Two Column Operational Panes */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left (2 Cols): Recent Puja Bookings & Sankalps */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden flex flex-col">
          <div className="p-5 border-b border-gray-100 flex items-center justify-between">
            <div>
              <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2">
                <span>📜</span> Devotee Puja Bookings & Active Sankalps
              </h2>
              <p className="text-[11px] text-gray-500">Live rituals queue awaiting priest confirmation or dispatch</p>
            </div>
            <Link
              href="/bookings"
              className="text-xs font-semibold text-mandir-maroon hover:underline flex items-center gap-1"
            >
              View All Queue <span>→</span>
            </Link>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-gray-50/70 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                <tr>
                  <th className="py-3 px-4">Booking ID</th>
                  <th className="py-3 px-4">Devotee & Gotra</th>
                  <th className="py-3 px-4">Sacred Puja</th>
                  <th className="py-3 px-4">Temple</th>
                  <th className="py-3 px-4">Dakshina</th>
                  <th className="py-3 px-4">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {recentBookings.map((b) => (
                  <tr key={b.id} className="hover:bg-amber-50/30 transition-colors">
                    <td className="py-3.5 px-4 font-mono font-semibold text-gray-700">{b.id}</td>
                    <td className="py-3.5 px-4">
                      <div className="font-semibold text-gray-900">{b.devotee}</div>
                      <div className="text-[10px] text-amber-700 font-medium">Gotra: {b.gotra}</div>
                    </td>
                    <td className="py-3.5 px-4 max-w-xs truncate text-gray-800 font-medium">{b.puja}</td>
                    <td className="py-3.5 px-4 text-gray-500 text-[11px]">{b.temple}</td>
                    <td className="py-3.5 px-4 font-bold text-gray-900">{b.dakshina}</td>
                    <td className="py-3.5 px-4">
                      <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold ${
                        b.status === 'In Progress'
                          ? 'bg-amber-100 text-amber-800 animate-pulse'
                          : b.status === 'Priest Assigned'
                          ? 'bg-blue-100 text-blue-800'
                          : 'bg-emerald-100 text-emerald-800'
                      }`}>
                        {b.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Right (1 Col): Live Consultations & Chat Shield */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2">
                  <span>💬</span> Consultations & Chat Shield
                </h2>
                <p className="text-[11px] text-gray-500">Live 1-on-1 astrologer calls & WhatsApp chat monitoring</p>
              </div>
              <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping"></span>
            </div>

            <div className="space-y-3">
              {recentConsultations.map((c) => (
                <div key={c.id} className="p-3 rounded-xl border border-gray-100 bg-gray-50/50 hover:bg-gray-50 transition-colors">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-semibold text-xs text-gray-900">{c.devotee}</span>
                    <span className="text-[10px] font-mono text-gray-400">{c.id}</span>
                  </div>
                  <div className="text-[11px] text-gray-600 mb-2">
                    with <span className="font-medium text-amber-900">{c.acharya}</span>
                  </div>
                  <div className="flex items-center justify-between text-[10px] pt-1 border-t border-gray-200/60">
                    <span className="font-medium text-gray-500 flex items-center gap-1">
                      {c.type === 'WhatsApp Chat' ? '💬 WhatsApp' : '📹 Agora Video'} • {c.duration}
                    </span>
                    <span className="px-2 py-0.5 rounded font-bold bg-emerald-100 text-emerald-800">
                      {c.moderation}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Chat Shield Compliance Card */}
          <div className="mt-4 p-3 bg-gradient-to-r from-emerald-50 to-teal-50 border border-emerald-200 rounded-xl">
            <div className="flex items-center gap-2 text-emerald-800 font-bold text-xs mb-1">
              <span>🛡️ Real-Time Safety Filter Active</span>
            </div>
            <p className="text-[10px] text-emerald-700 leading-tight">
              Anti-disintermediation shield blocks phone numbers, emails, and external UPI IDs automatically. Zero safety incidents reported.
            </p>
            <Link
              href="/consultations"
              className="inline-block mt-2 text-[10px] font-bold text-emerald-800 underline"
            >
              Open Live Moderation Dashboard →
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
