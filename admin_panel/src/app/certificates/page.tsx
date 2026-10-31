'use client';

import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

interface Booking {
  id: string;
  puja_title?: string;
  offering_title?: string;
  temple_name: string;
  sankalp_name?: string;
  devotee_name?: string;
  user_name?: string;
  created_at: string;
  status?: string;
  amount?: number;
}

type CertType = 'puja' | 'chadhawa';

// ─── Certificate Preview Card ─────────────────────────────────────────────────
function CertCard({
  item,
  type,
  backendUrl,
  isHindi,
}: {
  item: Booking;
  type: CertType;
  backendUrl: string;
  isHindi: boolean;
}) {
  const devoteeName = item.sankalp_name || item.devotee_name || item.user_name || (isHindi ? 'भक्त' : 'Devotee');
  const serviceTitle = item.puja_title || item.offering_title || (isHindi ? 'पवित्र अनुष्ठान' : 'Sacred Ritual');
  const certUrl = `${backendUrl}/api/v1/certificates/${type}/${item.id}`;

  let dateStr = '—';
  try {
    dateStr = new Date(item.created_at).toLocaleDateString(isHindi ? 'hi-IN' : 'en-IN', {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
    });
  } catch {
    /* ignore */
  }

  return (
    <div className="bg-white rounded-2xl border border-amber-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow group">
      {/* Top stripe */}
      <div className="h-2 bg-gradient-to-r from-amber-600 via-yellow-500 to-amber-600" />

      <div className="p-5">
        {/* Type badge */}
        <div className="flex items-center justify-between mb-3">
          <span
            className={`px-2.5 py-1 rounded-lg text-xs font-bold ${
              type === 'puja'
                ? 'bg-orange-100 text-orange-800'
                : 'bg-purple-100 text-purple-800'
            }`}
          >
            {type === 'puja' ? (isHindi ? '🪔 पूजा' : '🪔 Puja') : (isHindi ? '🌸 चढ़ावा' : '🌸 Chadhawa')}
          </span>
          <span className="text-xs font-mono text-gray-400">
            {item.id.slice(-8).toUpperCase()}
          </span>
        </div>

        {/* Devotee info */}
        <h3 className="font-bold text-gray-900 text-base leading-snug group-hover:text-amber-800 transition-colors">
          {devoteeName}
        </h3>
        <p className="text-xs text-amber-700 font-medium mt-0.5">{serviceTitle}</p>
        <p className="text-xs text-gray-400 mt-1 flex items-center gap-1">
          <span>🛕</span>
          <span>{item.temple_name || (isHindi ? 'पवित्र गर्भगृह' : 'Sacred Sanctum')}</span>
        </p>

        {/* Date & Amount */}
        <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
          <span>{dateStr}</span>
          {item.amount != null && (
            <span className="font-bold text-gray-800">
              ₹{Number(item.amount).toLocaleString('en-IN')}
            </span>
          )}
        </div>

        {/* Actions */}
        <div className="mt-4 flex gap-2">
          <a
            href={certUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex-1 py-2 bg-amber-600 hover:bg-amber-700 text-white text-xs font-bold rounded-xl text-center transition-colors flex items-center justify-center gap-1.5"
          >
            👁 {isHindi ? 'पूर्वावलोकन' : 'Preview'}
          </a>
          <a
            href={certUrl}
            download={`certificate_${item.id}.svg`}
            className="flex-1 py-2 bg-gradient-to-r from-orange-600 to-red-700 hover:opacity-90 text-white text-xs font-bold rounded-xl text-center transition-opacity flex items-center justify-center gap-1.5"
          >
            ⬇ {isHindi ? 'डाउनलोड' : 'Download'}
          </a>
        </div>
      </div>
    </div>
  );
}

// ─── Main Certificates Page ───────────────────────────────────────────────────
export default function CertificatesPage() {
  const { isHindi } = useAdminLanguage();
  const [pujaBookings, setPujaBookings] = useState<Booking[]>([]);
  const [chadhawaOrders, setChadhawaOrders] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<CertType>('puja');
  const [search, setSearch] = useState('');

  const API_BASE =
    process.env.NEXT_PUBLIC_BACKEND_URL ||
    (process.env.NEXT_PUBLIC_API_URL ? process.env.NEXT_PUBLIC_API_URL.replace(/\/api\/v1\/?$/, '') : '') ||
    'https://api.mandirm.in';

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      // Direct production queries to Supabase database (no mock fallbacks)
      const [bookingsRes, ordersRes] = await Promise.all([
        supabase.from('bookings').select('*').order('created_at', { ascending: false }).limit(100),
        supabase.from('orders').select('*').order('created_at', { ascending: false }).limit(100),
      ]);

      const pujas = (bookingsRes.data || []) as Booking[];
      const chadhawas = (ordersRes.data || []).map((o: any) => ({
        id: o.id,
        offering_title: o.items?.[0]?.name || (isHindi ? 'मंदिर चढ़ावा एवं अर्पण' : 'Temple Chadhawa Offering'),
        temple_name: o.temple_name || (isHindi ? 'पवित्र मंदिर' : 'Sacred Sanctum'),
        devotee_name: o.user_name || o.shipping_name || (isHindi ? 'भक्त' : 'Devotee'),
        created_at: o.created_at,
        status: o.order_status,
        amount: o.total_amount,
      })) as Booking[];

      setPujaBookings(pujas);
      setChadhawaOrders(chadhawas);
    } catch (err) {
      console.error('Error fetching certificates data:', err);
      setPujaBookings([]);
      setChadhawaOrders([]);
    } finally {
      setLoading(false);
    }
  }, [isHindi]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const currentList = activeTab === 'puja' ? pujaBookings : chadhawaOrders;
  const filtered = currentList.filter((b) => {
    const q = search.toLowerCase();
    const name = (b.sankalp_name || b.devotee_name || b.user_name || '').toLowerCase();
    const title = (b.puja_title || b.offering_title || '').toLowerCase();
    const temple = (b.temple_name || '').toLowerCase();
    return name.includes(q) || title.includes(q) || temple.includes(q) || b.id.toLowerCase().includes(q);
  });

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-4">
        <div>
          <h1 className="text-lg sm:text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>📜</span> {isHindi ? 'पवित्र सहभागिता प्रमाण पत्र' : 'Sacred Participation Certificates'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'सुपाबेस डेटाबेस से सीधे प्राप्त वास्तविक अनुष्ठान एवं चढ़ावा प्रमाण पत्र'
              : 'Real participation certificates generated from production database bookings'}
          </p>
        </div>

        <button
          onClick={fetchData}
          disabled={loading}
          className="px-3.5 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold rounded-xl flex items-center justify-center gap-1.5 transition-colors"
        >
          <span>{loading ? '⏳' : '🔄'}</span>
          <span>{isHindi ? 'रिफ्रेश' : 'Refresh'}</span>
        </button>
      </div>

      {/* Tabs & Search */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
        {/* Tabs */}
        <div className="flex gap-2 p-1 bg-gray-100 rounded-xl w-fit">
          <button
            onClick={() => setActiveTab('puja')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors ${
              activeTab === 'puja'
                ? 'bg-white text-orange-800 shadow-sm'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            {isHindi ? `🪔 पूजा प्रमाण पत्र (${pujaBookings.length})` : `🪔 Puja Certificates (${pujaBookings.length})`}
          </button>
          <button
            onClick={() => setActiveTab('chadhawa')}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition-colors ${
              activeTab === 'chadhawa'
                ? 'bg-white text-purple-800 shadow-sm'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            {isHindi ? `🌸 चढ़ावा प्रमाण पत्र (${chadhawaOrders.length})` : `🌸 Chadhawa Certificates (${chadhawaOrders.length})`}
          </button>
        </div>

        {/* Search */}
        <div className="relative max-w-xs w-full">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">
            🔍
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={isHindi ? 'भक्त, पूजा या मंदिर से खोजें...' : 'Search by devotee, ritual or temple...'}
            className="w-full pl-8 pr-3 py-2 bg-white border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-amber-500"
          />
        </div>
      </div>

      {/* Grid of Certificates */}
      {loading ? (
        <div className="py-24 text-center text-xs text-gray-400">
          {isHindi ? 'डेटाबेस से लोड हो रहा है...' : 'Loading certificates from database...'}
        </div>
      ) : filtered.length === 0 ? (
        <div className="py-24 text-center bg-white rounded-2xl border border-dashed border-gray-200 p-8">
          <div className="text-4xl mb-3">📜</div>
          <h3 className="text-sm font-bold text-gray-800">
            {isHindi ? 'कोई रिकॉर्ड नहीं मिला' : 'No records found'}
          </h3>
          <p className="text-xs text-gray-500 mt-1 max-w-sm mx-auto">
            {isHindi
              ? 'वर्तमान में कोई बुकिंग या अर्पण दर्ज नहीं है।'
              : 'There are currently no confirmed bookings in the database.'}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((item) => (
            <CertCard
              key={item.id}
              item={item}
              type={activeTab}
              backendUrl={API_BASE}
              isHindi={isHindi}
            />
          ))}
        </div>
      )}
    </div>
  );
}
