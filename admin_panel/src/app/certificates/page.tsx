'use client';

import { useState, useEffect, useCallback } from 'react';

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
}: {
  item: Booking;
  type: CertType;
  backendUrl: string;
}) {
  const devoteeName = item.sankalp_name || item.devotee_name || item.user_name || 'Devotee';
  const serviceTitle = item.puja_title || item.offering_title || 'Sacred Ritual';
  const certUrl = `${backendUrl}/api/v1/certificates/${type}/${item.id}`;

  let dateStr = '—';
  try {
    dateStr = new Date(item.created_at).toLocaleDateString('en-IN', {
      day: '2-digit', month: 'long', year: 'numeric',
    });
  } catch { /* ignore */ }

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
            {type === 'puja' ? '🪔 Puja' : '🌸 Chadhawa'}
          </span>
          <span className="text-xs font-mono text-gray-400">{item.id.slice(-8).toUpperCase()}</span>
        </div>

        {/* Devotee */}
        <h3 className="text-base font-bold text-gray-900 mb-1">{devoteeName}</h3>
        <p className="text-sm text-orange-700 font-semibold line-clamp-1 mb-1">{serviceTitle}</p>
        <p className="text-xs text-gray-500 mb-0.5">🏛 {item.temple_name}</p>
        <p className="text-xs text-gray-400">📅 {dateStr}</p>

        {/* Status */}
        {item.status && (
          <span className="inline-block mt-2 px-2 py-0.5 rounded-full bg-green-100 text-green-700 text-xs font-semibold">
            ✅ {item.status}
          </span>
        )}

        {/* Action buttons */}
        <div className="flex gap-2 mt-4">
          <a
            href={certUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="flex-1 py-2 bg-amber-600 hover:bg-amber-700 text-white text-xs font-bold rounded-xl text-center transition-colors flex items-center justify-center gap-1.5"
          >
            👁 Preview
          </a>
          <a
            href={certUrl}
            download={`certificate_${item.id}.svg`}
            className="flex-1 py-2 bg-gradient-to-r from-orange-600 to-red-700 hover:opacity-90 text-white text-xs font-bold rounded-xl text-center transition-opacity flex items-center justify-center gap-1.5"
          >
            ⬇ Download
          </a>
        </div>
      </div>
    </div>
  );
}

