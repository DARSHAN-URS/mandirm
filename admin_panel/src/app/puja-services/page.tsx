'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface PujaService {
  id: string;
  title: string;
  deity: string;
  category: string;
  temple_name: string;
  temple_id?: string;
  price: number;
  vip_price?: number;
  duration_minutes: number;
  is_popular: boolean;
  benefits?: string;
  description?: string;
  image_url: string;
}

const PUJA_IMAGE_PRESETS = [
  { label: 'Rudrabhishek Lingam', url: '/images/pujas/puja_rudrabhishek.jpg' },
  { label: 'Ganesha Homam', url: '/images/pujas/puja_ganesha_homam.jpg' },
  { label: 'Tirupati Kalyanotsavam', url: '/images/pujas/puja_venkateswara.jpg' },
  { label: 'Kaal Sarp Shanti', url: '/images/pujas/puja_kaal_sarp.jpg' },
  { label: 'Chandi Path Durga', url: '/images/pujas/puja_chandi_path.jpg' },
  { label: 'Navgrah Shanti Havan', url: '/images/pujas/puja_navgrah_shanti.jpg' },
];

const CATEGORIES = [
  'Health & Protection',
  'Moksha & Peace',
  'Dosha Nivaran',
  'Obstacle Removal & Prosperity',
  'Astrological Balance',
  'Victory & Court Cases',
  'Family & Marriage',
];

