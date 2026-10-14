'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  original_price?: number;
  stock: number;
  material?: string;
  dimensions?: string;
  description: string;
  image_url: string;
  is_featured: boolean;
  rating?: number;
}

const PRODUCT_IMAGE_PRESETS = [
  { label: 'Sphatik Shivling', url: '/images/products/prod_sphatik_shivling.jpg' },
  { label: 'Royal Brass Akhand Diya', url: '/images/products/prod_akhand_diya.jpg' },
  { label: 'Nepali Rudraksha Mala', url: '/images/products/prod_rudraksha_mala.jpg' },
  { label: 'Pure Mysore Dhoop Cones', url: '/images/products/prod_mysore_dhoop.jpg' },
  { label: 'Siddh Gomati Chakra Box', url: '/images/products/prod_gomati_chakra.jpg' },
  { label: 'Pure Silver Coin (20g)', url: '/images/products/prod_silver_coin.jpg' },
];

const CATEGORIES = [
  'Idols & Murtis',
  'Puja Essentials',
  'Spiritual Jewelry',
  'Dhoop & Fragrance',
  'Yantras & Good Luck',
  'Gifting & Silver',
  'Vastra & Accessories',
];

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successToast, setSuccessToast] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);

  // Form State
  const [formData, setFormData] = useState({
    name: '',
    category: 'Idols & Murtis',
    price: '',
    original_price: '',
    stock: '50',
    material: 'Natural Sacred Material',
    dimensions: 'Standard Sanctum Size',
    description: '',
    image_url: '',
    is_featured: true,
  });

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    setIsLoading(true);
    try {
      const res = await fetch('/api/products');
      const json = await res.json();
      if (json.success && Array.isArray(json.data) && json.data.length > 0) {
        setProducts(json.data);
      } else {
        const { data } = await supabase.from('products').select('*').order('name');
        if (data && data.length > 0) {
          setProducts(data as Product[]);
        }
      }
    } catch (_) {
      const { data } = await supabase.from('products').select('*').order('name');
      if (data && data.length > 0) {
        setProducts(data as Product[]);
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
    if (!formData.name.trim()) errs.name = 'Product title / name is required';
    if (!formData.category.trim()) errs.category = 'Category is required';
    if (!formData.price || isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      errs.price = 'Valid selling price (₹) is required';
    }
    if (!formData.description.trim()) errs.description = 'Product description is required';
    if (!formData.image_url.trim()) errs.image_url = 'Product image URL is required';
    if (formData.stock === '' || isNaN(Number(formData.stock)) || Number(formData.stock) < 0) {
      errs.stock = 'Valid stock quantity is required';
    }
    setFormErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsSubmitting(true);
    setErrorMsg(null);

    const payload = {
      ...(selectedProduct ? { id: selectedProduct.id } : { id: `prod_${Date.now()}` }),
      name: formData.name.trim(),
      category: formData.category.trim(),
      price: Number(formData.price),
      original_price: formData.original_price ? Number(formData.original_price) : Number(formData.price) * 1.3,
      stock: Number(formData.stock),
      material: formData.material.trim(),
      dimensions: formData.dimensions.trim(),
      description: formData.description.trim(),
      image_url: formData.image_url.trim(),
      is_featured: formData.is_featured,
    };

    try {
      const res = await fetch('/api/products', {
        method: selectedProduct ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save product');

      showToast(selectedProduct ? 'Product updated in store catalogue!' : 'New spiritual item listed in store database!');
      setIsModalOpen(false);
      setSelectedProduct(null);
      fetchProducts();
    } catch (err: any) {
      // Direct Supabase upsert fallback
      const { error: sbErr } = await supabase.from('products').upsert(payload);
      if (!sbErr) {
        showToast('Product saved to database!');
        setIsModalOpen(false);
        setSelectedProduct(null);
        fetchProducts();
      } else {
        setErrorMsg(err.message || sbErr.message || 'Error saving product');
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await fetch(`/api/products?id=${id}`, { method: 'DELETE' });
      if (!res.ok) {
        await supabase.from('products').delete().eq('id', id);
      }
      showToast('Item deleted from store catalogue.');
      setDeleteId(null);
      fetchProducts();
    } catch (_) {
      await supabase.from('products').delete().eq('id', id);
      fetchProducts();
    }
  };

  const openAdd = () => {
    setSelectedProduct(null);
    setFormData({
      name: '',
      category: 'Idols & Murtis',
      price: '',
      original_price: '',
      stock: '50',
      material: 'Natural Sacred Material',
      dimensions: 'Standard Sanctum Size',
      description: '',
      image_url: '',
      is_featured: true,
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const openEdit = (p: Product) => {
    setSelectedProduct(p);
    setFormData({
      name: p.name,
      category: p.category || 'Idols & Murtis',
      price: p.price.toString(),
      original_price: p.original_price?.toString() || '',
      stock: p.stock?.toString() || '50',
      material: p.material || 'Natural Sacred Material',
      dimensions: p.dimensions || 'Standard Sanctum Size',
      description: p.description || '',
      image_url: p.image_url || '',
      is_featured: p.is_featured ?? true,
    });
    setFormErrors({});
    setErrorMsg(null);
    setIsModalOpen(true);
  };

  const filtered = products.filter((p) => {
    const matchSearch =
      p.name?.toLowerCase().includes(search.toLowerCase()) ||
      p.category?.toLowerCase().includes(search.toLowerCase());
    const matchCat = categoryFilter === 'all' || p.category === categoryFilter;
    return matchSearch && matchCat;
  });

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      {/* Toast Notification */}
      {successToast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-700 text-white px-5 py-3 rounded-xl shadow-2xl flex items-center gap-3 border border-emerald-500 animate-bounce">
          <span className="text-lg">🛍️</span>
          <span className="text-xs font-bold">{successToast}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-gradient-to-r from-amber-950 via-yellow-950 to-mandir-maroon p-6 rounded-2xl text-white shadow-xl border border-amber-900/30">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="text-2xl">🛍️</span>
            <h1 className="text-2xl font-bold font-cinzel tracking-wide text-amber-200">
              Spiritual Store & Items Catalogue
            </h1>
          </div>
          <p className="text-xs text-amber-100/80">
            Fill in sacred idols, consecrated yantras, authentic Rudraksha malas, and sanctum puja samagri with live pricing & stock.
          </p>
        </div>
        <button
          onClick={openAdd}
          className="px-5 py-2.5 bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 text-amber-950 font-bold rounded-xl text-xs shadow-lg transition-all flex items-center gap-2 hover:scale-105 active:scale-95"
        >
          <span className="text-base font-extrabold">+</span> Add New Product / Item
        </button>
      </div>

      {/* Filter and Stats Toolbar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 space-y-3 shadow-sm">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="relative w-full sm:w-96">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search items by title or category..."
              className="w-full pl-8 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-mandir-maroon"
            />
          </div>
          <div className="flex items-center gap-3 text-xs font-semibold text-gray-600">
            <span className="bg-amber-50 text-amber-900 px-3 py-1 rounded-full border border-amber-200">
              Total Items: <strong>{products.length}</strong>
            </span>
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex flex-wrap gap-1.5 pt-2 border-t border-gray-100">
          <button
            onClick={() => setCategoryFilter('all')}
            className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
              categoryFilter === 'all'
                ? 'bg-amber-900 text-white shadow-sm'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All Products ({products.length})
          </button>
          {CATEGORIES.map((cat) => {
            const count = products.filter((p) => p.category === cat).length;
            return (
              <button
                key={cat}
                onClick={() => setCategoryFilter(cat)}
                className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all ${
                  categoryFilter === cat
                    ? 'bg-amber-900 text-white shadow-sm'
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
          <div className="w-10 h-10 border-4 border-amber-900 border-t-transparent rounded-full animate-spin"></div>
          <span className="text-xs font-semibold text-gray-500">Loading products from database...</span>
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-white rounded-2xl border border-gray-200 p-12 text-center space-y-3 shadow-sm">
          <span className="text-4xl block">🛍️</span>
          <h3 className="font-cinzel text-base font-bold text-gray-800">No Products Found</h3>
          <p className="text-xs text-gray-500 max-w-md mx-auto">
            {search ? 'No items match your current search query.' : 'No items in the spiritual store yet. Click below to add your first consecrated item!'}
          </p>
          <button
            onClick={openAdd}
            className="px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl hover:bg-mandir-maroon-dark transition-all"
          >
            + Add First Product
          </button>
        </div>
      ) : (
        /* Products Grid */
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map((item) => (
            <div
              key={item.id}
              className="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden hover:shadow-lg transition-all flex flex-col justify-between group"
            >
              <div>
                {/* Product Image */}
                <div className="relative h-44 w-full bg-gray-100 overflow-hidden">
                  <img
                    src={
                      item.image_url && !item.image_url.includes('1544005313-94ddf0286df2') && !item.image_url.includes('1509198397868') && !item.image_url.includes('1610444583713') && !item.image_url.includes('1517841905240') && !item.image_url.includes('1599488615731') && !item.image_url.includes('1590076212472')
                        ? item.image_url
                        : item.id === 'prod_1'
                        ? '/images/products/prod_sphatik_shivling.jpg'
                        : item.id === 'prod_2'
                        ? '/images/products/prod_akhand_diya.jpg'
                        : item.id === 'prod_3'
                        ? '/images/products/prod_rudraksha_mala.jpg'
                        : item.id === 'prod_4'
                        ? '/images/products/prod_mysore_dhoop.jpg'
                        : item.id === 'prod_5'
                        ? '/images/products/prod_gomati_chakra.jpg'
                        : item.id === 'prod_6'
                        ? '/images/products/prod_silver_coin.jpg'
                        : '/images/products/prod_sphatik_shivling.jpg'
                    }
                    alt={item.name}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/images/products/prod_sphatik_shivling.jpg';
                    }}
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

                  <div className="absolute top-3 left-3 flex gap-2">
                    <span className="text-[10px] font-bold text-amber-950 bg-amber-300 px-2.5 py-1 rounded-md uppercase tracking-wide shadow-md">
                      {item.category}
                    </span>
                    {item.is_featured && (
                      <span className="text-[10px] font-bold text-white bg-mandir-maroon px-2 py-0.5 rounded-md shadow-md">
                        ★ Featured
                      </span>
                    )}
                  </div>

                  <div className="absolute top-3 right-3">
                    <span
                      className={`text-[10px] font-bold px-2 py-0.5 rounded-full shadow-md ${
                        item.stock > 10 ? 'bg-emerald-500 text-white' : 'bg-red-500 text-white'
                      }`}
                    >
                      {item.stock > 0 ? `${item.stock} in stock` : 'Out of Stock'}
                    </span>
                  </div>

                  <div className="absolute bottom-3 left-3 right-3 text-white">
                    <h3 className="font-bold text-sm font-cinzel text-white leading-tight drop-shadow-md">
                      {item.name}
                    </h3>
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-sm font-black text-amber-300">
                        ₹ {Number(item.price).toLocaleString('en-IN')}
                      </span>
                      {item.original_price && Number(item.original_price) > Number(item.price) && (
                        <span className="text-xs text-gray-300 line-through">
                          ₹ {Number(item.original_price).toLocaleString('en-IN')}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Description & Specs */}
                <div className="p-4 space-y-2 text-xs">
                  <p className="text-gray-600 text-xs line-clamp-2 leading-relaxed">
                    {item.description || 'Consecrated sanctum item for devotion and positivity.'}
                  </p>

                  <div className="pt-2 border-t border-gray-100 flex items-center justify-between text-[11px] text-gray-500">
                    <span>Material: <strong className="text-gray-800">{item.material || 'Natural'}</strong></span>
                    <span>Dimensions: <strong className="text-gray-800">{item.dimensions || 'Standard'}</strong></span>
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
                    className="px-3 py-1 bg-amber-900 hover:bg-amber-950 text-white font-semibold text-xs rounded-lg transition-all shadow-sm"
                  >
                    Edit Item
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
            <h3 className="font-bold text-base text-gray-900 font-cinzel">Confirm Item Deletion</h3>
            <p className="text-xs text-gray-500">
              Are you sure you want to remove this spiritual store item from the live database?
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
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-2xl border border-gray-200 my-8">
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🛍️</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedProduct ? 'Edit Spiritual Store Item' : 'Fill & List New Spiritual Item'}
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
              {/* Row 1: Name & Category */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div className="sm:col-span-2">
                  <label className="block text-gray-700 font-bold mb-1">
                    Item Name / Title <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    placeholder="e.g. Consecrated Brass Akhand Diya"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900 ${
                      formErrors.name ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.name && <p className="text-[10px] text-red-600 mt-1">{formErrors.name}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Category <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900 text-xs"
                  >
                    {CATEGORIES.map((cat) => (
                      <option key={cat} value={cat}>
                        {cat}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Row 2: Price, MRP, Stock */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Selling Price (₹) <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    min="1"
                    placeholder="e.g. 1499"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900 ${
                      formErrors.price ? 'border-red-500 bg-red-50' : 'border-gray-200'
                    }`}
                  />
                  {formErrors.price && <p className="text-[10px] text-red-600 mt-1">{formErrors.price}</p>}
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">Original Price / MRP (₹)</label>
                  <input
                    type="number"
                    min="1"
                    placeholder="e.g. 2499"
                    value={formData.original_price}
                    onChange={(e) => setFormData({ ...formData, original_price: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">
                    Available Stock <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    min="0"
                    placeholder="e.g. 50"
                    value={formData.stock}
                    onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900"
                  />
                  {formErrors.stock && <p className="text-[10px] text-red-600 mt-1">{formErrors.stock}</p>}
                </div>
              </div>

              {/* Row 3: Material & Dimensions */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-bold mb-1">Material / Sanctum Source</label>
                  <input
                    type="text"
                    placeholder="e.g. Solid Polished Brass, Natural Sphatik"
                    value={formData.material}
                    onChange={(e) => setFormData({ ...formData, material: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-bold mb-1">Dimensions / Weight</label>
                  <input
                    type="text"
                    placeholder="e.g. 7.5 inches height, 450 grams"
                    value={formData.dimensions}
                    onChange={(e) => setFormData({ ...formData, dimensions: e.target.value })}
                    className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900"
                  />
                </div>
              </div>

              {/* Row 4: Description (Required) */}
              <div>
                <label className="block text-gray-700 font-bold mb-1">
                  Product Significance & Description <span className="text-red-500">*</span>
                </label>
                <textarea
                  rows={3}
                  placeholder="Detail the spiritual energization, Vedic mantras recited, authenticity certs, and usage guidelines..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-2 focus:ring-amber-900 ${
                    formErrors.description ? 'border-red-500 bg-red-50' : 'border-gray-200'
                  }`}
                />
                {formErrors.description && <p className="text-[10px] text-red-600 mt-1">{formErrors.description}</p>}
              </div>

              {/* Row 5: Image URL (Required) */}
              <div className="p-3 bg-amber-50/60 rounded-xl border border-amber-200/70 space-y-2">
                <label className="block text-amber-950 font-bold mb-1">
                  Product Image URL <span className="text-red-500">*</span>
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="/images/products/prod_sphatik_shivling.jpg"
                    value={formData.image_url}
                    onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                    className={`flex-1 p-2.5 bg-white border rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-900 ${
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
                    Quick Sample Product Image Presets:
                  </span>
                  <div className="flex flex-wrap gap-1.5">
                    {PRODUCT_IMAGE_PRESETS.map((preset) => (
                      <button
                        key={preset.label}
                        type="button"
                        onClick={() => setFormData({ ...formData, image_url: preset.url })}
                        className="px-2 py-1 bg-white hover:bg-amber-100 text-amber-900 rounded-lg text-[10px] font-semibold border border-amber-300 transition-colors shadow-2xs"
                      >
                        🛍️ {preset.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Featured checkbox */}
              <div className="flex items-center gap-2 p-2.5 bg-gray-50 border border-gray-200 rounded-xl">
                <input
                  type="checkbox"
                  id="prod_featured"
                  checked={formData.is_featured}
                  onChange={(e) => setFormData({ ...formData, is_featured: e.target.checked })}
                  className="w-4 h-4 text-mandir-maroon rounded focus:ring-mandir-maroon"
                />
                <label htmlFor="prod_featured" className="text-gray-700 font-bold text-xs select-none">
                  Highlight on Home & Spiritual Store Featured Banner
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
                  className="px-6 py-2.5 bg-gradient-to-r from-amber-900 to-mandir-maroon text-white font-bold rounded-xl shadow-md hover:scale-102 active:scale-98 transition-all disabled:opacity-50 flex items-center gap-2"
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
