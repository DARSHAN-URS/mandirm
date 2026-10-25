'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface ChadhawaOffering {
  id: string;
  temple_id?: string;
  temple_name: string;
  title: string;
  category: string;
  price: number;
  description: string;
  image_url: string;
}

const CHADAWA_IMAGE_PRESETS = [
  { label: 'Silver Bilva Patra', url: '/images/chadhawa/chadhawa_bilva_patra.jpg' },
  { label: 'Tirupati Laddu Mahaprasad', url: '/images/chadhawa/chadhawa_tirupati_laddu.jpg' },
  { label: 'Golden Modak & Garland', url: '/images/chadhawa/chadhawa_modak_garland.jpg' },
  { label: 'Akhand Desi Ghee Diya', url: '/images/chadhawa/chadhawa_akhand_jyoti.jpg' },
  { label: 'Red Banarasi Zari Chunri', url: '/images/chadhawa/chadhawa_red_chunri.jpg' },
  { label: 'Ceremonial Temple Flag', url: '/images/chadhawa/chadhawa_somnath_dhwaja.jpg' },
];

const CATEGORIES = [
  'Sacred Metals',
  'Prasadam Sewa',
  'Flowers & Bhog',
  'Deep Daan',
  'Vastram & Shringar',
  'Temple Dhwajarohan',
  'Divine Offering',
];

