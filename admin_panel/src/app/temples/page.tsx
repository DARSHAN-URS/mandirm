'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface Temple {
  id: string;
  name: string;
  deity: string;
  city: string;
  state: string;
  address?: string;
  description: string;
  image_url: string;
  live_darshan_url?: string;
  darshan_timings: string;
  aarti_timings: string;
  is_featured: boolean;
  rating: number;
}

const TEMPLE_IMAGE_PRESETS = [
  { label: 'Kashi Vishwanath', url: 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=1200&q=80' },
  { label: 'Tirupati Balaji', url: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=1200&q=80' },
  { label: 'Siddhivinayak', url: 'https://images.unsplash.com/photo-1609358905596-f94632a67307?auto=format&fit=crop&w=1200&q=80' },
  { label: 'Mahakaleshwar', url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=1200&q=80' },
  { label: 'Vaishno Devi', url: 'https://images.unsplash.com/photo-1620766182966-c6eb5ed2b788?auto=format&fit=crop&w=1200&q=80' },
  { label: 'Somnath Dham', url: 'https://images.unsplash.com/photo-1590076212472-a7d1891b05ff?auto=format&fit=crop&w=1200&q=80' },
];

export default function TemplesPage() {
  const [temples, setTemples] = useState<Temple[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [search, setSearch] = useState('');
  const [selectedTemple, setSelectedTemple] = useState<Temple | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successToast, setSuccessToast] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form State
  const [formData, setFormData] = useState({
    name: '',
    deity: '',
    city: '',
    state: '',
    address: '',
    description: '',
    image_url: '',
    live_darshan_url: '',
    darshan_timings: '04:00 AM - 11:00 PM',
    aarti_timings: 'Mangala: 04:00 AM | Sandhya: 07:00 PM',
    is_featured: true,
  });

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    fetchTemples();
  }, []);

  const fetchTemples = async () => {
    setIsLoading(true);
    try {
      // 1. Try local API route
      const res = await fetch('/api/temples');
      const json = await res.json();
      if (json.success && Array.isArray(json.data) && json.data.length > 0) {
        setTemples(json.data);
      } else {
        // 2. Direct Supabase fallback
        const { data } = await supabase.from('temples').select('*').order('name');
        if (data && data.length > 0) {
          setTemples(data as Temple[]);
        }
      }
    } catch (e) {
      // Direct Supabase fallback
      const { data } = await supabase.from('temples').select('*').order('name');
      if (data && data.length > 0) {
        setTemples(data as Temple[]);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const showToast = (msg: string) => {
    setSuccessToast(msg);
    setTimeout(() => setSuccessToast(null), 3500);
  };

  const validateForm = () => {
    const errs: Record<string, string> = {};
    if (!formData.name.trim()) errs.name = 'Temple name is required';
    if (!formData.deity.trim()) errs.deity = 'Deity name is required';
    if (!formData.city.trim()) errs.city = 'City is required';
    if (!formData.state.trim()) errs.state = 'State is required';
    if (!formData.description.trim()) errs.description = 'Sanctum description is required';
    if (!formData.image_url.trim()) errs.image_url = 'Temple image URL is required';
    if (!formData.darshan_timings.trim()) errs.darshan_timings = 'Darshan timings are required';
    if (!formData.aarti_timings.trim()) errs.aarti_timings = 'Aarti timings are required';
    setFormErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsSubmitting(true);
    setErrorMsg(null);

    const payload = {
      ...(selectedTemple ? { id: selectedTemple.id } : { id: `temple_${Date.now()}` }),
      ...formData,
    };

    try {
      const res = await fetch('/api/temples', {
        method: selectedTemple ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save temple');

      showToast(selectedTemple ? 'Temple updated successfully in database!' : 'New sacred temple listed successfully!');
      setIsModalOpen(false);
      setSelectedTemple(null);
      fetchTemples();
    } catch (err: any) {
      // Direct fallback to Supabase upsert
      const { error: sbErr } = await supabase.from('temples').upsert(payload);
      if (!sbErr) {
        showToast('Temple saved to database!');
        setIsModalOpen(false);
        setSelectedTemple(null);
        fetchTemples();
      } else {
        setErrorMsg(err.message || sbErr.message || 'Error saving temple');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await fetch(`/api/temples?id=${id}`, { method: 'DELETE' });
      if (!res.ok) {
        await supabase.from('temples').delete().eq('id', id);
      }
      showToast('Temple listing removed.');
      setDeleteId(null);
      fetchTemples();
    } catch (_) {
      await supabase.from('temples').delete().eq('id', id);
      fetchTemples();
    }
  };

  const openAdd = () => {
    setSelectedTemple(null);
    setFormData({
      name: '',
      deity: '',
      city: '',
      state: '',
      address: '',
      description: '',
      image_url: '',
      live_darshan_url: '',
      darshan_timings: '04:00 AM - 11:00 PM',
      aarti_timings: 'Mangala: 04:00 AM | Sandhya: 07:00 PM',
      is_featured: true,
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const openEdit = (t: Temple) => {
    setSelectedTemple(t);
    setFormData({
      name: t.name,
      deity: t.deity,
      city: t.city,
      state: t.state,
      address: t.address || '',
      description: t.description || '',
      image_url: t.image_url || '',
      live_darshan_url: t.live_darshan_url || '',
      darshan_timings: t.darshan_timings || '04:00 AM - 11:00 PM',
      aarti_timings: t.aarti_timings || 'Mangala: 04:00 AM | Sandhya: 07:00 PM',
      is_featured: t.is_featured ?? true,
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const filtered = temples.filter(
    (t) =>
      t.name?.toLowerCase().includes(search.toLowerCase()) ||
      t.deity?.toLowerCase().includes(search.toLowerCase()) ||
      t.city?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Toast Notification */}
      {successToast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-700 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-3 border border-emerald-500 animate-bounce">
          <span className="text-lg">✨</span>
          <span className="text-xs font-bold">{successToast}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-gradient-to-r from-mandir-maroon-deep via-amber-950 to-mandir-maroon p-6 rounded-2xl text-white shadow-xl border border-amber-900/30">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="text-2xl">🛕</span>
            <h1 className="text-2xl font-bold font-cinzel tracking-wide text-amber-200">
              Sacred Temples & Sanctum Feeds
            </h1>
          </div>
          <p className="text-xs text-amber-100/80">
            Add and manage holy sanctums, live darshan streams, verified deity aartis, and descriptions.
          </p>
        </div>
        <button
          onClick={openAdd}
          className="px-5 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-amber-950 font-bold rounded-xl text-xs shadow-lg transition-all flex items-center gap-2 hover:scale-105 active:scale-95"
        >
          <span className="text-base font-extrabold">+</span> Add Sacred Temple
        </button>
      </div>

      {/* Filter and Stats Toolbar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-center justify-between gap-4 shadow-sm">
        <div className="relative w-full sm:w-96">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by temple name, deity, or holy city..."
            className="w-full pl-8 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
          />
        </div>
        <div className="flex items-center gap-4 text-xs font-medium text-gray-600">
          <span className="flex items-center gap-1.5 bg-emerald-50 text-emerald-800 px-3 py-1 rounded-full border border-emerald-200">
            <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
            <strong>{temples.filter((t) => t.live_darshan_url).length}</strong> Live Darshan Feeds
          </span>
          <span className="bg-amber-50 text-amber-900 px-3 py-1 rounded-full border border-amber-200">
            Total Temples: <strong>{temples.length}</strong>
          </span>
        </div>
      </div>

      {/* Loading Indicator */}
      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center space-y-3">
          <div className="w-10 h-10 border-4 border-mandir-maroon border-t-transparent rounded-full animate-spin"></div>
          <span className="text-xs font-semibold text-gray-500">Loading sacred temples from database...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-200 p-12 text-center space-y-3 shadow-sm">
          <span className="text-4xl block">🛕</span>
          <h3 className="font-cinzel text-base font-bold text-gray-800">No Temples Found</h3>
          <p className="text-xs text-gray-500 max-w-md mx-auto">
            {search ? 'No temples match your current search query.' : 'No sacred temples in the database yet. Click below to add the first one!'}
          </p>
          <button
            onClick={openAdd}
            className="px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl hover:bg-mandir-maroon-dark transition-all"
          >
            + Add First Temple
          </button>
        </div>
      ) : (
        /* Temples Grid */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map((t) => (
            <div
              key={t.id}
              className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden hover:shadow-lg transition-all flex flex-col justify-between group"
            >
              <div>
                {/* Temple Banner Image */}
                <div className="relative h-44 w-full bg-gray-100 overflow-hidden">
                  <img
                    src={t.image_url || 'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=600&q=80'}
                    alt={t.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src =
                        'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=600&q=80';
                    }}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

                  <div className="absolute top-3 left-3 flex gap-2">
                    <span className="text-[10px] font-bold text-amber-950 bg-amber-400 px-2.5 py-1 rounded-md uppercase tracking-wide shadow-md">
                      {t.deity}
                    </span>
                    {t.is_featured && (
                      <span className="text-[10px] font-bold text-white bg-mandir-maroon px-2 py-0.5 rounded-md shadow-md">
                        ★ Featured
                      </span>
                    )}
                  </div>

                  <div className="absolute top-3 right-3">
                    {t.live_darshan_url ? (
                      <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-500 text-white flex items-center gap-1 shadow-md">
                        <span className="w-1.5 h-1.5 rounded-full bg-white animate-pulse"></span> LIVE
                      </span>
                    ) : (
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-black/60 text-white/80 backdrop-blur-sm">
                        Offline
                      </span>
                    )}
                  </div>

                  <div className="absolute bottom-3 left-3 right-3 text-white">
                    <h3 className="font-bold text-sm font-cinzel text-white leading-tight drop-shadow-md">
                      {t.name}
                    </h3>
                    <p className="text-[11px] text-amber-200/90 flex items-center gap-1 mt-0.5">
                      📍 {t.city}, {t.state}
                    </p>
                  </div>
                </div>

                {/* Description & Timings */}
                <div className="p-4 space-y-2.5 text-xs">
                  <p className="text-gray-600 text-xs line-clamp-2 leading-relaxed italic">
                    "{t.description || 'Sacred temple sanctum revered by millions of devotees.'}"
                  </p>

                  <div className="pt-2 border-t border-gray-100 space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-gray-400 text-[10px] uppercase font-bold">Darshan Timings</span>
                      <span className="text-gray-800 font-semibold">{t.darshan_timings}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-gray-400 text-[10px] uppercase font-bold">Aarti Schedule</span>
                      <span className="text-gray-800 font-semibold text-[11px] truncate max-w-[200px]">
                        {t.aarti_timings}
                      </span>
                    </div>
                    {t.live_darshan_url && (
                      <div className="flex items-center justify-between pt-1 text-[11px]">
                        <span className="text-emerald-700 font-semibold flex items-center gap-1">
                          <span>🔴</span> Stream Live
                        </span>
                        <a
                          href={t.live_darshan_url}
                          target="_blank"
                          rel="noreferrer"
                          className="text-blue-600 hover:underline font-mono text-[10px] truncate max-w-[170px]"
                        >
                          {t.live_darshan_url}
                        </a>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="p-3 bg-gray-50 border-t border-gray-100 flex items-center justify-between">
                <span className="text-[11px] font-bold text-amber-700">⭐ {t.rating || 4.9} Rating</span>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setDeleteId(t.id)}
                    className="px-2.5 py-1 text-red-600 hover:bg-red-50 font-semibold text-xs rounded-lg transition-colors"
                  >
                    Delete
                  </button>
                  <button
                    onClick={() => openEdit(t)}
                    className="px-3 py-1 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white font-semibold text-xs rounded-lg transition-all shadow-sm"
                  >
                    Edit
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteId && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 text-center space-y-4 shadow-2xl">
            <span className="text-3xl block">⚠️</span>
            <h3 className="font-bold text-base text-gray-900 font-cinzel">Confirm Temple Deletion</h3>
            <p className="text-xs text-gray-500">
              Are you sure you want to remove this sacred temple listing from the live database?
            </p>
            <div className="flex items-center justify-center gap-3 pt-2">
              <button
                onClick={() => setDeleteId(null)}
                className="px-4 py-2 border border-gray-300 rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(deleteId)}
                className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-xl text-xs font-bold shadow-md"
              >
                Yes, Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Add / Edit Temple Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-2xl border border-gray-200 my-8">
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🛕</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedTemple ? 'Edit Sacred Temple' : 'Fill & List New Sacred Temple'}
                  </h2>
                  <p className="text-[11px] text-gray-500">
                    All required fields marked with <span className="text-red-500 font-bold">*</span>
                  </p>
                </div>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 flex items-center justify-center text-sm font-bold"
              >
                ✕
              </button>
            </div>

            {errorMsg && (
              <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-xs font-semibold">
                ⚠️ {errorMsg}
              </div>
            )}

            <form onSubmit={handleSave} className="space-y-4 mt-4 text-xs">
              {/* Row 1: Temple Name & Deity */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Temple Name <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Kashi Vishwanath Temple"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.name ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.name && <p className="text-[10px] text-red-600 mt-1">{formErrors.name}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Presiding Deity <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Lord Shiva, Lord Venkateswara"
                    value={formData.deity}
                    onChange={(e) => setFormData({ ...formData, deity: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.deity ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.deity && <p className="text-[10px] text-red-600 mt-1">{formErrors.deity}</p>}
                </div>
              </div>

              {/* Row 2: City & State */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    City <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Varanasi, Ujjain, Ayodhya"
                    value={formData.city}
                    onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.city ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.city && <p className="text-[10px] text-red-600 mt-1">{formErrors.city}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    State <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Uttar Pradesh, Madhya Pradesh"
                    value={formData.state}
                    onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.state ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.state && <p className="text-[10px] text-red-600 mt-1">{formErrors.state}</p>}
                </div>
              </div>

              {/* Row 3: Address / Exact Location */}
              <div>
                <label className="block text-gray-700 font-bold mb-1">Sanctum Address / Location</label>
                <input
                  type="text"
                  placeholder="e.g. Lahori Tola, Varanasi, UP 221001"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                />
              </div>

              {/* Row 4: Description (Required) */}
              <div>
                <label className="block text-gray-700 font-bold mb-1">
                  Sanctum Description & Spiritual Significance <span className="text-red-500">*</span>
                </label>
                <textarea
                  rows={3}
                  placeholder="Describe the divine origin, spiritual virtues, rituals, and significance for devotees..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                    formErrors.description ? 'border-red-500 bg-red-50' : 'border-gray-200'
                  }`}
                />
                {formErrors.description && <p className="text-[10px] text-red-600 mt-1">{formErrors.description}</p>}
              </div>

              {/* Row 5: Image URL & Quick Presets (Required) */}
              <div className="p-3 bg-amber-50/60 rounded-xl border border-amber-200/70 space-y-2">
                <label className="block text-amber-950 font-bold mb-1">
                  Temple Banner Image URL <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <input
                    type="url"
                    placeholder="https://images.unsplash.com/photo-..."
                    value={formData.image_url}
                    onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                    className={`flex-1 p-2.5 bg-white border rounded-xl focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.image_url ? 'border-red-500' : 'border-amber-200'
                    }`}
                  />
                  {formData.image_url && (
                    <div className="w-12 h-10 rounded-lg overflow-hidden border border-amber-300 shadow-sm shrink-0">
                      <img src={formData.image_url} alt="Preview" className="w-full h-full object-cover" />
                    </div>
                  )}
                </div>
                {formErrors.image_url && <p className="text-[10px] text-red-600">{formErrors.image_url}</p>}

                {/* Quick Presets */}
                <div>
                  <span className="text-[10px] font-bold text-amber-900 block mb-1">
                    Quick Sample Sanctum Image Presets:
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {TEMPLE_IMAGE_PRESETS.map((preset) => (
                      <button
                        key={preset.label}
                        type="button"
                        onClick={() => setFormData({ ...formData, image_url: preset.url })}
                        className="px-2 py-1 bg-white hover:bg-amber-100 text-amber-900 rounded-lg text-[10px] font-semibold border border-amber-300 transition-colors shadow-2xs"
                      >
                        📷 {preset.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Row 6: Timings & Aarti */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Darshan Timings <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. 04:00 AM - 11:00 PM"
                    value={formData.darshan_timings}
                    onChange={(e) => setFormData({ ...formData, darshan_timings: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                  />
                  {formErrors.darshan_timings && <p className="text-[10px] text-red-600 mt-1">{formErrors.darshan_timings}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Aarti Schedule <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Mangala: 04:00 AM | Sandhya: 07:00 PM"
                    value={formData.aarti_timings}
                    onChange={(e) => setFormData({ ...formData, aarti_timings: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                  />
                  {formErrors.aarti_timings && <p className="text-[10px] text-red-600 mt-1">{formErrors.aarti_timings}</p>}
                </div>
              </div>

              {/* Row 7: Live Stream & Featured Toggle */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 items-end">
                <div className="sm:col-span-2">
                  <label className="block text-gray-700 font-bold mb-1">
                    Live Darshan Stream URL <span className="text-gray-400 font-normal">(YouTube / HLS / RTMP)</span>
                  </label>
                  <input
                    type="url"
                    placeholder="e.g. https://www.youtube.com/embed/live_stream?channel=..."
                    value={formData.live_darshan_url}
                    onChange={(e) => setFormData({ ...formData, live_darshan_url: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                  />
                </div>

                <div className="flex items-center gap-2 p-2.5 bg-gray-50 border border-gray-200 rounded-xl">
                  <input
                    type="checkbox"
                    id="is_featured"
                    checked={formData.is_featured}
                    onChange={(e) => setFormData({ ...formData, is_featured: e.target.checked })}
                    className="w-4 h-4 text-mandir-maroon rounded focus:ring-mandir-maroon"
                  />
                  <label htmlFor="is_featured" className="text-gray-700 font-bold text-xs select-none">
                    Feature on Home
                  </label>
                </div>
              </div>

              {/* Submit Buttons */}
              <div className="flex justify-end gap-3 pt-4 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-gray-300 rounded-xl text-gray-700 font-semibold hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-2.5 bg-gradient-to-r from-mandir-maroon to-mandir-maroon-dark text-white font-bold rounded-xl shadow-md hover:scale-102 active:scale-98 transition-all disabled:opacity-50 flex items-center gap-2"
                >
                  {isSubmitting ? (
                    <>
                      <span className="w-3.5 h-3.5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                      Saving to Database...
                    </>
                  ) : (
                    <span>💾 Save to Live Database</span>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
