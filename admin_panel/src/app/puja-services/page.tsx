'use client';

import { useState } from 'react';

interface PujaService {
  id: string;
  title: string;
  deity: string;
  category: string;
  temple_name: string;
  price: number;
  vip_price: number;
  duration_minutes: number;
  is_popular: boolean;
  benefits: string;
}

const SEED_PUJAS: PujaService[] = [
  { id: 'PJ-01', title: 'Maha Mrityunjaya Jaap & Havan (54,000 Chants)', deity: 'Lord Shiva', category: 'Health & Protection', temple_name: 'Mahakaleshwar Jyotirlinga, Ujjain', price: 2100, vip_price: 5100, duration_minutes: 120, is_popular: true, benefits: 'Cures severe chronic illnesses, relieves untimely death fears & planetary malefic doshas.' },
  { id: 'PJ-02', title: 'Kashi Vishwanath Rudrabhishek with Bilva Patra', deity: 'Lord Shiva', category: 'Moksha & Peace', temple_name: 'Kashi Vishwanath, Varanasi', price: 1100, vip_price: 2500, duration_minutes: 60, is_popular: true, benefits: 'Attains mental tranquility, spiritual elevation and fulfills inner heartfelt desires.' },
  { id: 'PJ-03', title: 'Kaal Sarp Dosh Nivaran Maha Puja', deity: 'Lord Shiva & Rahu-Ketu', category: 'Dosha Nivaran', temple_name: 'Trimbakeshwar Shiva Temple, Nashik', price: 2500, vip_price: 5500, duration_minutes: 90, is_popular: true, benefits: 'Eradicates continuous hurdles, career setbacks and delay in marital harmony caused by Kaal Sarp yoga.' },
  { id: 'PJ-04', title: 'Siddhivinayak Sankat Nashan Ganesha Puja', deity: 'Lord Ganesha', category: 'Obstacle Removal & Prosperity', temple_name: 'Siddhivinayak Temple, Mumbai', price: 850, vip_price: 2100, duration_minutes: 45, is_popular: true, benefits: 'Removes financial hurdles, business obstacles and brings auspicious beginnings.' },
  { id: 'PJ-05', title: 'Navgrah Shanti Maha Puja with 9 Grains', deity: 'Navgraha Devatas', category: 'Astrological Balance', temple_name: 'Kalahasti Temple, Andhra Pradesh', price: 1500, vip_price: 3500, duration_minutes: 75, is_popular: false, benefits: 'Balances nine planetary transits and neutralizes Sade Sati, Dhaiya and debilitated planets.' },
  { id: 'PJ-06', title: 'Mata Baglamukhi Shatru Vinashak Puja', deity: 'Mata Baglamukhi', category: 'Victory & Court Cases', temple_name: 'Baglamukhi Pitambara Peeth, Nalkheda', price: 3100, vip_price: 7500, duration_minutes: 90, is_popular: false, benefits: 'Grants invincibility in legal litigations, dissolves malice, jealousy and false allegations.' },
];