export default function ChadhawaPage() {
  const [offerings, setOfferings] = useState<ChadhawaOffering[]>([]);
  const [templeList, setTempleList] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedOffering, setSelectedOffering] = useState<ChadhawaOffering | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successToast, setSuccessToast] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form State
  const [formData, setFormData] = useState({
    title: '',
    temple_name: '',
    category: 'Sacred Metals',
    price: '',
    description: '',
    image_url: '',
  });

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    fetchOfferings();
    fetchTemplesList();
  }, []);

  const fetchTemplesList = async () => {
    try {
      const { data } = await supabase.from('temples').select('name');
      if (data && data.length > 0) {
        setTempleList(data.map((t) => t.name));
      }
    } catch (_) {}
  };

  const fetchOfferings = async () => {
    setIsLoading(true);
    try {
      const res = await fetch('/api/chadhawa');
      const json = await res.json();
      if (json.success && Array.isArray(json.data) && json.data.length > 0) {
        setOfferings(json.data);
      } else {
        const { data } = await supabase.from('chadhawa_offerings').select('*').order('title');
        if (data && data.length > 0) {
          setOfferings(data as ChadhawaOffering[]);
        }
      }
    } catch (_) {
      const { data } = await supabase.from('chadhawa_offerings').select('*').order('title');
      if (data && data.length > 0) {
        setOfferings(data as ChadhawaOffering[]);
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
    if (!formData.title.trim()) errs.title = 'Offering title is required';
    if (!formData.temple_name.trim()) errs.temple_name = 'Temple destination is required';
    if (!formData.category.trim()) errs.category = 'Category is required';
    if (!formData.price || isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      errs.price = 'Valid dakshina / price (₹) is required';
    }
    if (!formData.description.trim()) errs.description = 'Offering description is required';
    if (!formData.image_url.trim()) errs.image_url = 'Offering image URL is required';
    setFormErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsSubmitting(true);
    setErrorMsg(null);

    const payload = {
      ...(selectedOffering ? { id: selectedOffering.id } : { id: `chadhawa_${Date.now()}` }),
      title: formData.title.trim(),
      temple_name: formData.temple_name.trim(),
      category: formData.category.trim(),
      price: Number(formData.price),
      description: formData.description.trim(),
      image_url: formData.image_url.trim(),
    };

    try {
      const res = await fetch('/api/chadhawa', {
        method: selectedOffering ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save offering');

      showToast(selectedOffering ? 'Chadhawa offering updated in database!' : 'New Chadhawa offering added to database!');
      setIsModalOpen(false);
      setSelectedOffering(null);
      fetchOfferings();
    } catch (err: any) {
      // Direct Supabase upsert fallback
      const { error: sbErr } = await supabase.from('chadhawa_offerings').upsert(payload);
      if (!sbErr) {
        showToast('Chadhawa offering saved to database!');
        setIsModalOpen(false);
        setSelectedOffering(null);
        fetchOfferings();
      } else {
        setErrorMsg(err.message || sbErr.message || 'Error saving offering');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await fetch(`/api/chadhawa?id=${id}`, { method: 'DELETE' });
      if (!res.ok) {
        await supabase.from('chadhawa_offerings').delete().eq('id', id);
      }
      showToast('Offering removed from catalogue.');
      setDeleteId(null);
      fetchOfferings();
    } catch (_) {
      await supabase.from('chadhawa_offerings').delete().eq('id', id);
      fetchOfferings();
    }
  };

  const openAdd = () => {
    setSelectedOffering(null);
    setFormData({
      title: '',
      temple_name: templeList.length > 0 ? templeList[0] : 'Kashi Vishwanath Temple',
      category: 'Sacred Metals',
      price: '',
      description: '',
      image_url: '',
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const openEdit = (item: ChadhawaOffering) => {
    setSelectedOffering(item);
    setFormData({
      title: item.title,
      temple_name: item.temple_name,
      category: item.category || 'Sacred Metals',
      price: item.price.toString(),
      description: item.description || '',
      image_url: item.image_url || '',
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const filtered = offerings.filter((o) => {
    const matchSearch =
      o.title?.toLowerCase().includes(search.toLowerCase()) ||
      o.temple_name?.toLowerCase().includes(search.toLowerCase()) ||
      o.category?.toLowerCase().includes(search.toLowerCase());
    const matchCat = selectedCategory === 'all' || o.category === selectedCategory;
    return matchSearch && matchCat;
  });

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Toast Notification */}
      {successToast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-700 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-3 border border-emerald-500 animate-bounce">
          <span className="text-lg">🌸</span>
          <span className="text-xs font-bold">{successToast}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-gradient-to-r from-pink-950 via-rose-900 to-mandir-maroon p-4 sm:p-6 rounded-2xl text-white shadow-xl border border-pink-900/30">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xl sm:text-2xl">🌸</span>
            <h1 className="text-xl sm:text-2xl font-bold font-cinzel tracking-wide text-rose-200">
              Sacred Chadhawa Offerings Console
            </h1>
          </div>
          <p className="text-[11px] sm:text-xs text-rose-100/80 leading-normal">
            Create and maintain divine offerings that devotees can book directly at temple sanctums (Silver Arpan, Vastra, Diya, Bhog).
          </p>
        </div>
        <button
          onClick={openAdd}
          className="w-full sm:w-auto justify-center px-5 py-2.5 bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 text-amber-950 font-bold rounded-xl text-xs shadow-lg transition-all flex items-center gap-2 hover:scale-105 active:scale-95 shrink-0"
        >
          <span className="text-base font-extrabold">+</span> Add Sacred Chadhawa Offering
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
              placeholder="Search by offering title, deity, or temple..."
              className="w-full pl-8 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
            />
          </div>
          <div className="flex items-center gap-3 text-xs font-semibold text-gray-600">
            <span className="bg-rose-50 text-rose-900 px-3 py-1 rounded-full border border-rose-200 text-[11px]">
              Total Offerings: <strong>{offerings.length}</strong>
            </span>
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex sm:flex-wrap items-center gap-1.5 pt-2 border-t border-gray-100 overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
          <button
            onClick={() => setSelectedCategory('all')}
            className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold transition-all shrink-0 ${
              selectedCategory === 'all'
                ? 'bg-rose-900 text-white shadow-sm'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All Categories ({offerings.length})
          </button>
          {CATEGORIES.map((cat) => {
            const count = offerings.filter((o) => o.category === cat).length;
            return (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
                  selectedCategory === cat
                    ? 'bg-rose-900 text-white shadow-sm'
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
          <div className="w-10 h-10 border-4 border-rose-900 border-t-transparent rounded-full animate-spin"></div>
          <span className="text-xs font-semibold text-gray-500">Loading Chadhawa offerings from database...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-200 p-12 text-center space-y-3 shadow-sm">
          <span className="text-4xl block">🌸</span>
          <h3 className="font-cinzel text-base font-bold text-gray-800">No Offerings Found</h3>
          <p className="text-xs text-gray-500 max-w-md mx-auto">
            {search ? 'No offerings match your current search query.' : 'No Chadhawa offerings in the database yet. Click below to add the first sacred offering!'}
          </p>
          <button
            onClick={openAdd}
            className="px-4 py-2 bg-rose-900 text-white font-bold text-xs rounded-xl hover:bg-rose-950 transition-all"
          >
            + Add First Offering
          </button>
        </div>
      ) : (
        /* Offerings Grid */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden hover:shadow-lg transition-all flex flex-col justify-between group"
            >
              <div>
                {/* Offering Image */}
                <div className="relative h-44 w-full bg-gray-100 overflow-hidden">
                  <img
                    src={
                      item.image_url && !item.image_url.includes('unsplash.com')
                        ? item.image_url
                        : item.id === 'chadhawa_1'
                        ? '/images/chadhawa/chadhawa_bilva_patra.jpg'
                        : item.id === 'chadhawa_2'
                        ? '/images/chadhawa/chadhawa_tirupati_laddu.jpg'
                        : item.id === 'chadhawa_3'
                        ? '/images/chadhawa/chadhawa_modak_garland.jpg'
                        : item.id === 'chadhawa_4'
                        ? '/images/chadhawa/chadhawa_akhand_jyoti.jpg'
                        : item.id === 'chadhawa_5'
                        ? '/images/chadhawa/chadhawa_red_chunri.jpg'
                        : item.id === 'chadhawa_6'
                        ? '/images/chadhawa/chadhawa_somnath_dhwaja.jpg'
                        : '/images/chadhawa/chadhawa_akhand_jyoti.jpg'
                    }
                    alt={item.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/images/chadhawa/chadhawa_akhand_jyoti.jpg';
                    }}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

                  <div className="absolute top-3 left-3">
                    <span className="text-[10px] font-bold text-pink-950 bg-pink-200 px-2.5 py-1 rounded-md uppercase tracking-wide shadow-md">
                      {item.category || 'Divine Offering'}
                    </span>
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
                    <p className="text-[11px] text-rose-200/90 flex items-center gap-1 mt-0.5">
                      🛕 {item.temple_name}
                    </p>
                  </div>
                </div>

                {/* Offering Description */}
                <div className="p-4 space-y-2 text-xs">
                  <p className="text-gray-600 text-xs line-clamp-3 leading-relaxed">
                    {item.description || 'Devotee offering conducted inside deity inner sanctum.'}
                  </p>
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
                    className="px-3 py-1 bg-rose-900 hover:bg-rose-950 text-white font-semibold text-xs rounded-lg transition-all shadow-sm"
                  >
                    Edit Offering
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
            <h3 className="font-bold text-base text-gray-900 font-cinzel">Confirm Offering Deletion</h3>
            <p className="text-xs text-gray-500">
              Are you sure you want to remove this sacred Chadhawa offering from the live database?
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
          <div className="bg-white rounded-2xl max-w-xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-4 sm:my-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🌸</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedOffering ? 'Edit Chadhawa Offering' : 'Fill & Add Sacred Chadhawa Offering'}
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
              {/* Row 1: Title & Price */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div className="sm:col-span-2">
                  <label className="block text-gray-700 font-bold mb-1">
                    Offering Title <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Pure Silver Bilva Patra Arpan"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-900 ${
                      formErrors.title ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.title && <p className="text-[10px] text-red-600 mt-1">{formErrors.title}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Dakshina / Price (₹) <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    min="1"
                    placeholder="e.g. 501"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-900 ${
                      formErrors.price ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.price && <p className="text-[10px] text-red-600 mt-1">{formErrors.price}</p>}
                </div>
              </div>

              {/* Row 2: Temple Destination & Category */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Destination Temple <span className="text-red-500">*</span>
                  </label>
                  <div className="space-y-1.5">
                    {templeList.length > 0 ? (
                      <select
                        value={formData.temple_name}
                        onChange={(e) => setFormData({ ...formData, temple_name: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-900 text-xs"
                      >
                        {templeList.map((name) => (
                          <option key={name} value={name}>
                            {name}
                          </option>
                        ))}
                      </select>
                    ) : (
                      <input
                        type="text"
                        placeholder="e.g. Kashi Vishwanath Temple, Varanasi"
                        value={formData.temple_name}
                        onChange={(e) => setFormData({ ...formData, temple_name: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-900"
                      />
                    )}
                  </div>
                  {formErrors.temple_name && <p className="text-[10px] text-red-600 mt-1">{formErrors.temple_name}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Offering Category <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-900 text-xs"
                  >
                    {CATEGORIES.map((cat) => (
                      <option key={cat} value={cat}>
                        {cat}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Row 3: Description (Required) */}
              <div>
                <label className="block text-gray-700 font-bold mb-1">
                  Offering Significance & Ritual Description <span className="text-red-500">*</span>
                </label>
                <textarea
                  rows={3}
                  placeholder="Detail the sacred item offered, sankalp recitation, deity blessing, and what the devotee receives..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-rose-900 ${
                    formErrors.description ? 'border-red-500 bg-red-50' : 'border-gray-200'
                  }`}
                />
                {formErrors.description && <p className="text-[10px] text-red-600 mt-1">{formErrors.description}</p>}
              </div>

              {/* Row 4: Image URL (Required) */}
              <div className="p-3 bg-rose-50/60 rounded-xl border border-rose-200/70 space-y-2">
                <label className="block text-rose-950 font-bold mb-1">
                  Offering Image URL <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="/images/chadhawa/chadhawa_akhand_jyoti.jpg"
                    value={formData.image_url}
                    onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                    className={`flex-1 p-2.5 bg-white border rounded-xl focus:outline-none focus:ring-2 focus:ring-rose-900 ${
                      formErrors.image_url ? 'border-red-500' : 'border-rose-200'
                    }`}
                  />
                  {formData.image_url && (
                    <div className="w-12 h-10 rounded-lg overflow-hidden border border-rose-300 shadow-sm shrink-0">
                      <img src={formData.image_url} alt="Preview" className="w-full h-full object-cover" />
                    </div>
                  )}
                </div>
                {formErrors.image_url && <p className="text-[10px] text-red-600">{formErrors.image_url}</p>}

                {/* Quick Presets */}
                <div>
                  <span className="text-[10px] font-bold text-rose-900 block mb-1">
                    Quick Sample Chadhawa Image Presets:
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {CHADAWA_IMAGE_PRESETS.map((preset) => (
                      <button
                        key={preset.label}
                        type="button"
                        onClick={() => setFormData({ ...formData, image_url: preset.url })}
                        className="px-2 py-1 bg-white hover:bg-rose-100 text-rose-900 rounded-lg text-[10px] font-semibold border border-rose-300 transition-colors shadow-2xs"
                      >
                        🌸 {preset.label}
                      </button>
                    ))}
                  </div>
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
                  className="px-6 py-2.5 bg-gradient-to-r from-rose-900 to-mandir-maroon text-white font-bold rounded-xl shadow-md hover:scale-102 active:scale-98 transition-all disabled:opacity-50 flex items-center gap-2"
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
