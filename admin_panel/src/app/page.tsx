'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

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
  const { isHindi } = useAdminLanguage();
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
      // Direct production queries to Supabase tables
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

      // Real gross revenue from settled bookings, orders and consultations
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
      title: isHindi ? 'कुल दक्षिणा एवं व्यापार' : 'Gross Devotional Volume',
      value: `₹ ${stats.grossVolume.toLocaleString('en-IN')}`,
      change: isHindi ? 'लाइव डेटाबेस' : 'Live Database',
      icon: '🪙',
      color: 'from-amber-500 to-amber-600',
      sub: isHindi ? 'पूजा, स्टोर एवं परामर्श' : 'Puja, Store & Consultations',
      href: '/transactions',
    },
    {
      title: isHindi ? 'पवित्र तीर्थ व मंदिर' : 'Sacred Temples',
      value: `${stats.templesCount} ${isHindi ? 'सूचीबद्ध' : 'Listed'}`,
      change: `${stats.liveStreamsCount} ${isHindi ? 'लाइव दर्शन' : 'Live Feeds'}`,
      icon: '🛕',
      color: 'from-orange-500 to-orange-600',
      sub: isHindi ? 'गर्भगृह एवं दर्शन' : 'Sanctums & Darshan',
      href: '/temples',
    },
    {
      title: isHindi ? 'पूजा अनुष्ठान सेवाएँ' : 'Puja Services',
      value: `${stats.pujasCount} ${isHindi ? 'सक्रिय' : 'Active'}`,
      change: isHindi ? 'वैदिक अनुष्ठान' : 'Vedic Ceremonies',
      icon: '🪔',
      color: 'from-red-600 to-red-700',
      sub: isHindi ? 'मंदिर अनुष्ठान सूची' : 'Sanctum Rituals Catalog',
      href: '/puja-services',
    },
    {
      title: isHindi ? 'भक्त बुकिंग एवं संकल्प' : 'Devotee Bookings',
      value: `${stats.bookingsCount} ${isHindi ? 'दर्ज' : 'Recorded'}`,
      change: isHindi ? 'लाइव कतार' : 'Live Queue',
      icon: '📜',
      color: 'from-purple-600 to-purple-700',
      sub: isHindi ? 'संकल्प एवं आशीर्वाद' : 'Sankalps & Intentions',
      href: '/bookings',
    },
    {
      title: isHindi ? 'चढ़ावा एवं विशेष अर्पण' : 'Chadhawa Offerings',
      value: `${stats.chadhawaCount} ${isHindi ? 'उपलब्ध' : 'Cataloged'}`,
      change: isHindi ? 'भोग एवं शृंगार' : 'Direct Sanctum Offerings',
      icon: '🌸',
      color: 'from-pink-600 to-pink-700',
      sub: isHindi ? 'प्रसाद एवं दीप दान' : 'Temple Prasadam & Deep Daan',
      href: '/chadhawa',
    },
    {
      title: isHindi ? 'पंडित एवं ज्योतिषी' : 'Verified Astrologers',
      value: `${stats.astrologersCount} ${isHindi ? 'पंजीकृत' : 'Registered'}`,
      change: `${stats.onlineAstrologersCount} ${isHindi ? 'अभी ऑनलाइन' : 'Now Online'}`,
      icon: '🧘‍♂️',
      color: 'from-indigo-600 to-indigo-700',
      sub: isHindi ? 'कुंडली एवं वैदिक संवाद' : 'Live Chat & Audio Calling',
      href: '/astrologers',
    },
    {
      title: isHindi ? 'परामर्श सत्र' : 'Devotee Consultations',
      value: `${stats.consultationsCount} ${isHindi ? 'सत्र' : 'Sessions'}`,
      change: isHindi ? 'सुरक्षित संचार' : 'Private Audio/Chat',
      icon: '💬',
      color: 'from-blue-600 to-blue-700',
      sub: isHindi ? 'ज्योतिष परामर्श' : 'Astrological Counseling',
      href: '/consultations',
    },
    {
      title: isHindi ? 'पंजीकृत भक्त' : 'Registered Devotees',
      value: `${stats.devoteesCount} ${isHindi ? 'भक्त' : 'Devotees'}`,
      change: isHindi ? 'गोत्र सहित पंजिका' : 'Active Profiles',
      icon: '👥',
      color: 'from-emerald-600 to-emerald-700',
      sub: isHindi ? 'समर्पित समुदाय' : 'Devotional Community',
      href: '/users',
    },
  ];

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Top Banner with Quick Action Buttons */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-mandir-maroon-deep via-mandir-maroon to-mandir-maroon-dark p-4 sm:p-6 md:p-8 text-white shadow-xl border border-amber-500/30">
        <div className="absolute top-0 right-0 -mt-6 -mr-6 w-48 sm:w-64 h-48 sm:h-64 rounded-full bg-amber-500/10 blur-3xl pointer-events-none" />
        <div className="relative z-10 flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4 sm:gap-6">
          <div className="flex items-start sm:items-center gap-3 sm:gap-4">
            <div className="h-12 w-12 sm:h-16 sm:w-16 rounded-2xl bg-black/40 border border-amber-400/30 p-2 flex items-center justify-center shrink-0 shadow-inner">
              <img
                src="/images/inner_logo_clean.png"
                alt="Mandirm"
                className="h-9 sm:h-12 w-auto object-contain"
              />
            </div>
            <div>
              <div className="inline-flex items-center gap-1.5 bg-amber-400/20 text-amber-200 border border-amber-400/30 px-2.5 py-0.5 sm:px-3 sm:py-1 rounded-full text-[10px] sm:text-xs font-semibold mb-1">
                <span>{isHindi ? '🕉️ श्री मंदिरम् एकीकृत संचालन' : '🕉️ Sri Mandir Unified Operations'}</span>
              </div>
              <h1 className="text-xl sm:text-2xl md:text-3xl font-bold font-cinzel text-amber-100 leading-tight">
                {isHindi ? 'कमांड सेंटर एवं लाइव पोर्टल' : 'Command Center & Live Portal'}
              </h1>
              <p className="text-[11px] sm:text-xs text-amber-200/80 max-w-xl mt-1 leading-normal">
                {isHindi
                  ? 'सुपाबेस डेटाबेस से सीधा उत्पादन कनेक्शन। यहाँ किए गए परिवर्तन तुरंत वेबसाइट और ऐप पर दिखाई देते हैं।'
                  : 'Direct production connection to Supabase & FastAPI backend. Changes made here propagate instantly to the mobile app and website.'}
              </p>
            </div>
          </div>

          {/* Quick Shortcuts with prominent Add Pandit button */}
          <div className="flex flex-wrap items-center gap-2 w-full lg:w-auto">
            <Link
              href="/temples"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-amber-500 hover:bg-amber-400 text-mandir-maroon-deep font-bold text-xs rounded-xl shadow-md transition-all flex items-center gap-1.5 active:scale-95"
            >
              <span>🛕</span> {isHindi ? 'मंदिर जोड़ें' : 'Add Temple'}
            </Link>

            {/* User Requested: Add Pandit Button right in header banner */}
            <Link
              href="/astrologers?action=new"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-gradient-to-r from-amber-600 to-amber-700 hover:from-amber-500 hover:to-amber-600 text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center gap-1.5 active:scale-95 border border-amber-400/30"
            >
              <span>🧘‍♂️</span> {isHindi ? 'पंडित जोड़ें' : 'Add Pandit'}
            </Link>

            <Link
              href="/puja-services"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all flex items-center gap-1.5 active:scale-95"
            >
              <span>🪔</span> {isHindi ? 'नई पूजा' : 'New Puja'}
            </Link>

            <Link
              href="/products"
              className="flex-1 sm:flex-none justify-center px-3 sm:px-4 py-2 sm:py-2.5 bg-white/10 hover:bg-white/20 text-white font-semibold text-xs rounded-xl border border-white/20 transition-all flex items-center gap-1.5 active:scale-95"
            >
              <span>📦</span> {isHindi ? 'नया उत्पाद' : 'New Product'}
            </Link>

            <button
              onClick={fetchDashboardData}
              disabled={loading}
              className="px-3 sm:px-3.5 py-2 sm:py-2.5 bg-black/30 hover:bg-black/50 text-amber-200 font-semibold text-xs rounded-xl border border-amber-400/30 transition-all flex items-center justify-center gap-1.5 active:scale-95"
              title={isHindi ? 'लाइव डेटा रिफ्रेश करें' : 'Refresh Live Metrics'}
            >
              <span>{loading ? '⏳' : '🔄'}</span>
              <span className="hidden sm:inline">{isHindi ? 'रिफ्रेश' : 'Refresh'}</span>
            </button>
          </div>
        </div>
      </div>

      {/* Real KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
        {metrics.map((m, idx) => {
          const content = (
            <div className="bg-white rounded-xl sm:rounded-2xl border border-gray-100 p-3.5 sm:p-5 shadow-sm hover:shadow-md transition-all group flex flex-col justify-between h-full">
              <div>
                <div className="flex items-center justify-between mb-2 sm:mb-3">
                  <span className="text-[10px] sm:text-xs font-semibold text-gray-500 tracking-wide uppercase line-clamp-1">
                    {m.title}
                  </span>
                  <div
                    className={`w-7 h-7 sm:w-9 sm:h-9 rounded-xl bg-gradient-to-br ${m.color} text-white flex items-center justify-center text-xs sm:text-base shadow-sm shrink-0 group-hover:scale-110 transition-transform`}
                  >
                    {m.icon}
                  </div>
                </div>
                <div className="text-base sm:text-xl md:text-2xl font-extrabold text-gray-900 font-cinzel tracking-tight truncate">
                  {loading ? '—' : m.value}
                </div>
              </div>

              <div className="mt-3 pt-2.5 border-t border-gray-50 flex items-center justify-between text-[10px] sm:text-xs">
                <span className="text-gray-400 truncate max-w-[120px] sm:max-w-none">{m.sub}</span>
                <span className="font-semibold text-emerald-600 bg-emerald-50 px-1.5 py-0.5 rounded shrink-0">
                  {m.change}
                </span>
              </div>
            </div>
          );

          return m.href ? (
            <Link key={idx} href={m.href} className="block transition-transform hover:-translate-y-0.5">
              {content}
            </Link>
          ) : (
            <div key={idx}>{content}</div>
          );
        })}
      </div>

      {/* Real Production Queues: Recent Bookings & Astrologer Consultations */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
        {/* Recent Devotee Sankalps & Bookings */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 sm:p-6 flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-sm sm:text-base font-bold font-cinzel text-gray-900 flex items-center gap-2">
                  <span>📜</span> {isHindi ? 'नवीनतम भक्त संकल्प एवं बुकिंग' : 'Recent Devotee Sankalps & Bookings'}
                </h2>
                <p className="text-[11px] text-gray-400 mt-0.5">
                  {isHindi ? 'सुपाबेस डेटाबेस से सीधी लाइव कतार' : 'Direct live feed from Supabase bookings table'}
                </p>
              </div>
              <Link
                href="/bookings"
                className="text-xs font-bold text-amber-700 hover:text-amber-800 bg-amber-50 hover:bg-amber-100 px-3 py-1.5 rounded-xl transition-colors shrink-0"
              >
                {isHindi ? 'सभी देखें →' : 'View All →'}
              </Link>
            </div>

            {loading ? (
              <div className="py-12 text-center text-xs text-gray-400">
                {isHindi ? 'डेटाबेस से लोड हो रहा है...' : 'Loading bookings from database...'}
              </div>
            ) : recentBookings.length === 0 ? (
              <div className="py-12 text-center text-xs text-gray-400 bg-gray-50 rounded-xl border border-dashed border-gray-200">
                {isHindi ? 'डेटाबेस में कोई बुकिंग दर्ज नहीं है।' : 'No bookings in database yet.'}
              </div>
            ) : (
              <div className="space-y-2.5">
                {recentBookings.map((b) => (
                  <div
                    key={b.id}
                    className="p-3 rounded-xl border border-gray-100 hover:border-amber-200 hover:bg-amber-50/20 transition-all flex items-center justify-between gap-3 text-xs"
                  >
                    <div className="min-w-0">
                      <div className="font-bold text-gray-900 truncate">
                        {b.sankalp_name || b.user_name || (isHindi ? 'अनाम भक्त' : 'Devotee')}
                        {b.sankalp_gotra && (
                          <span className="ml-1 text-[10px] font-normal text-amber-800 bg-amber-100/70 px-1.5 py-0.5 rounded">
                            {b.sankalp_gotra}
                          </span>
                        )}
                      </div>
                      <div className="text-[11px] text-gray-500 truncate mt-0.5">
                        {b.puja_title} • <span className="text-gray-700">{b.temple_name}</span>
                      </div>
                    </div>

                    <div className="text-right shrink-0">
                      <div className="font-bold text-mandir-maroon">
                        ₹ {Number(b.amount || 0).toLocaleString('en-IN')}
                      </div>
                      <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full inline-block mt-0.5 bg-emerald-100 text-emerald-800">
                        {b.status || (isHindi ? 'सफल' : 'Confirmed')}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Recent Astrologer Consultations */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 sm:p-6 flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-sm sm:text-base font-bold font-cinzel text-gray-900 flex items-center gap-2">
                  <span>💬</span> {isHindi ? 'नवीनतम पंडित परामर्श एवं संवाद' : 'Recent Pandit Consultations & Chats'}
                </h2>
                <p className="text-[11px] text-gray-400 mt-0.5">
                  {isHindi ? 'लाइव परामर्श सत्र एवं वार्ता' : 'Live astrological sessions & audio/chat consultations'}
                </p>
              </div>
              <Link
                href="/consultations"
                className="text-xs font-bold text-amber-700 hover:text-amber-800 bg-amber-50 hover:bg-amber-100 px-3 py-1.5 rounded-xl transition-colors shrink-0"
              >
                {isHindi ? 'सभी देखें →' : 'View All →'}
              </Link>
            </div>

            {loading ? (
              <div className="py-12 text-center text-xs text-gray-400">
                {isHindi ? 'डेटाबेस से लोड हो रहा है...' : 'Loading consultations from database...'}
              </div>
            ) : recentConsultations.length === 0 ? (
              <div className="py-12 text-center text-xs text-gray-400 bg-gray-50 rounded-xl border border-dashed border-gray-200">
                {isHindi ? 'डेटाबेस में कोई परामर्श सत्र नहीं मिला।' : 'No consultations in database yet.'}
              </div>
            ) : (
              <div className="space-y-2.5">
                {recentConsultations.map((c) => (
                  <div
                    key={c.id}
                    className="p-3 rounded-xl border border-gray-100 hover:border-indigo-200 hover:bg-indigo-50/20 transition-all flex items-center justify-between gap-3 text-xs"
                  >
                    <div className="min-w-0">
                      <div className="font-bold text-gray-900 truncate">
                        {c.user_name || (isHindi ? 'अनाम भक्त' : 'Devotee')}
                        <span className="text-gray-400 font-normal mx-1">→</span>
                        <span className="text-indigo-800 font-semibold">{c.astrologer_name}</span>
                      </div>
                      <div className="text-[11px] text-gray-500 truncate mt-0.5">
                        {c.type === 'chat' ? (isHindi ? '💬 चैट' : '💬 Live Chat') : (isHindi ? '📞 कॉल' : '📞 Voice Call')} •{' '}
                        {c.duration_minutes || 15} {isHindi ? 'मिनट' : 'mins'}
                      </div>
                    </div>

                    <div className="text-right shrink-0">
                      <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full inline-block bg-blue-100 text-blue-800">
                        {c.status || (isHindi ? 'सक्रिय' : 'Active')}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