export default function PujaServicesPage() {
  const [pujas, setPujas] = useState<PujaService[]>([]);
  const [templeList, setTempleList] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [selectedPuja, setSelectedPuja] = useState<PujaService | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successToast, setSuccessToast] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form State
  const [formData, setFormData] = useState({
    title: '',
    deity: '',
    category: 'Health & Protection',
    temple_name: '',
    price: '',
    vip_price: '',
    duration_minutes: '60',
    description: '',
    benefits: '',
    image_url: '',
    is_popular: true,
  });

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    fetchPujas();
    fetchTemples();
  }, []);

  const fetchTemples = async () => {
    try {
      const { data } = await supabase.from('temples').select('name');
      if (data && data.length > 0) {
        setTempleList(data.map((t) => t.name));
      }
    } catch (_) {}
  };

  const fetchPujas = async () => {
    setIsLoading(true);
    try {
      const res = await fetch('/api/puja-services');
      const json = await res.json();
      if (json.success && Array.isArray(json.data) && json.data.length > 0) {
        setPujas(json.data);
      } else {
        const { data } = await supabase.from('puja_services').select('*').order('title');
        if (data && data.length > 0) {
          setPujas(data as PujaService[]);
        }
      }
    } catch (_) {
      const { data } = await supabase.from('puja_services').select('*').order('title');
      if (data && data.length > 0) {
        setPujas(data as PujaService[]);
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
    if (!formData.title.trim()) errs.title = 'Puja title is required';
    if (!formData.temple_name.trim()) errs.temple_name = 'Temple name is required';
    if (!formData.deity.trim()) errs.deity = 'Deity name is required';
    if (!formData.category.trim()) errs.category = 'Category is required';
    if (!formData.price || isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      errs.price = 'Valid general dakshina (₹) is required';
    }
    if (!formData.description.trim()) errs.description = 'Puja description is required';
    if (!formData.image_url.trim()) errs.image_url = 'Puja image URL is required';
    setFormErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsSubmitting(true);
    setErrorMsg(null);

    const payload = {
      ...(selectedPuja ? { id: selectedPuja.id } : { id: `puja_${Date.now()}` }),
      title: formData.title.trim(),
      temple_name: formData.temple_name.trim(),
      deity: formData.deity.trim(),
      category: formData.category.trim(),
      price: Number(formData.price),
      vip_price: formData.vip_price ? Number(formData.vip_price) : Number(formData.price) * 2,
      duration_minutes: Number(formData.duration_minutes) || 60,
      description: formData.description.trim(),
      benefits: formData.benefits.trim() || 'Brings peace, health, and spiritual blessings.',
      image_url: formData.image_url.trim(),
      is_popular: formData.is_popular,
    };

    try {
      const res = await fetch('/api/puja-services', {
        method: selectedPuja ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save puja service');

      showToast(selectedPuja ? 'Puja ceremony updated in database!' : 'New Vedic puja ceremony listed in database!');
      setIsModalOpen(false);
      setSelectedPuja(null);
      fetchPujas();
    } catch (err: any) {
      // Direct Supabase upsert fallback
      const { error: sbErr } = await supabase.from('puja_services').upsert(payload);
      if (!sbErr) {
        showToast('Puja service saved to database!');
        setIsModalOpen(false);
        setSelectedPuja(null);
        fetchPujas();
      } else {
        setErrorMsg(err.message || sbErr.message || 'Error saving puja service');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await fetch(`/api/puja-services?id=${id}`, { method: 'DELETE' });
      if (!res.ok) {
        await supabase.from('puja_services').delete().eq('id', id);
      }
      showToast('Puja service deleted.');
      setDeleteId(null);
      fetchPujas();
    } catch (_) {
      await supabase.from('puja_services').delete().eq('id', id);
      fetchPujas();
    }
  };

  const openAdd = () => {
    setSelectedPuja(null);
    setFormData({
      title: '',
      deity: '',
      category: 'Health & Protection',
      temple_name: templeList.length > 0 ? templeList[0] : 'Kashi Vishwanath Temple',
      price: '',
      vip_price: '',
      duration_minutes: '60',
      description: '',
      benefits: '',
      image_url: '',
      is_popular: true,
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const openEdit = (p: PujaService) => {
    setSelectedPuja(p);
    setFormData({
      title: p.title,
      deity: p.deity,
      category: p.category || 'Health & Protection',
      temple_name: p.temple_name,
      price: p.price.toString(),
      vip_price: p.vip_price?.toString() || '',
      duration_minutes: p.duration_minutes?.toString() || '60',
      description: p.description || '',
      benefits: p.benefits || '',
      image_url: p.image_url || '',
      is_popular: p.is_popular ?? false,
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const filtered = pujas.filter((p) => {
    const matchSearch =
      p.title?.toLowerCase().includes(search.toLowerCase()) ||
      p.deity?.toLowerCase().includes(search.toLowerCase()) ||
      p.temple_name?.toLowerCase().includes(search.toLowerCase());
    const matchCat = categoryFilter === 'all' || p.category === categoryFilter;
    return matchSearch && matchCat;
  });

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Toast Notification */}
      {successToast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-700 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-3 border border-emerald-500 animate-bounce">
          <span className="text-lg">🪔</span>
          <span className="text-xs font-bold">{successToast}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-gradient-to-r from-orange-950 via-amber-900 to-mandir-maroon p-4 sm:p-6 rounded-2xl text-white shadow-xl border border-amber-900/30">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xl sm:text-2xl">🪔</span>
            <h1 className="text-xl sm:text-2xl font-bold font-cinzel tracking-wide text-amber-200">
              Vedic Puja Ceremonies & Rituals Catalog
            </h1>
          </div>
          <p className="text-[11px] sm:text-xs text-amber-100/80 leading-normal">
            Manage sacred rituals, Gotra sankalp ceremonies, pandit samagri inclusion, and pricing across participating temples.
          </p>
        </div>
        <button
          onClick={openAdd}
          className="w-full sm:w-auto justify-center px-5 py-2.5 bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 text-amber-950 font-bold rounded-xl text-xs shadow-lg transition-all flex items-center gap-2 hover:scale-105 active:scale-95 shrink-0"
        >
          <span className="text-base font-extrabold">+</span> Add Puja Ceremony
        </button>
      </div>

      {/* Filter and Stats Toolbar */}
      <div className="bg-white p-3.5 sm:p-4 rounded-xl border border-gray-200 space-y-3 shadow-sm">
        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3">
          <div className="relative w-full sm:w-80 md:w-96">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by puja title, deity, or temple..."
              className="w-full pl-8 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
            />
          </div>
          <div className="flex items-center gap-3 text-xs font-semibold text-gray-600">
            <span className="bg-amber-50 text-amber-900 px-3 py-1 rounded-full border border-amber-200 text-[11px]">
              Total Pujas: <strong>{pujas.length}</strong>
            </span>
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex sm:flex-wrap items-center gap-1.5 pt-2 border-t border-gray-100 overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
          <button
            onClick={() => setCategoryFilter('all')}
            className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold transition-all shrink-0 ${
              categoryFilter === 'all'
                ? 'bg-mandir-maroon text-white shadow-sm'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All Pujas ({pujas.length})
          </button>
          {CATEGORIES.map((cat) => {
            const count = pujas.filter((p) => p.category === cat).length;
            return (
              <button
                key={cat}
                onClick={() => setCategoryFilter(cat)}
                className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold transition-all shrink-0 ${
                  categoryFilter === cat
                    ? 'bg-mandir-maroon text-white shadow-sm'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                {cat} {count > 0 && `(${count})`}
              </button>
            );
          })}
        </div>
      </div>

      {/* Loading Indicator */}
      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center space-y-3">
          <div className="w-10 h-10 border-4 border-mandir-maroon border-t-transparent rounded-full animate-spin"></div>
          <span className="text-xs font-semibold text-gray-500">Loading Puja services from database...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-200 p-8 sm:p-12 text-center space-y-3 shadow-sm">
          <span className="text-4xl block">🪔</span>
          <h3 className="font-cinzel text-base font-bold text-gray-800">No Pujas Found</h3>
          <p className="text-xs text-gray-500 max-w-md mx-auto">
            {search ? 'No ceremonies match your current search query.' : 'No puja services in the database yet. Click below to add the first Vedic ritual!'}
          </p>
          <button
            onClick={openAdd}
            className="px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl hover:bg-mandir-maroon-dark transition-all"
          >
            + Add First Puja
          </button>
        </div>
      ) : (
        /* Pujas Grid */
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          {filtered.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden hover:shadow-lg transition-all flex flex-col justify-between group"
            >
              <div>
                {/* Puja Image */}
                <div className="relative h-44 w-full bg-gray-100 overflow-hidden">
                  <img
                    src={
                      item.image_url && !item.image_url.includes('1544005313-94ddf0286df2') && !item.image_url.includes('1609358905596') && !item.image_url.includes('1582510003544') && !item.image_url.includes('1561361513-2d000a50f0dc') && !item.image_url.includes('1620766182966') && !item.image_url.includes('1590076212472')
                        ? item.image_url
                        : item.id === 'puja_1'
                        ? '/images/pujas/puja_rudrabhishek.jpg'
                        : item.id === 'puja_2'
                        ? '/images/pujas/puja_ganesha_homam.jpg'
                        : item.id === 'puja_3'
                        ? '/images/pujas/puja_venkateswara.jpg'
                        : item.id === 'puja_4'
                        ? '/images/pujas/puja_kaal_sarp.jpg'
                        : item.id === 'puja_5'
                        ? '/images/pujas/puja_chandi_path.jpg'
                        : item.id === 'puja_6'
                        ? '/images/pujas/puja_navgrah_shanti.jpg'
                        : '/images/pujas/puja_rudrabhishek.jpg'
                    }
                    alt={item.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/images/pujas/puja_rudrabhishek.jpg';
                    }}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

                  <div className="absolute top-3 left-3 flex gap-2">
                    <span className="text-[10px] font-bold text-amber-950 bg-amber-300 px-2.5 py-1 rounded-md uppercase tracking-wide shadow-md">
                      {item.deity}
                    </span>
                    {item.is_popular && (
                      <span className="text-[10px] font-bold text-white bg-mandir-maroon px-2 py-0.5 rounded-md shadow-md">
                        ★ Popular
                      </span>
                    )}
                  </div>

                  <div className="absolute top-3 right-3">
                    <span className="text-xs font-black text-amber-950 bg-amber-400 px-3 py-1 rounded-full shadow-lg">
                      ₹ {Number(item.price).toLocaleString('en-IN')}
                    </span>
                  </div>

                  <div className="absolute bottom-3 left-3 right-3 text-white">
                    <h3 className="font-bold text-sm font-cinzel text-white leading-tight drop-shadow-md">
                      {item.title}
                    </h3>
                    <p className="text-[11px] text-amber-200/90 flex items-center gap-1 mt-0.5">
                      🛕 {item.temple_name}
                    </p>
                  </div>
                </div>

                {/* Details & Benefits */}
                <div className="p-4 space-y-2 text-xs">
                  <p className="text-gray-600 text-xs line-clamp-2 leading-relaxed">
                    {item.description || 'Sacred Vedic ritual performed by certified acharyas.'}
                  </p>
                  <p className="text-emerald-700 text-[11px] line-clamp-1 font-medium">
                    ✨ {item.benefits || 'Brings peace, health, and spiritual blessings.'}
                  </p>
                  <div className="pt-2 border-t border-gray-100 flex items-center justify-between text-[11px] text-gray-500">
                    <span>Duration: <strong className="text-gray-800">{item.duration_minutes} mins</strong></span>
                    {item.vip_price && (
                      <span>VIP Sankalp: <strong className="text-mandir-maroon">₹{Number(item.vip_price).toLocaleString('en-IN')}</strong></span>
                    )}
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="p-3 bg-gray-50 border-t border-gray-100 flex items-center justify-between">
                <span className="text-[11px] font-bold text-gray-500 font-mono">ID: {item.id}</span>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setDeleteId(item.id)}
                    className="px-2.5 py-1 text-red-600 hover:bg-red-50 font-semibold text-xs rounded-lg transition-colors"
                  >
                    Delete
                  </button>
                  <button
                    onClick={() => openEdit(item)}
                    className="px-3 py-1 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white font-semibold text-xs rounded-lg transition-all shadow-sm"
                  >
                    Edit Puja
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
            <h3 className="font-bold text-base text-gray-900 font-cinzel">Confirm Puja Deletion</h3>
            <p className="text-xs text-gray-500">
              Are you sure you want to remove this sacred Puja ritual from the live database?
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

      {/* Add / Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-3 sm:p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-4 sm:my-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🪔</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedPuja ? 'Edit Puja Ceremony' : 'Fill & List New Vedic Puja Ceremony'}
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
              {/* Row 1: Title & Temple */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Puja Title <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Maha Rudrabhishek with Bilva Patra"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.title ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.title && <p className="text-[10px] text-red-600 mt-1">{formErrors.title}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Temple Destination <span className="text-red-500">*</span>
                  </label>
                  {templeList.length > 0 ? (
                    <select
                      value={formData.temple_name}
                      onChange={(e) => setFormData({ ...formData, temple_name: e.target.value })}
                      className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon text-xs"
                    >
                      {templeList.map((t) => (
                        <option key={t} value={t}>
                          {t}
                        </option>
                      ))}
                    </select>
                  ) : (
                    <input
                      type="text"
                      placeholder="e.g. Kashi Vishwanath Temple, Varanasi"
                      value={formData.temple_name}
                      onChange={(e) => setFormData({ ...formData, temple_name: e.target.value })}
                      className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                    />
                  )}
                  {formErrors.temple_name && <p className="text-[10px] text-red-600 mt-1">{formErrors.temple_name}</p>}
                </div>
              </div>

              {/* Row 2: Deity & Category */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Presiding Deity <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Lord Shiva, Lord Ganesha"
                    value={formData.deity}
                    onChange={(e) => setFormData({ ...formData, deity: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.deity ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.deity && <p className="text-[10px] text-red-600 mt-1">{formErrors.deity}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Ceremony Category <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon text-xs"
                  >
                    {CATEGORIES.map((cat) => (
                      <option key={cat} value={cat}>
                        {cat}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Row 3: Price, VIP Price, Duration */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    General Dakshina (₹) <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    min="1"
                    placeholder="e.g. 1100"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.price ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.price && <p className="text-[10px] text-red-600 mt-1">{formErrors.price}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">VIP Sankalp Rate (₹)</label>
                  <input
                    type="number"
                    min="1"
                    placeholder="e.g. 2500"
                    value={formData.vip_price}
                    onChange={(e) => setFormData({ ...formData, vip_price: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">Duration (Minutes)</label>
                  <input
                    type="number"
                    min="15"
                    step="5"
                    placeholder="e.g. 60"
                    value={formData.duration_minutes}
                    onChange={(e) => setFormData({ ...formData, duration_minutes: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                  />
                </div>
              </div>

              {/* Row 4: Description & Benefits */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Puja Description & Vedic Rites <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    rows={3}
                    placeholder="Explain the havan, recitations, mantra chanting, and sacred gotra sankalp process..."
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon ${
                      formErrors.description ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.description && <p className="text-[10px] text-red-600 mt-1">{formErrors.description}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">Spiritual Benefits to Devotee</label>
                  <textarea
                    rows={3}
                    placeholder="e.g. Eradicates obstacles, restores good health, neutralizes planetary doshas..."
                    value={formData.benefits}
                    onChange={(e) => setFormData({ ...formData, benefits: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
                  />
                </div>
              </div>

              {/* Row 5: Image URL & Quick Presets */}
              <div className="p-3 bg-amber-50/60 rounded-xl border border-amber-200/70 space-y-2">
                <label className="block text-amber-950 font-bold mb-1">
                  Puja Ceremony Image URL <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="/images/pujas/puja_rudrabhishek.jpg"
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
                    Quick Sample Ceremony Image Presets:
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {PUJA_IMAGE_PRESETS.map((preset) => (
                      <button
                        key={preset.label}
                        type="button"
                        onClick={() => setFormData({ ...formData, image_url: preset.url })}
                        className="px-2 py-1 bg-white hover:bg-amber-100 text-amber-900 rounded-lg text-[10px] font-semibold border border-amber-300 transition-colors shadow-2xs"
                      >
                        🪔 {preset.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Popular Checkbox */}
              <div className="flex items-center gap-2 p-2.5 bg-gray-50 border border-gray-200 rounded-xl">
                <input
                  type="checkbox"
                  id="puja_popular"
                  checked={formData.is_popular}
                  onChange={(e) => setFormData({ ...formData, is_popular: e.target.checked })}
                  className="w-4 h-4 text-mandir-maroon rounded focus:ring-mandir-maroon"
                />
                <label htmlFor="puja_popular" className="text-gray-700 font-bold text-xs select-none">
                  Highlight as Popular Ceremony on Home & Puja Directory
                </label>
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
