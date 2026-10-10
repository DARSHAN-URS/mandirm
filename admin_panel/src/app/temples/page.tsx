'use client';

import { useState } from 'react';

interface Temple {
  id: string;
  name: string;
  deity: string;
  city: string;
  state: string;
  live_darshan_url?: string;
  darshan_timings: string;
  aarti_timings: string;
  is_featured: boolean;
  rating: number;
}

const SEED_TEMPLES: Temple[] = [
  { id: 'T-01', name: 'Kashi Vishwanath Temple', deity: 'Lord Shiva', city: 'Varanasi', state: 'Uttar Pradesh', live_darshan_url: 'https://www.youtube.com/watch?v=live_kashi', darshan_timings: '04:00 AM - 11:00 PM', aarti_timings: 'Mangala: 03:00 AM | Sandhya: 07:00 PM', is_featured: true, rating: 4.9 },
  { id: 'T-02', name: 'Mahakaleshwar Jyotirlinga', deity: 'Lord Shiva', city: 'Ujjain', state: 'Madhya Pradesh', live_darshan_url: 'https://www.youtube.com/watch?v=live_mahakal', darshan_timings: '04:00 AM - 11:00 PM', aarti_timings: 'Bhasma Aarti: 04:00 AM | Sandhya: 07:30 PM', is_featured: true, rating: 5.0 },
  { id: 'T-03', name: 'Tirupati Balaji (Venkateswara)', deity: 'Lord Vishnu (Balaji)', city: 'Tirumala', state: 'Andhra Pradesh', live_darshan_url: 'https://www.youtube.com/watch?v=live_tirupati', darshan_timings: '03:00 AM - 11:30 PM', aarti_timings: 'Suprabhatam: 03:00 AM | Ekanta Seva: 01:30 AM', is_featured: true, rating: 4.9 },
  { id: 'T-04', name: 'Siddhivinayak Ganapati Temple', deity: 'Lord Ganesha', city: 'Mumbai', state: 'Maharashtra', live_darshan_url: 'https://www.youtube.com/watch?v=live_siddhi', darshan_timings: '05:30 AM - 10:00 PM', aarti_timings: 'Kakad: 05:30 AM | Dhoop: 07:30 PM', is_featured: true, rating: 4.8 },
  { id: 'T-05', name: 'Kedarnath Dham Jyotirlinga', deity: 'Lord Shiva', city: 'Rudraprayag', state: 'Uttarakhand', live_darshan_url: '', darshan_timings: '05:00 AM - 09:00 PM', aarti_timings: 'Maha Aarti: 06:30 PM', is_featured: true, rating: 5.0 },
  { id: 'T-06', name: 'Somnath Temple', deity: 'Lord Shiva', city: 'Prabhas Patan', state: 'Gujarat', live_darshan_url: 'https://www.youtube.com/watch?v=live_somnath', darshan_timings: '06:00 AM - 10:00 PM', aarti_timings: 'Pratah: 07:00 AM | Sandhya: 07:00 PM', is_featured: true, rating: 4.9 },
  { id: 'T-07', name: 'Vaishno Devi Bhawan', deity: 'Mata Vaishno Devi', city: 'Katra', state: 'Jammu & Kashmir', live_darshan_url: 'https://www.youtube.com/watch?v=live_vaishno', darshan_timings: '24 Hours Open', aarti_timings: 'Pratah: 06:00 AM | Sandhya: 06:30 PM', is_featured: true, rating: 5.0 },
];

