'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface Astrologer {
  id: string;
  name: string;
  title: string;
  bio?: string;
  experience_years: number;
  per_minute_chat_rate: number;
  per_minute_call_rate: number;
  specialities?: string;
  languages?: string;
  rating: number;
  consultations_count: number;
  is_online: boolean;
  avatar_url?: string;
  phone?: string;
  created_at: string;
}

const REAL_ASTRO_IMAGES: Record<string, string> = {
  astro_1: '/images/astrologers/astro_1.jpg',
  astro_2: '/images/astrologers/astro_2.jpg',
  astro_3: '/images/astrologers/astro_3.jpg',
  astro_4: '/images/astrologers/astro_4.jpg',
  astro_5: '/images/astrologers/astro_5.jpg',
};

const getAstrologerImage = (astro: Astrologer) => {
  if (REAL_ASTRO_IMAGES[astro.id]) return REAL_ASTRO_IMAGES[astro.id];
  if (astro.avatar_url && !astro.avatar_url.includes('unsplash.com')) return astro.avatar_url;
  const hash = Math.abs(astro.id.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0));
  const index = (hash % 5) + 1;
  return `/images/astrologers/astro_${index}.jpg`;
};

export default function AstrologersPage() {
  const [astrologers, setAstrologers] = useState<Astrologer[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState<string | null>(null);
  const [editingAstro, setEditingAstro] = useState<Astrologer | null>(null);
  const [showModal, setShowModal] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    title: '',
    specialities: 'Vedic Astrology, Kundli Milan',
    languages: 'Hindi, English, Sanskrit',
    experience_years: 10,
    per_minute_chat_rate: 21,
    per_minute_call_rate: 35,
    phone: '',
    rating: 4.9,
    consultations_count: 500,
    is_online: true,
  });

  useEffect(() => {
    fetchAstrologers();
  }, []);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  };

  const fetchAstrologers = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('astrologers')
        .select('*')
        .order('rating', { ascending: false });

      if (error) {
        console.error('Error fetching astrologers:', error);
      } else {
        setAstrologers((data as Astrologer[]) || []);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleOnline = async (id: string, current: boolean) => {
    try {
      const { error } = await supabase
        .from('astrologers')
        .update({ is_online: !current })
        .eq('id', id);

      if (error) {
        showToast(`Failed: ${error.message}`);
      } else {
        showToast(`Updated astrologer status`);
        setAstrologers(
          astrologers.map((a) => (a.id === id ? { ...a, is_online: !current } : a))
        );
      }
    } catch (err: any) {
      showToast(`Error: ${err.message}`);
    }
  };

  const handleSaveAstrologer = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.title.trim()) {
      showToast('Name and Vedic Title are required');
      return;
    }

    try {
      const payload = {
        id: editingAstro?.id || `ast_${Date.now()}`,
        name: formData.name.trim(),
        title: formData.title.trim(),
        specialities: formData.specialities,
        languages: formData.languages,
        experience_years: Number(formData.experience_years) || 5,
        per_minute_chat_rate: Number(formData.per_minute_chat_rate) || 21,
        per_minute_call_rate: Number(formData.per_minute_call_rate) || 35,
        phone: formData.phone.trim() || '+91 98000 00000',
        rating: Number(formData.rating) || 4.9,
        consultations_count: Number(formData.consultations_count) || 108,
        is_online: formData.is_online,
      };

      const { error } = await supabase.from('astrologers').upsert(payload);

      if (error) {
        showToast(`Error: ${error.message}`);
      } else {
        showToast(editingAstro ? 'Astrologer updated!' : 'Astrologer registered!');
        setShowModal(false);
        setEditingAstro(null);
        fetchAstrologers();
      }
    } catch (err: any) {
      showToast(`Error: ${err.message}`);
    }
  };

  const filtered = astrologers.filter(
    (a) =>
      a.name.toLowerCase().includes(search.toLowerCase()) ||
      (a.specialities || '').toLowerCase().includes(search.toLowerCase()) ||
      (a.title || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Toast */}
      {toast && (
        <div className="fixed top-20 right-6 z-50 bg-mandir-maroon text-amber-200 px-4 py-2.5 rounded-xl shadow-2xl border border-amber-400/40 text-xs font-semibold flex items-center gap-2 animate-bounce">
          <span>✓</span>
          <span>{toast}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-4">
        <div>
          <h1 className="text-lg sm:text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🧘‍♂️</span> Verified Astrologers & Acharyas
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Live Supabase database • Regulate per-minute Dakshina rates, online presence, and KYC credentials
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2 w-full sm:w-auto">
          <button
            onClick={fetchAstrologers}
            disabled={loading}
            className="flex-1 sm:flex-none justify-center px-3 py-2 sm:py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>Refresh</span>
          </button>
          <button
            onClick={() => {
              setEditingAstro(null);
              setFormData({
                name: '',
                title: 'Vedic Jyotish Acharya',
                specialities: 'Vedic Astrology, Kundli Milan, Prashna Kundli',
                languages: 'Hindi, English, Sanskrit',
                experience_years: 12,
                per_minute_chat_rate: 25,
                per_minute_call_rate: 35,
                phone: '',
                rating: 4.95,
                consultations_count: 500,
                is_online: true,
              });
              setShowModal(true);
            }}
            className="flex-1 sm:flex-none justify-center px-3.5 py-2 sm:py-1.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-amber-200 font-bold text-xs rounded-xl shadow transition-all flex items-center gap-1.5"
          >
            <span>+</span> Register Astrologer
          </button>
        </div>
      </div>

      {/* Search Toolbar */}
      <div className="bg-white p-3.5 sm:p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">
            🔍
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by name, specialty, or title..."
            className="w-full pl-8 pr-3 py-2 sm:py-1.5 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>
        <div className="text-xs font-bold text-indigo-900 bg-indigo-50 px-3 py-1.5 rounded-xl border border-indigo-100 w-fit">
          {astrologers.filter((a) => a.is_online).length} Currently Online
        </div>
      </div>

      {/* Astrologers Grid */}
      {loading ? (
        <div className="py-20 text-center text-gray-400 text-xs">
          <span className="text-3xl block mb-2 animate-spin">⏳</span>
          <span>Loading live astrologer catalog from database...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-100 p-8 sm:p-12 text-center text-gray-400 text-xs">
          <span className="text-4xl block mb-2">🧘‍♂️</span>
          <p className="font-semibold text-gray-700">No astrologers found in database</p>
          <p className="mt-1 text-[11px]">
            Click &ldquo;+ Register Astrologer&rdquo; above to onboard your first Vedic scholar.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
          {filtered.map((a) => (
            <div
              key={a.id}
              className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm hover:shadow-md transition-all space-y-4"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-500 to-mandir-maroon text-white font-bold flex items-center justify-center text-lg shadow-sm overflow-hidden shrink-0">
                    <img
                      src={getAstrologerImage(a)}
                      alt={a.name}
                      className="w-full h-full object-cover rounded-xl"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src = '/images/astrologers/astro_1.jpg';
                      }}
                    />
                  </div>
                  <div>
                    <h3 className="font-bold text-gray-900 text-sm">{a.name}</h3>
                    <p className="text-[11px] text-gray-500">{a.title}</p>
                  </div>
                </div>

                {/* Online Toggle */}
                <button
                  onClick={() => toggleOnline(a.id, a.is_online)}
                  className={`px-2.5 py-1 rounded-full text-[10px] font-semibold transition-all ${
                    a.is_online
                      ? 'bg-emerald-100 text-emerald-800 border border-emerald-200'
                      : 'bg-gray-100 text-gray-500 border border-gray-200'
                  }`}
                >
                  {a.is_online ? '● Online' : '○ Offline'}
                </button>
              </div>

              {/* Specialties & Languages */}
              <div className="text-xs space-y-1">
                <div className="text-gray-600">
                  <strong>Specialities:</strong> {a.specialities || 'Vedic Astrology'}
                </div>
                <div className="text-gray-500 text-[11px]">
                  <strong>Languages:</strong> {a.languages || 'Hindi, Sanskrit'}
                </div>
              </div>

              {/* Rates & Stats */}
              <div className="grid grid-cols-2 gap-2 p-2.5 bg-gray-50 rounded-xl text-center text-xs">
                <div>
                  <span className="text-[10px] text-gray-400 block uppercase font-semibold">Chat Rate</span>
                  <span className="font-bold text-gray-900 font-cinzel">₹ {a.per_minute_chat_rate} / min</span>
                </div>
                <div>
                  <span className="text-[10px] text-gray-400 block uppercase font-semibold">Call Rate</span>
                  <span className="font-bold text-gray-900 font-cinzel">₹ {a.per_minute_call_rate} / min</span>
                </div>
              </div>

              <div className="flex items-center justify-between text-xs pt-1 border-t border-gray-100 text-gray-500">
                <span>⭐ {a.rating || 4.9} ({a.consultations_count || 108} sessions)</span>
                <button
                  onClick={() => {
                    setEditingAstro(a);
                    setFormData({
                      name: a.name,
                      title: a.title,
                      specialities: a.specialities || '',
                      languages: a.languages || '',
                      experience_years: a.experience_years,
                      per_minute_chat_rate: a.per_minute_chat_rate,
                      per_minute_call_rate: a.per_minute_call_rate,
                      phone: a.phone || '',
                      rating: a.rating,
                      consultations_count: a.consultations_count,
                      is_online: a.is_online,
                    });
                    setShowModal(true);
                  }}
                  className="text-amber-800 hover:text-amber-900 font-semibold text-[11px]"
                >
                  Edit Rates & Info →
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Edit/Create Modal */}
      {showModal && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-3 sm:p-4">
          <div className="bg-white rounded-2xl sm:rounded-3xl max-w-lg w-full p-4 sm:p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3">
              <h2 className="text-base font-bold font-cinzel text-gray-900">
                {editingAstro ? 'Edit Astrologer Details' : 'Register New Astrologer'}
              </h2>
              <button
                onClick={() => setShowModal(false)}
                className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-gray-500"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveAstrologer} className="space-y-3 text-xs">
              <div>
                <label className="block font-semibold text-gray-700 mb-1">Full Name</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g. Pandit Radheshyam Shastri"
                  className="w-full p-2 border border-gray-200 rounded-lg text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Vedic Title / Honors</label>
                <input
                  type="text"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="e.g. Jyotish Acharya & Gold Medalist"
                  className="w-full p-2 border border-gray-200 rounded-lg text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Chat Rate (₹ / min)</label>
                  <input
                    type="number"
                    required
                    value={formData.per_minute_chat_rate}
                    onChange={(e) =>
                      setFormData({ ...formData, per_minute_chat_rate: Number(e.target.value) })
                    }
                    className="w-full p-2 border border-gray-200 rounded-lg text-xs"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-gray-700 mb-1">Call Rate (₹ / min)</label>
                  <input
                    type="number"
                    required
                    value={formData.per_minute_call_rate}
                    onChange={(e) =>
                      setFormData({ ...formData, per_minute_call_rate: Number(e.target.value) })
                    }
                    className="w-full p-2 border border-gray-200 rounded-lg text-xs"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Specialties</label>
                <input
                  type="text"
                  value={formData.specialities}
                  onChange={(e) => setFormData({ ...formData, specialities: e.target.value })}
                  placeholder="Kundli Milan, Vastu, Prashna Kundli"
                  className="w-full p-2 border border-gray-200 rounded-lg text-xs"
                />
              </div>

              <div>
                <label className="block font-semibold text-gray-700 mb-1">Languages</label>
                <input
                  type="text"
                  value={formData.languages}
                  onChange={(e) => setFormData({ ...formData, languages: e.target.value })}
                  placeholder="Hindi, English, Gujarati"
                  className="w-full p-2 border border-gray-200 rounded-lg text-xs"
                />
              </div>

              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="onlineCheck"
                  checked={formData.is_online}
                  onChange={(e) => setFormData({ ...formData, is_online: e.target.checked })}
                  className="rounded text-mandir-maroon"
                />
                <label htmlFor="onlineCheck" className="text-gray-700 font-semibold">
                  Enable Online Status Immediately
                </label>
              </div>

              <div className="flex justify-end gap-2 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-mandir-maroon hover:bg-mandir-maroon-dark text-amber-200 font-bold shadow"
                >
                  Save Astrologer
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