export default function PujaServicesPage() {
  const [pujas, setPujas] = useState<PujaService[]>(SEED_PUJAS);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingPuja, setEditingPuja] = useState<PujaService | null>(null);

  const [form, setForm] = useState({
    title: '', deity: '', category: 'Health & Protection', temple_name: 'Kashi Vishwanath, Varanasi',
    price: 1100, vip_price: 2500, duration_minutes: 60, is_popular: false, benefits: ''
  });

  const categories = ['all', 'Health & Protection', 'Moksha & Peace', 'Dosha Nivaran', 'Obstacle Removal & Prosperity', 'Astrological Balance', 'Victory & Court Cases'];

  const filtered = pujas.filter(p => {
    const matchSearch = p.title.toLowerCase().includes(search.toLowerCase()) || p.deity.toLowerCase().includes(search.toLowerCase());
    const matchCat = categoryFilter === 'all' || p.category === categoryFilter;
    return matchSearch && matchCat;
  });

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (editingPuja) {
      setPujas(pujas.map(p => p.id === editingPuja.id ? { ...p, ...form } : p));
    } else {
      const newP: PujaService = {
        id: `PJ-${String(pujas.length + 1).padStart(2, '0')}`,
        ...form
      };
      setPujas([...pujas, newP]);
    }
    setIsModalOpen(false);
    setEditingPuja(null);
  };

  const openEdit = (p: PujaService) => {
    setEditingPuja(p);
    setForm({
      title: p.title, deity: p.deity, category: p.category, temple_name: p.temple_name,
      price: p.price, vip_price: p.vip_price, duration_minutes: p.duration_minutes, is_popular: p.is_popular, benefits: p.benefits
    });
    setIsModalOpen(true);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🪔</span> Sacred Puja Ceremonies & Rituals
          </h1>
          <p className="text-xs text-gray-500">
            Configure Vedic pujas, deity rituals, temple associations, and regular vs. VIP Sankalp Dakshina
          </p>
        </div>
        <button
          onClick={() => {
            setEditingPuja(null);
            setForm({ title: '', deity: '', category: 'Health & Protection', temple_name: 'Kashi Vishwanath, Varanasi', price: 1100, vip_price: 2500, duration_minutes: 60, is_popular: false, benefits: '' });
            setIsModalOpen(true);
          }}
          className="px-4 py-2 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-xl text-xs font-bold shadow-md transition-all flex items-center gap-1.5"
        >
          <span>+</span> Create New Puja
        </button>
      </div>

      {/* Filter and Category Pills */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 space-y-3 shadow-sm">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="relative w-full sm:w-80">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
            <input
              type="text"
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search pujas by title or deity..."
              className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
            />
          </div>
          <div className="text-xs text-gray-500 font-medium">
            Active Rituals: <strong>{pujas.length}</strong>
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex flex-wrap gap-2 pt-1 border-t border-gray-100">
          {categories.map(c => (
            <button
              key={c}
              onClick={() => setCategoryFilter(c)}
              className={`px-3 py-1 rounded-full text-xs font-semibold transition-all ${
                categoryFilter === c
                  ? 'bg-mandir-maroon text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {c === 'all' ? 'All Categories' : c}
            </button>
          ))}
        </div>
      </div>

      {/* Pujas Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">Puja Ceremony</th>
                <th className="py-3 px-4">Deity & Category</th>
                <th className="py-3 px-4">Temple Sanctum</th>
                <th className="py-3 px-4">Duration</th>
                <th className="py-3 px-4">Regular Dakshina</th>
                <th className="py-3 px-4">VIP Sankalp</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map(p => (
                <tr key={p.id} className="hover:bg-amber-50/20 transition-colors">
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-gray-900 font-cinzel text-xs">{p.title}</div>
                    <div className="text-[11px] text-gray-500 max-w-sm line-clamp-1">{p.benefits}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-semibold text-gray-800">{p.deity}</div>
                    <span className="inline-block px-2 py-0.5 rounded text-[10px] font-semibold bg-amber-100 text-amber-800 mt-0.5">
                      {p.category}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-gray-600 font-medium">{p.temple_name}</td>
                  <td className="py-3.5 px-4 font-mono text-gray-700">{p.duration_minutes} mins</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900">₹ {p.price.toLocaleString('en-IN')}</td>
                  <td className="py-3.5 px-4 font-bold text-amber-700">₹ {p.vip_price.toLocaleString('en-IN')}</td>
                  <td className="py-3.5 px-4 text-right">
                    <button
                      onClick={() => openEdit(p)}
                      className="px-3 py-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-lg text-xs transition-colors shadow-sm"
                    >
                      Edit
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit/Create Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-gray-200 max-h-[90vh] overflow-y-auto">
            <h2 className="text-base font-bold font-cinzel text-gray-900 mb-4">
              {editingPuja ? 'Edit Sacred Puja Ceremony' : 'Create Sacred Puja Ceremony'}
            </h2>
            <form onSubmit={handleSave} className="space-y-3 text-xs">
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Puja Title</label>
                <input
                  type="text"
                  required
                  value={form.title}
                  onChange={e => setForm({ ...form, title: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">Deity</label>
                  <input
                    type="text"
                    required
                    value={form.deity}
                    onChange={e => setForm({ ...form, deity: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                  />
                </div>
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">Category</label>
                  <select
                    value={form.category}
                    onChange={e => setForm({ ...form, category: e.target.value })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                  >
                    {categories.filter(c => c !== 'all').map(c => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Temple Sanctum</label>
                <input
                  type="text"
                  required
                  value={form.temple_name}
                  onChange={e => setForm({ ...form, temple_name: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
              </div>
              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">Regular (₹)</label>
                  <input
                    type="number"
                    required
                    value={form.price}
                    onChange={e => setForm({ ...form, price: Number(e.target.value) })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">VIP Sankalp (₹)</label>
                  <input
                    type="number"
                    required
                    value={form.vip_price}
                    onChange={e => setForm({ ...form, vip_price: Number(e.target.value) })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
                  />
                </div>
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">Duration (Min)</label>
                  <input
                    type="number"
                    required
                    value={form.duration_minutes}
                    onChange={e => setForm({ ...form, duration_minutes: Number(e.target.value) })}
                    className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
                  />
                </div>
              </div>
              <div>
                <label className="block text-gray-700 font-semibold mb-1">Divine Benefits & Spiritual Significance</label>
                <textarea
                  rows={3}
                  value={form.benefits}
                  onChange={e => setForm({ ...form, benefits: e.target.value })}
                  className="w-full p-2 border border-gray-300 rounded-lg text-xs"
                />
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
                  Save Ceremony
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