export default function TemplesPage() {
  const [temples, setTemples] = useState<Temple[]>(SEED_TEMPLES);
  const [search, setSearch] = useState('');
  const [selectedTemple, setSelectedTemple] = useState<Temple | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Form State
  const [formData, setFormData] = useState({
    name: '', deity: '', city: '', state: '', live_darshan_url: '', darshan_timings: '', aarti_timings: '', is_featured: true
  });

  const filtered = temples.filter(t =>
    t.name.toLowerCase().includes(search.toLowerCase()) ||
    t.deity.toLowerCase().includes(search.toLowerCase()) ||
    t.city.toLowerCase().includes(search.toLowerCase())
  );

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedTemple) {
      setTemples(temples.map(t => t.id === selectedTemple.id ? { ...t, ...formData } : t));
    } else {
      const newTemple: Temple = {
        id: `T-${String(temples.length + 1).padStart(2, '0')}`,
        ...formData,
        rating: 5.0
      };
      setTemples([...temples, newTemple]);
    }
    setIsModalOpen(false);
    setSelectedTemple(null);
  };

  const openEdit = (t: Temple) => {
    setSelectedTemple(t);
    setFormData({
      name: t.name,
      deity: t.deity,
      city: t.city,
      state: t.state,
      live_darshan_url: t.live_darshan_url || '',
      darshan_timings: t.darshan_timings,
      aarti_timings: t.aarti_timings,
      is_featured: t.is_featured
    });
    setIsModalOpen(true);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🛕</span> Sacred Temples & Live Darshan Feeds
          </h1>
          <p className="text-xs text-gray-500">
            Manage participating holy sanctums, Live Darshan RTMP/HLS streams, and Aarti timings
          </p>
        </div>
        <button
          onClick={() => {
            setSelectedTemple(null);
            setFormData({ name: '', deity: '', city: '', state: '', live_darshan_url: '', darshan_timings: '', aarti_timings: '', is_featured: true });
            setIsModalOpen(true);
          }}
          className="px-4 py-2 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center gap-1.5"
        >
          <span>+</span> Add Sacred Temple
        </button>
      </div>

      {/* Filter and Stats Bar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-center justify-between gap-4 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search by temple name, deity, or city..."
            className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>
        <div className="flex items-center gap-4 text-xs font-medium text-gray-600">
          <span className="flex items-center gap-1.5">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
            <strong>{temples.filter(t => t.live_darshan_url).length}</strong> Live Darshan Feeds Active
          </span>
          <span>Total Temples: <strong>{temples.length}</strong></span>
        </div>
      </div>

      {/* Temples Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.map(t => (
          <div key={t.id} className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-all flex flex-col justify-between">
            <div>
              {/* Header Card */}
              <div className="p-4 bg-gradient-to-r from-amber-500/10 to-orange-500/10 border-b border-amber-100/50 flex items-start justify-between">
                <div>
                  <span className="text-[10px] font-bold text-amber-800 bg-amber-100 px-2 py-0.5 rounded-md uppercase">
                    {t.deity}
                  </span>
                  <h3 className="font-bold text-sm text-gray-900 font-cinzel mt-1">{t.name}</h3>
                  <p className="text-[11px] text-gray-500">{t.city}, {t.state}</p>
                </div>
                {t.live_darshan_url ? (
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800 flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span> LIVE
                  </span>
                ) : (
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-gray-100 text-gray-600">
                    Offline
                  </span>
                )}
              </div>

              {/* Body Details */}
              <div className="p-4 space-y-2 text-xs">
                <div>
                  <span className="text-gray-400 text-[10px] uppercase font-bold block">Darshan Timings</span>
                  <span className="text-gray-800 font-medium">{t.darshan_timings}</span>
                </div>
                <div>
                  <span className="text-gray-400 text-[10px] uppercase font-bold block">Aarti Schedule</span>
                  <span className="text-gray-800 font-medium">{t.aarti_timings}</span>
                </div>
                {t.live_darshan_url && (
                  <div>
                    <span className="text-gray-400 text-[10px] uppercase font-bold block">Stream Source</span>
                    <span className="text-blue-600 font-mono text-[11px] truncate block">{t.live_darshan_url}</span>
                  </div>
                )}
              </div>
            </div>

            {/* Actions */}
            <div className="p-3 bg-gray-50/70 border-t border-gray-100 flex items-center justify-between">
              <span className="text-xs font-semibold text-amber-600">⭐ {t.rating} Devotee Rating</span>
              <button
                onClick={() => openEdit(t)}
                className="px-3 py-1 bg-white hover:bg-gray-100 text-gray-700 font-semibold text-xs rounded-lg border border-gray-200 transition-colors shadow-sm"
              >
                Edit Temple Details
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Edit/Add Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-gray-200">
            <h2 className="text-base font-bold font-cinzel text-gray-900 mb-4">
              {selectedTemple ? 'Edit Sacred Temple' : 'Add New Sacred Temple'}
            </h2>
            <form onSubmit={handleSave} className="space-y-3 text-xs">
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Temple Name</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={e => setFormData({ ...formData, name: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">Deity</label>
                  <input
                    type="text"
                    required
                    value={formData.deity}
                    onChange={e => setFormData({ ...formData, deity: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                  />
                </div>
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">City</label>
                  <input
                    type="text"
                    required
                    value={formData.city}
                    onChange={e => setFormData({ ...formData, city: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                  />
                </div>
              </div>
              <div>
                <label className="block text-gray-700 font-semibold mb-1">State</label>
                <input
                  type="text"
                  required
                  value={formData.state}
                  onChange={e => setFormData({ ...formData, state: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
              </div>
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Live Darshan Stream URL (HLS / YouTube Live)</label>
                <input
                  type="url"
                  placeholder="https://..."
                  value={formData.live_darshan_url}
                  onChange={e => setFormData({ ...formData, live_darshan_url: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
                />
              </div>
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Darshan Timings</label>
                <input
                  type="text"
                  value={formData.darshan_timings}
                  onChange={e => setFormData({ ...formData, darshan_timings: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
              </div>
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Aarti Schedule</label>
                <input
                  type="text"
                  value={formData.aarti_timings}
                  onChange={e => setFormData({ ...formData, aarti_timings: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
              </div>
              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="featured"
                  checked={formData.is_featured}
                  onChange={e => setFormData({ ...formData, is_featured: e.target.checked })}
                  className="rounded text-mandir-maroon"
                />
                <label htmlFor="featured" className="text-gray-700 font-medium">Feature on Mobile App Home Screen</label>
              </div>

              <div className="flex justify-end gap-2 pt-4 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-lg font-bold shadow-md"
                >
                  Save Temple
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