// ─── Main Certificates Page ───────────────────────────────────────────────────
export default function CertificatesPage() {
  const [pujaBookings, setPujaBookings] = useState<Booking[]>([]);
  const [chadhawaOrders, setChadhawaOrders] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<CertType>('puja');
  const [search, setSearch] = useState('');

  const API_BASE = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000';
  const ADMIN_TOKEN =
    typeof window !== 'undefined' ? localStorage.getItem('adminToken') || '' : '';

  // ─── Demo seed data (used when backend unavailable) ─────────────────────────
  const DEMO_PUJA: Booking[] = [
    { id: 'booking_demo01', puja_title: 'Pitru Dosh Shanti Mahapuja', temple_name: 'Ganga Ghat, Haridwar', sankalp_name: 'Ramesh Kumar Sharma', created_at: new Date().toISOString(), status: 'Completed', amount: 2100 },
    { id: 'booking_demo02', puja_title: 'Mahakal Rudrabhishek Puja', temple_name: 'Mahakaleshwar, Ujjain', sankalp_name: 'Priya Agarwal', created_at: new Date().toISOString(), status: 'Completed', amount: 1100 },
    { id: 'booking_demo03', puja_title: 'Satyanarayan Katha & Puja', temple_name: 'Siddhivinayak, Mumbai', sankalp_name: 'Sunita Joshi', created_at: new Date().toISOString(), status: 'Completed', amount: 5100 },
  ];
  const DEMO_CHADHAWA: Booking[] = [
    { id: 'chadhawa_ord_demo01', offering_title: 'Mahakal Special Chadava', temple_name: 'Mahakaleshwar, Ujjain', devotee_name: 'Ankit Verma', created_at: new Date().toISOString(), status: 'Offered at Temple Sanctuary', amount: 251 },
    { id: 'chadhawa_ord_demo02', offering_title: 'Vishnu Sahasranam Path', temple_name: 'Tirupati Balaji', devotee_name: 'Kavitha Nair', created_at: new Date().toISOString(), status: 'Offered at Temple Sanctuary', amount: 501 },
  ];

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const headers = { Authorization: `Bearer ${ADMIN_TOKEN}` };
      const [pujaRes, chaRes] = await Promise.all([
        fetch(`${API_BASE}/api/v1/bookings?limit=100`, { headers }),
        fetch(`${API_BASE}/api/v1/chadhawa/user/orders?limit=100`, { headers }),
      ]);
      const pujaData = pujaRes.ok ? await pujaRes.json() : { data: DEMO_PUJA };
      const chaData = chaRes.ok ? await chaRes.json() : { data: DEMO_CHADHAWA };
      setPujaBookings(pujaData.data || DEMO_PUJA);
      setChadhawaOrders(chaData.data || DEMO_CHADHAWA);
    } catch {
      setPujaBookings(DEMO_PUJA);
      setChadhawaOrders(DEMO_CHADHAWA);
    } finally {
      setLoading(false);
    }
  }, [API_BASE, ADMIN_TOKEN]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const activeList = activeTab === 'puja' ? pujaBookings : chadhawaOrders;
  const filtered = activeList.filter((item) => {
    if (!search) return true;
    const q = search.toLowerCase();
    const name = (item.sankalp_name || item.devotee_name || item.user_name || '').toLowerCase();
    const title = (item.puja_title || item.offering_title || '').toLowerCase();
    const temple = (item.temple_name || '').toLowerCase();
    return name.includes(q) || title.includes(q) || temple.includes(q) || item.id.toLowerCase().includes(q);
  });

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 to-orange-50/30">
      <div className="max-w-6xl mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
            <span className="text-3xl">📜</span> Sacred Certificates
          </h1>
          <p className="text-gray-500 mt-1">
            Preview & download participation certificates for all Puja bookings and Chadhawa offerings
          </p>
        </div>

        {/* Info Banner */}
        <div className="bg-amber-50 border border-amber-200 rounded-2xl p-4 mb-7 flex items-start gap-4">
          <div className="text-2xl">✨</div>
          <div>
            <p className="text-sm font-semibold text-amber-900">Auto-Generated SVG Certificates</p>
            <p className="text-xs text-amber-700 mt-0.5">
              Each certificate is dynamically generated with the devotee name, ritual title, temple, and date.
              Certificates are available for all completed bookings and are downloadable as high-quality SVG files.
              Devotees can also download their certificates directly from the <strong>Mandiram mobile app</strong>.
            </p>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex gap-3 mb-6">
          <button
            onClick={() => setActiveTab('puja')}
            className={`flex items-center gap-2 px-5 py-2.5 rounded-xl font-semibold text-sm transition-all ${
              activeTab === 'puja'
                ? 'bg-orange-600 text-white shadow-md'
                : 'bg-white text-gray-600 border border-gray-200 hover:border-orange-300'
            }`}
          >
            🪔 Puja Certificates
            <span
              className={`px-2 py-0.5 rounded-full text-xs font-bold ${
                activeTab === 'puja' ? 'bg-white/20 text-white' : 'bg-gray-100 text-gray-600'
              }`}
            >
              {pujaBookings.length}
            </span>
          </button>
          <button
            onClick={() => setActiveTab('chadhawa')}
            className={`flex items-center gap-2 px-5 py-2.5 rounded-xl font-semibold text-sm transition-all ${
              activeTab === 'chadhawa'
                ? 'bg-purple-700 text-white shadow-md'
                : 'bg-white text-gray-600 border border-gray-200 hover:border-purple-300'
            }`}
          >
            🌸 Chadhawa Certificates
            <span
              className={`px-2 py-0.5 rounded-full text-xs font-bold ${
                activeTab === 'chadhawa' ? 'bg-white/20 text-white' : 'bg-gray-100 text-gray-600'
              }`}
            >
              {chadhawaOrders.length}
            </span>
          </button>
        </div>

        {/* Search */}
        <div className="relative mb-6">
          <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
          <input
            type="text"
            placeholder="Search by devotee name, puja title, temple..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-11 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-400 text-sm shadow-sm"
          />
        </div>

        {/* Grid */}
        {loading ? (
          <div className="flex items-center justify-center py-24">
            <div className="w-10 h-10 border-4 border-amber-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="text-center py-24">
            <div className="text-6xl mb-4">📜</div>
            <h3 className="text-xl font-bold text-gray-700 mb-2">No certificates found</h3>
            <p className="text-gray-500">Completed bookings and offerings will appear here</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filtered.map((item) => (
              <CertCard
                key={item.id}
                item={item}
                type={activeTab}
                backendUrl={API_BASE}
              />
            ))}
          </div>
        )}

        {/* Developer note */}
        <div className="mt-10 p-4 bg-gray-100 rounded-xl text-xs text-gray-500">
          <strong>Developer Note:</strong> Certificate endpoint:{' '}
          <code className="bg-white px-1.5 py-0.5 rounded font-mono">
            GET /api/v1/certificates/{'{puja|chadhawa}'}/{'{id}'}
          </code>{' '}
          — Returns SVG with{' '}
          <code className="bg-white px-1.5 py-0.5 rounded font-mono">Content-Disposition: attachment</code>.
          Flutter app uses <code className="bg-white px-1.5 py-0.5 rounded font-mono">url_launcher</code> to open the download link.
        </div>
      </div>
    </div>
  );
}
