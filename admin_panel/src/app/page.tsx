'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase/client';

interface Booking {
  id: string;
  user_name?: string;
  sankalp_name?: string;
  sankalp_gotra?: string;
  puja_title: string;
  temple_name: string;
  booking_date?: string;
  created_at: string;
  status: string;
  amount: number;
}

interface Consultation {
  id: string;
  user_name: string;
  astrologer_name: string;
  type: string;
  duration_minutes: number;
  status: string;
  created_at: string;
}

export default function AdminDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    grossVolume: 0,
    templesCount: 0,
    liveStreamsCount: 0,
    pujasCount: 0,
    bookingsCount: 0,
    chadhawaCount: 0,
    astrologersCount: 0,
    onlineAstrologersCount: 0,
    consultationsCount: 0,
    ordersCount: 0,
    devoteesCount: 0,
  });

  const [recentBookings, setRecentBookings] = useState<Booking[]>([]);
  const [recentConsultations, setRecentConsultations] = useState<Consultation[]>([]);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      // 1. Parallel queries to Supabase real tables
      const [
        templesRes,
        pujasRes,
        bookingsRes,
        chadhawaRes,
        astrologersRes,
        consultationsRes,
        ordersRes,
        profilesRes,
      ] = await Promise.all([
        supabase.from('temples').select('id, live_darshan_url'),
        supabase.from('puja_services').select('id'),
        supabase.from('bookings').select('*').order('created_at', { ascending: false }).limit(6),
        supabase.from('chadhawa_offerings').select('id'),
        supabase.from('astrologers').select('id, is_online'),
        supabase.from('consultations').select('*').order('created_at', { ascending: false }).limit(6),
        supabase.from('orders').select('id, total_amount, order_status'),
        supabase.from('profiles').select('id', { count: 'exact' }),
      ]);

      const temples = templesRes.data || [];
      const liveFeeds = temples.filter((t) => t.live_darshan_url && t.live_darshan_url.trim().length > 0).length;
      const pujas = pujasRes.data || [];
      const bookings = bookingsRes.data || [];
      const chadhawa = chadhawaRes.data || [];
      const astrologers = astrologersRes.data || [];
      const onlineAstros = astrologers.filter((a) => a.is_online).length;
      const consultations = consultationsRes.data || [];
      const orders = ordersRes.data || [];
      const devoteesCount = profilesRes.count ?? profilesRes.data?.length ?? 0;

      // Calculate real gross revenue from completed/confirmed bookings and orders
      const bookingSum = bookings.reduce((sum, b) => sum + (Number(b.amount) || 0), 0);
      const orderSum = orders.reduce((sum, o) => sum + (Number(o.total_amount) || 0), 0);
      const consSum = consultations.reduce((sum, c) => sum + (Number(c.total_amount) || 0), 0);
      const gross = bookingSum + orderSum + consSum;

      setStats({
        grossVolume: gross,
        templesCount: temples.length,
        liveStreamsCount: liveFeeds,
        pujasCount: pujas.length,
        bookingsCount: bookings.length,
        chadhawaCount: chadhawa.length,
        astrologersCount: astrologers.length,
        onlineAstrologersCount: onlineAstros,
        consultationsCount: consultations.length,
        ordersCount: orders.length,
        devoteesCount,
      });

      setRecentBookings(bookings as Booking[]);
      setRecentConsultations(consultations as Consultation[]);
    } catch (err) {
      console.error('Error fetching dashboard live data:', err);
    } finally {
      setLoading(false);
    }
  };

  const metrics = [
    {
      title: 'Gross Devotional Volume',
      value: `₹ ${stats.grossVolume.toLocaleString('en-IN')}`,
      change: 'Live Database',
      icon: '🪙',
      color: 'from-amber-500 to-amber-600',
      sub: 'Puja, Store & Consultations',
    },
    {
      title: 'Sacred Temples',
      value: `${stats.templesCount} Listed`,
      change: `${stats.liveStreamsCount} Live Feeds`,
      icon: '🛕',
      color: 'from-orange-500 to-orange-600',
      sub: 'Sanctums & Darshan',
      href: '/temples',
    },
    {
      title: 'Puja Services',
      value: `${stats.pujasCount} Active`,
      change: 'Vedic Ceremonies',
      icon: '🪔',
      color: 'from-red-600 to-red-700',
      sub: 'Sanctum Rituals Catalog',
      href: '/puja-services',
    },
    {
      title: 'Devotee Bookings',
      value: `${stats.bookingsCount} Recorded`,
      change: 'Live Queue',
      icon: '📜',
      color: 'from-purple-600 to-purple-700',
      sub: 'Sankalps & Intentions',
      href: '/bookings',
    },
    {
      title: 'Chadhawa Items',
      value: `${stats.chadhawaCount} Offerings`,
      change: 'Sanctum Delivery',
      icon: '🌸',
      color: 'from-pink-500 to-rose-600',
      sub: 'Silver Chhatra, Diya & Vastra',
      href: '/chadhawa',
    },
    {
      title: 'Vedic Astrologers',
      value: `${stats.astrologersCount} Verified`,
      change: `${stats.onlineAstrologersCount} Online Now`,
      icon: '🧘‍♂️',
      color: 'from-indigo-600 to-indigo-700',
      sub: 'Verified Acharyas & Jyotish',
      href: '/astrologers',
    },
    {
      title: 'Live Consultations',
      value: `${stats.consultationsCount} Total`,
      change: 'RTC / Chat',
      icon: '💬',
      color: 'from-emerald-600 to-teal-700',
      sub: 'Agora Call & Safety Shield',
      href: '/consultations',
    },
    {
      title: 'Devotee Profiles',
      value: `${stats.devoteesCount} Registered`,
      change: 'Supabase Auth',
      icon: '👥',
      color: 'from-cyan-600 to-blue-700',
      sub: 'Gotras & Devotional Lineage',
      href: '/users',
    },
  ];

  return (
    <div className="space-y-4 sm:space-y-6 max-w-full">
      {/* Welcome Banner with Authentic Logo */}
      <div className="bg-gradient-to-r from-mandir-maroon via-mandir-maroon-dark to-mandir-maroon-deep rounded-2xl sm:rounded-3xl p-4 sm:p-6 md:p-8 text-white shadow-divine relative overflow-hidden">
        <div className="relative z-10 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 sm:gap-6">
          <div className="flex items-start sm:items-center gap-3 sm:gap-4">
            <div className="h-12 w-12 sm:h-16 sm:w-16 rounded-xl sm:rounded-2xl bg-black/30 border border-amber-400/30 p-1.5 sm:p-2 flex items-center justify-center shrink-0 shadow-xl">
              <img
                src="/images/inner_logo_clean.png"
                alt="Mandirm"
                className="h-9 sm:h-12 w-auto object-contain"
              />
            </div>
            <div>
              <div className="inline-flex items-center gap-1.5 bg-amber-400/20 text-amber-200 border border-amber-400/30 px-2.5 py-0.5 sm:px-3 sm:py-1 rounded-full text-[10px] sm:text-xs font-semibold mb-1">
                <span>🕉️ Sri Mandir Unified Operations</span>
              </div>
              <h1 className="text-xl sm:text-2xl md:text-3xl font-bold font-cinzel text-amber-100 leading-tight">
                Command Center & Live Portal
              </h1>
              <p className="text-[11px] sm:text-xs text-amber-200/80 max-w-xl mt-1 leading-normal">
                Direct production connection to Supabase & FastAPI backend. Changes made here propagate instantly to the mobile app and website.
              </p>
            </div>
          </div>

          {/* Quick Shortcuts */}
          <div className="flex flex-wrap items-center gap-2 w-full lg:w-auto">
            <Link
              href="/temples"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-amber-500 hover:bg-amber-400 text-mandir-maroon-deep font-bold text-xs rounded-xl shadow-md transition-all flex items-center gap-1.5 active:scale-95"
            >
              <span>🛕</span> Add Temple
            </Link>
            <Link
              href="/puja-services"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all flex items-center gap-1.5 active:scale-95"
            >
              <span>🪔</span> New Puja
            </Link>
            <Link
              href="/products"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all flex items-center gap-1.5 active:scale-95"
            >
              <span>📦</span> New Product
            </Link>
            <button
              onClick={fetchDashboardData}
              disabled={loading}
              className="px-3 sm:px-3.5 py-2 sm:py-2.5 bg-black/30 hover:bg-black/50 text-amber-200 font-semibold text-xs rounded-xl border border-amber-400/30 transition-all flex items-center justify-center gap-1.5 active:scale-95"
              title="Refresh Live Metrics"
            >
              <span>{loading ? '⏳' : '🔄'}</span>
              <span className="hidden sm:inline">Refresh</span>
            </button>
          </div>
        </div>
      </div>

      {/* Real KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        {metrics.map((m) => {
          const content = (
            <div className="bg-white rounded-xl sm:rounded-2xl border border-gray-100 p-3.5 sm:p-5 shadow-sm hover:shadow-md transition-all group flex flex-col justify-between h-full">
              <div>
                <div className="flex items-center justify-between mb-2 sm:mb-3">
                  <span className="text-[10px] sm:text-xs font-semibold text-gray-500 tracking-wide uppercase line-clamp-1">
                    {m.title}
                  </span>
                  <div
                    className={`w-7 h-7 sm:w-9 sm:h-9 rounded-lg sm:rounded-xl bg-gradient-to-br ${m.color} text-white flex items-center justify-center text-sm sm:text-lg shadow-sm group-hover:scale-110 transition-transform shrink-0`}
                  >
                    {m.icon}
                  </div>
                </div>
                <div className="flex flex-col sm:flex-row sm:items-baseline justify-between gap-1">
                  <span className="text-lg sm:text-2xl font-bold font-cinzel text-gray-900 tracking-tight">
                    {loading ? '...' : m.value}
                  </span>
                  <span className="text-[9px] sm:text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-1.5 sm:px-2 py-0.5 rounded-full border border-emerald-100 w-fit">
                    {m.change}
                  </span>
                </div>
              </div>
              <p className="text-[10px] sm:text-[11px] text-gray-400 mt-2 font-medium line-clamp-1">{m.sub}</p>
            </div>
          );

          return m.href ? (
            <Link key={m.title} href={m.href} className="block h-full">
              {content}
            </Link>
          ) : (
            <div key={m.title} className="h-full">{content}</div>
          );
        })}
      </div>

      {/* Live Operational Queues */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
        {/* Recent Puja Bookings */}
        <div className="bg-white rounded-xl sm:rounded-2xl border border-gray-100 p-4 sm:p-5 shadow-sm">
          <div className="flex items-center justify-between mb-3 sm:mb-4 border-b border-gray-100 pb-3">
            <div>
              <h2 className="text-xs sm:text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2">
                <span>📜</span> Devotee Bookings & Sankalps Queue
              </h2>
              <span className="text-[10px] sm:text-[11px] text-gray-400">Live records from Supabase</span>
            </div>
            <Link
              href="/bookings"
              className="text-xs text-amber-700 hover:text-amber-800 font-semibold shrink-0 ml-2"
            >
              View All →
            </Link>
          </div>

          {recentBookings.length === 0 ? (
            <div className="py-8 sm:py-10 text-center text-gray-400 text-xs">
              <span className="text-3xl block mb-2">📜</span>
              <span>No bookings currently in queue.</span>
            </div>
          ) : (
            <div className="space-y-2.5 sm:space-y-3">
              {recentBookings.map((b) => (
                <div
                  key={b.id}
                  className="p-3 sm:p-3.5 rounded-xl border border-gray-100 bg-gray-50/50 hover:bg-amber-50/30 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-2 sm:gap-3 text-xs"
                >
                  <div className="min-w-0 flex-1">
                    <div className="font-semibold text-gray-900 truncate">
                      {b.sankalp_name || b.user_name || 'Devotee'}
                      {b.sankalp_gotra && (
                        <span className="ml-1.5 font-normal text-gray-500 font-mono text-[10px]">
                          (Gotra: {b.sankalp_gotra})
                        </span>
                      )}
                    </div>
                    <div className="text-gray-500 text-[11px] mt-0.5 truncate">
                      {b.puja_title} • <span className="text-amber-800 font-medium">{b.temple_name}</span>
                    </div>
                  </div>
                  <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-center shrink-0 pt-1 sm:pt-0 border-t sm:border-t-0 border-gray-100">
                    <span className="font-bold text-gray-900 font-cinzel block text-xs sm:text-sm">
                      ₹ {Number(b.amount || 0).toLocaleString('en-IN')}
                    </span>
                    <span
                      className={`inline-block px-2 py-0.5 rounded-full text-[10px] font-semibold capitalize ${
                        b.status === 'Completed' || b.status === 'completed'
                          ? 'bg-emerald-100 text-emerald-800'
                          : 'bg-amber-100 text-amber-800'
                      }`}
                    >
                      {b.status || 'Confirmed'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Live Consultations & Chat Feed */}
        <div className="bg-white rounded-xl sm:rounded-2xl border border-gray-100 p-4 sm:p-5 shadow-sm">
          <div className="flex items-center justify-between mb-3 sm:mb-4 border-b border-gray-100 pb-3">
            <div>
              <h2 className="text-xs sm:text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2">
                <span>💬</span> Consultations & Session Activity
              </h2>
              <span className="text-[10px] sm:text-[11px] text-gray-400">Live records from Supabase</span>
            </div>
            <Link
              href="/consultations"
              className="text-xs text-amber-700 hover:text-amber-800 font-semibold shrink-0 ml-2"
            >
              View Hub →
            </Link>
          </div>

          {recentConsultations.length === 0 ? (
            <div className="py-8 sm:py-10 text-center text-gray-400 text-xs">
              <span className="text-3xl block mb-2">🧘‍♂️</span>
              <span>No active consultation sessions right now.</span>
            </div>
          ) : (
            <div className="space-y-2.5 sm:space-y-3">
              {recentConsultations.map((c) => (
                <div
                  key={c.id}
                  className="p-3 sm:p-3.5 rounded-xl border border-gray-100 bg-gray-50/50 hover:bg-emerald-50/30 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-2 sm:gap-3 text-xs"
                >
                  <div className="min-w-0 flex-1">
                    <div className="font-semibold text-gray-900 truncate">
                      {c.user_name || 'Devotee'} <span className="text-gray-400 font-normal">with</span> {c.astrologer_name}
                    </div>
                    <div className="text-gray-500 text-[11px] mt-0.5 capitalize truncate">
                      {c.type} Session • {c.duration_minutes || 0} mins
                    </div>
                  </div>
                  <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-center shrink-0 pt-1 sm:pt-0 border-t sm:border-t-0 border-gray-100">
                    <span
                      className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-semibold capitalize ${
                        c.status === 'active'
                          ? 'bg-emerald-100 text-emerald-800 animate-pulse'
                          : 'bg-gray-100 text-gray-700'
                      }`}
                    >
                      {c.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
