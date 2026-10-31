'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';
import { autoTranslateText } from '@/lib/autoTranslate';

interface FAQItem {
  question: string;
  answer: string;
  question_hi?: string;
  answer_hi?: string;
}

interface Product {
  id: string;
  name: string;
  name_hi?: string;
  category: string;
  price: number;
  original_price?: number;
  stock: number;
  material?: string;
  material_hi?: string;
  dimensions?: string;
  description: string;
  description_hi?: string;
  benefits?: string;
  benefits_hi?: string;
  how_to_use?: string;
  how_to_use_hi?: string;
  package_contents?: string;
  package_contents_hi?: string;
  image_url: string;
  is_featured: boolean;
  rating?: number;
  faqs?: FAQItem[];
}

const PRODUCT_IMAGE_PRESETS = [
  { label: 'Sphatik Shivling', url: '/images/products/prod_sphatik_shivling.jpg' },
  { label: 'Royal Brass Akhand Diya', url: '/images/products/prod_akhand_diya.jpg' },
  { label: 'Nepali Rudraksha Mala', url: '/images/products/prod_rudraksha_mala.jpg' },
  { label: 'Pure Mysore Dhoop Cones', url: '/images/products/prod_mysore_dhoop.jpg' },
  { label: 'Siddh Gomati Chakra Box', url: '/images/products/prod_gomati_chakra.jpg' },
  { label: 'Pure Silver Coin (20g)', url: '/images/products/prod_silver_coin.jpg' },
];

const CATEGORIES_DATA = [
  { en: 'Idols & Murtis', hi: 'दिव्य मूर्तियां' },
  { en: 'Puja Essentials', hi: 'पूजा सामग्री' },
  { en: 'Spiritual Jewelry', hi: 'रुद्राक्ष एवं माला' },
  { en: 'Dhoop & Fragrance', hi: 'धूप एवं सुगंधि' },
  { en: 'Yantras & Good Luck', hi: 'सिद्ध यंत्र' },
  { en: 'Gifting & Silver', hi: 'चांदी एवं उपहार' },
  { en: 'Vastra & Accessories', hi: 'वस्त्र एवं शृंगार' },
];

const DEFAULT_PRODUCT_FAQS: FAQItem[] = [
  {
    question: "Is this item authentic and Pran Pratishthit (consecrated)?",
    question_hi: "क्या यह सामग्री पूर्णतः प्रामाणिक और प्राण प्रतिष्ठित है?",
    answer: "Yes, 100%. Every item is strictly sourced from authentic pilgrim origins and consecrated through Vedic rituals by learned Sanskrit acharyas.",
    answer_hi: "हाँ, शत-प्रतिशत। प्रत्येक सामग्री सीधे तीर्थ उद्गम से प्राप्त की जाती है और विद्वान वैदिक आचार्यों द्वारा प्राण-प्रतिष्ठित की जाती है।"
  },
  {
    question: "What is the recommended Sthapana Vidhi (method of placement) at home?",
    question_hi: "घर पर इस सामग्री की स्थापना विधि क्या है?",
    answer: "Place the sacred item on a clean altar or puja mandir in the North-East direction on an auspicious day. Purify with Gangajal and light a pure ghee lamp.",
    answer_hi: "शुभ मुहूर्त में पूजा घर के ईशान कोण में लाल या पीले वस्त्र पर स्थापित करें। गंगाजल से शुद्ध कर गाय के घी का दीपक प्रज्वलित करें।"
  },
  {
    question: "What is the delivery time and transit packaging safety?",
    question_hi: "डिलीवरी में कितना समय लगता है और पैकेजिंग कितनी सुरक्षित है?",
    answer: "Orders are shipped within 24 hours in multi-layered cushioned sanctum packaging. Doorstep delivery takes 3 to 5 business days across India with live tracking.",
    answer_hi: "ऑर्डर 24 घंटे के भीतर बहुस्तरीय सुरक्षित कुशन पैकेजिंग में रवाना किया जाता है। पूरे भारत में 3-5 दिनों में लाइव ट्रैकिंग सहित होम डिलीवरी होती है।"
  },
  {
    question: "Can this sacred product be gifted to someone?",
    question_hi: "क्या यह आध्यात्मिक उत्पाद किसी को उपहार में दिया जा सकता है?",
    answer: "Absolutely! Gifting sacred consecrated murtis, rudrakshas, and diya sets for Griha Pravesh, weddings, and festivals is considered highly auspicious.",
    answer_hi: "निसंदेह! गृह प्रवेश, विवाह, जन्मदिन और पावन पर्वों पर प्राण प्रतिष्ठित सामग्री भेंट करना अत्यंत शुभ और पुण्यदायी माना गया है।"
  }
];

export default function ProductsPage() {
  const { isHindi } = useAdminLanguage();
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
  const [modalTab, setModalTab] = useState<'basic' | 'details' | 'faqs'>('basic');

  // Form State with bilingual & Sri Mandir full details
  const [formData, setFormData] = useState({
    name: '',
    name_hi: '',
    category: 'Idols & Murtis',
    price: '',
    original_price: '',
    stock: '50',
    material: 'Natural Sacred Material',
    material_hi: '',
    dimensions: 'Standard Sanctum Size',
    description: '',
    description_hi: '',
    benefits: '',
    benefits_hi: '',
    how_to_use: '',
    how_to_use_hi: '',
    package_contents: '',
    package_contents_hi: '',
    image_url: '',
    is_featured: true,
    faqs: [] as FAQItem[],
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
        setProducts((data as Product[]) || []);
      }
    } catch (_) {
      const { data } = await supabase.from('products').select('*').order('name');
      setProducts((data as Product[]) || []);
    } finally {
      setIsLoading(false);
    }
  };

  const showToast = (msg: string) => {
    setSuccessToast(msg);
    setTimeout(() => setSuccessToast(null), 3500);
  };

  const handleAutoFillHindi = () => {
    setFormData((prev) => ({
      ...prev,
      name_hi: prev.name_hi.trim() ? prev.name_hi : autoTranslateText(prev.name),
      description_hi: prev.description_hi.trim() ? prev.description_hi : autoTranslateText(prev.description),
      material_hi: prev.material_hi.trim() ? prev.material_hi : autoTranslateText(prev.material),
      benefits_hi: prev.benefits_hi.trim() ? prev.benefits_hi : autoTranslateText(prev.benefits),
      how_to_use_hi: prev.how_to_use_hi.trim() ? prev.how_to_use_hi : autoTranslateText(prev.how_to_use),
      package_contents_hi: prev.package_contents_hi.trim() ? prev.package_contents_hi : autoTranslateText(prev.package_contents),
      faqs: prev.faqs.map((f) => ({
        ...f,
        question_hi: f.question_hi?.trim() ? f.question_hi : autoTranslateText(f.question),
        answer_hi: f.answer_hi?.trim() ? f.answer_hi : autoTranslateText(f.answer),
      })),
    }));
    showToast(isHindi ? 'हिन्दी अनुवाद स्वतः तैयार कर लिया गया!' : 'Hindi translations auto-filled!');
  };

  const addFaq = () => {
    setFormData((prev) => ({
      ...prev,
      faqs: [...prev.faqs, { question: '', answer: '', question_hi: '', answer_hi: '' }],
    }));
  };

  const updateFaq = (index: number, field: keyof FAQItem, val: string) => {
    setFormData((prev) => {
      const updated = [...prev.faqs];
      updated[index] = { ...updated[index], [field]: val };
      return { ...prev, faqs: updated };
    });
  };

  const removeFaq = (index: number) => {
    setFormData((prev) => ({
      ...prev,
      faqs: prev.faqs.filter((_, i) => i !== index),
    }));
  };

  const loadDefaultFaqs = () => {
    setFormData((prev) => ({
      ...prev,
      faqs: DEFAULT_PRODUCT_FAQS,
    }));
    showToast(isHindi ? 'सनातन प्रामाणिक FAQ लोड हो गए!' : 'Standard Sanatan FAQs loaded!');
  };

  const validateForm = () => {
    const errs: Record<string, string> = {};
    if (!formData.name.trim()) errs.name = isHindi ? 'उत्पाद का नाम अनिवार्य है' : 'Product title / name is required';
    if (!formData.category.trim()) errs.category = isHindi ? 'श्रेणी अनिवार्य है' : 'Category is required';
    if (!formData.price || isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      errs.price = isHindi ? 'मान्य मूल्य (₹) आवश्यक है' : 'Valid selling price (₹) is required';
    }
    if (!formData.description.trim()) errs.description = isHindi ? 'विवरण आवश्यक है' : 'Product description is required';
    if (!formData.image_url.trim()) errs.image_url = isHindi ? 'फोटो URL आवश्यक है' : 'Product image URL is required';
    setFormErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setIsSubmitting(true);
    setErrorMsg(null);

    const payload = {
      ...(selectedProduct ? { id: selectedProduct.id } : { id: `product_${Date.now()}` }),
      name: formData.name.trim(),
      name_hi: formData.name_hi.trim() || undefined,
      category: formData.category.trim(),
      price: Number(formData.price),
      original_price: formData.original_price ? Number(formData.original_price) : Number(formData.price) * 1.3,
      stock: Number(formData.stock) || 10,
      material: formData.material.trim() || 'Sacred Natural Material',
      material_hi: formData.material_hi.trim() || undefined,
      dimensions: formData.dimensions.trim() || 'Standard Sanctum Size',
      description: formData.description.trim(),
      description_hi: formData.description_hi.trim() || undefined,
      benefits: formData.benefits.trim() || undefined,
      benefits_hi: formData.benefits_hi.trim() || undefined,
      how_to_use: formData.how_to_use.trim() || undefined,
      how_to_use_hi: formData.how_to_use_hi.trim() || undefined,
      package_contents: formData.package_contents.trim() || undefined,
      package_contents_hi: formData.package_contents_hi.trim() || undefined,
      image_url: formData.image_url.trim(),
      is_featured: formData.is_featured,
      faqs: formData.faqs,
    };

    try {
      const res = await fetch('/api/products', {
        method: selectedProduct ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save product');

      showToast(
        selectedProduct
          ? (isHindi ? 'उत्पाद विवरण अपडेट हुआ!' : 'Product updated in database!')
          : (isHindi ? 'नया उत्पाद सफलतापूर्वक जोड़ा गया!' : 'New spiritual product listed in database!')
      );
      setIsModalOpen(false);
      setSelectedProduct(null);
      fetchProducts();
    } catch (err: any) {
      const { error: sbErr } = await supabase.from('products').upsert(payload);
      if (!sbErr) {
        showToast(isHindi ? 'उत्पाद डेटाबेस में सुरक्षित हो गया!' : 'Product saved to database!');
        setIsModalOpen(false);
        setSelectedProduct(null);
        fetchProducts();
      } else {
        setErrorMsg(err.message || sbErr.message || (isHindi ? 'त्रुटि उत्पन्न हुई' : 'Error saving product'));
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
      showToast(isHindi ? 'उत्पाद सूची से हटाया गया।' : 'Product removed from store.');
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
      name_hi: '',
      category: 'Idols & Murtis',
      price: '',
      original_price: '',
      stock: '50',
      material: isHindi ? 'प्राकृतिक पवित्र सामग्री' : 'Natural Sacred Material',
      material_hi: '',
      dimensions: isHindi ? 'मानक गर्भगृह आकार' : 'Standard Sanctum Size',
      description: '',
      description_hi: '',
      benefits: '',
      benefits_hi: '',
      how_to_use: '',
      how_to_use_hi: '',
      package_contents: '',
      package_contents_hi: '',
      image_url: '',
      is_featured: true,
      faqs: DEFAULT_PRODUCT_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const openEdit = (prod: Product) => {
    setSelectedProduct(prod);
    setFormData({
      name: prod.name,
      name_hi: prod.name_hi || '',
      category: prod.category || 'Idols & Murtis',
      price: prod.price.toString(),
      original_price: prod.original_price?.toString() || '',
      stock: prod.stock.toString(),
      material: prod.material || '',
      material_hi: prod.material_hi || '',
      dimensions: prod.dimensions || '',
      description: prod.description || '',
      description_hi: prod.description_hi || '',
      benefits: prod.benefits || '',
      benefits_hi: prod.benefits_hi || '',
      how_to_use: prod.how_to_use || '',
      how_to_use_hi: prod.how_to_use_hi || '',
      package_contents: prod.package_contents || '',
      package_contents_hi: prod.package_contents_hi || '',
      image_url: prod.image_url || '',
      is_featured: prod.is_featured ?? true,
      faqs: prod.faqs && prod.faqs.length > 0 ? prod.faqs : DEFAULT_PRODUCT_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const filteredProducts = products.filter((p) => {
    const q = search.toLowerCase();
    const matchSearch =
      p.name.toLowerCase().includes(q) ||
      (p.name_hi && p.name_hi.toLowerCase().includes(q)) ||
      p.category.toLowerCase().includes(q) ||
      p.description.toLowerCase().includes(q);
    const matchCat = categoryFilter === 'all' || p.category.toLowerCase().includes(categoryFilter.toLowerCase());
    return matchSearch && matchCat;
  });

  return (
    <div className="space-y-6">
      {/* Toast Notification */}
      {successToast && (
        <div className="fixed top-6 right-6 z-50 bg-emerald-600 text-white font-bold text-xs px-4 py-3 rounded-xl shadow-xl flex items-center gap-2 animate-in slide-in-from-top-2">
          <span>✓</span>
          <span>{successToast}</span>
        </div>
      )}

      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-5 rounded-2xl border border-gray-200 shadow-xs">
        <div>
          <div className="inline-flex items-center gap-1.5 bg-amber-50 text-amber-800 border border-amber-200/80 px-2.5 py-0.5 rounded-full text-xs font-semibold mb-1">
            <span>📦 {isHindi ? 'पवित्र स्टोर प्रबंधन' : 'Sacred Store Inventory'}</span>
          </div>
          <h1 className="text-xl sm:text-2xl font-bold font-cinzel text-gray-900">
            {isHindi ? 'आध्यात्मिक पूजा भंडार' : 'Spiritual Puja Store Products'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'प्रमाणित मूर्तियां, रुद्राक्ष, यंत्र एवं हवन सामग्री का प्रबंधन, संपूर्ण विवरण व FAQ सहित'
              : 'Manage consecrated murtis, rudrakshas, yantras & havan essentials with full Sri Mandir details & FAQs'}
          </p>
        </div>

        <button
          onClick={openAdd}
          className="px-4 py-2.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-95 shrink-0"
        >
          <span>✨</span>
          <span>{isHindi ? '+ नया उत्पाद जोड़ें' : '+ Add New Product'}</span>
        </button>
      </div>

      {/* Filter & Search Bar */}
      <div className="flex flex-col sm:flex-row gap-3 bg-white p-3 rounded-2xl border border-gray-200 shadow-xs">
        <div className="relative flex-1">
          <input
            type="text"
            placeholder={isHindi ? 'उत्पाद खोजें (नाम, श्रेणी, विवरण)...' : 'Search products by title, category, description...'}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
          <span className="absolute left-3 top-2.5 text-gray-400 text-xs">🔍</span>
        </div>

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value)}
          className="px-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs font-medium focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon shrink-0"
        >
          <option value="all">{isHindi ? 'सभी श्रेणियां' : 'All Categories'}</option>
          {CATEGORIES_DATA.map((cat) => (
            <option key={cat.en} value={cat.en}>
              {isHindi ? cat.hi : cat.en}
            </option>
          ))}
        </select>
      </div>

      {/* Products Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="bg-white rounded-2xl p-4 border border-gray-200 h-64 animate-pulse" />
          ))}
        </div>
      ) : filteredProducts.length === 0 ? (
        <div className="bg-white rounded-2xl p-12 text-center border border-gray-200 shadow-xs">
          <span className="text-4xl block mb-2">📦</span>
          <h3 className="font-bold text-gray-800 text-sm">
            {isHindi ? 'कोई उत्पाद नहीं मिला' : 'No Spiritual Products Found'}
          </h3>
          <p className="text-xs text-gray-500 mt-1">
            {isHindi ? 'कृपया अपनी खोज बदलें अथवा नया उत्पाद जोड़ें।' : 'Try refining your search filter or list a new product.'}
          </p>
          <button
            onClick={openAdd}
            className="mt-4 px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl shadow-xs"
          >
            {isHindi ? '+ नया उत्पाद जोड़ें' : '+ Add Product'}
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {filteredProducts.map((prod) => (
            <div
              key={prod.id}
              className="bg-white rounded-2xl border border-gray-200 p-4 shadow-xs hover:shadow-md transition-all flex flex-col justify-between"
            >
              <div>
                <div className="relative h-44 w-full rounded-xl overflow-hidden bg-gray-50 mb-3 border border-gray-100">
                  <img
                    src={prod.image_url}
                    alt={prod.name}
                    className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
                  />
                  <span className="absolute top-2 left-2 bg-black/70 backdrop-blur-md text-amber-200 text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    {prod.category}
                  </span>
                  {prod.is_featured && (
                    <span className="absolute top-2 right-2 bg-amber-500 text-mandir-maroon-deep text-[10px] font-extrabold px-2 py-0.5 rounded shadow">
                      ★ {isHindi ? 'विशेष' : 'Featured'}
                    </span>
                  )}
                </div>

                <div className="flex items-start justify-between gap-2">
                  <div>
                    <h3 className="font-bold text-sm text-gray-900 line-clamp-1">
                      {isHindi && prod.name_hi ? prod.name_hi : prod.name}
                    </h3>
                    {prod.name_hi && !isHindi && (
                      <p className="text-[10px] text-amber-800 font-medium line-clamp-1">{prod.name_hi}</p>
                    )}
                  </div>
                  <div className="text-right shrink-0">
                    <span className="text-sm font-bold text-mandir-maroon">₹{prod.price}</span>
                    {prod.original_price && prod.original_price > prod.price && (
                      <span className="text-[10px] text-gray-400 line-through block">₹{prod.original_price}</span>
                    )}
                  </div>
                </div>

                <p className="text-xs text-gray-500 mt-2 line-clamp-2 leading-relaxed">
                  {isHindi && prod.description_hi ? prod.description_hi : prod.description}
                </p>

                {/* Details Pills */}
                <div className="mt-3 pt-2 border-t border-gray-100 flex flex-wrap gap-1.5 text-[10px]">
                  <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded-md">
                    {isHindi ? 'स्टॉक: ' : 'Stock: '} {prod.stock}
                  </span>
                  {prod.material && (
                    <span className="bg-amber-50 text-amber-900 px-2 py-0.5 rounded-md line-clamp-1">
                      {isHindi && prod.material_hi ? prod.material_hi : prod.material}
                    </span>
                  )}
                  {prod.faqs && prod.faqs.length > 0 && (
                    <span className="bg-emerald-50 text-emerald-800 font-bold px-2 py-0.5 rounded-md">
                      ✓ {prod.faqs.length} FAQs
                    </span>
                  )}
                </div>
              </div>

              {/* Action Buttons */}
              <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between gap-2">
                <button
                  onClick={() => openEdit(prod)}
                  className="flex-1 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-800 font-bold text-xs rounded-xl transition-colors flex items-center justify-center gap-1"
                >
                  <span>✏️</span>
                  <span>{isHindi ? 'संपादित करें' : 'Edit'}</span>
                </button>
                <button
                  onClick={() => setDeleteId(prod.id)}
                  className="px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-600 font-bold text-xs rounded-xl transition-colors"
                  title={isHindi ? 'हटाएं' : 'Delete'}
                >
                  🗑️
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteId && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-sm w-full p-5 text-center shadow-xl space-y-3">
            <span className="text-3xl">⚠️</span>
            <h4 className="font-bold text-sm text-gray-900">
              {isHindi ? 'उत्पाद हटाने की पुष्टि' : 'Confirm Product Deletion'}
            </h4>
            <p className="text-xs text-gray-500">
              {isHindi
                ? 'क्या आप सचमुच इस उत्पाद को लाइव डेटाबेस से हटाना चाहते हैं?'
                : 'Are you sure you want to remove this product from the live database?'}
            </p>
            <div className="flex items-center justify-center gap-3 pt-2">
              <button
                onClick={() => setDeleteId(null)}
                className="px-4 py-2 border border-gray-300 rounded-xl text-xs font-semibold text-gray-700 hover:bg-gray-50"
              >
                {isHindi ? 'रद्द करें' : 'Cancel'}
              </button>
              <button
                onClick={() => handleDelete(deleteId)}
                className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-xl text-xs font-bold shadow-md"
              >
                {isHindi ? 'हाँ, हटाएं' : 'Yes, Delete'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Comprehensive Add / Edit Product Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-center justify-center p-3 sm:p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-3xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-4 sm:my-8 max-h-[92vh] overflow-y-auto">
            {/* Modal Header with Auto-Translate Button */}
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🛍️</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedProduct
                      ? (isHindi ? 'उत्पाद विवरण एवं FAQ संपादित करें' : 'Edit Spiritual Product & FAQs')
                      : (isHindi ? 'नया उत्पाद व विस्तृत विवरण जोड़ें' : 'Add New Spiritual Product & Full Details')}
                  </h2>
                  <p className="text-[11px] text-gray-500">
                    {isHindi ? 'श्री मंदिरम् एकीकृत विवरण एवं द्विभाषी (EN/HI) प्रबंधन' : 'Sri Mandir unified details, vidhi & bilingual support'}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={handleAutoFillHindi}
                  className="px-3 py-1.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-mandir-maroon-deep font-extrabold text-xs rounded-xl shadow-xs transition-all flex items-center gap-1 active:scale-95"
                  title="Auto-translate English text to natural Hindi"
                >
                  <span>✨</span>
                  <span>{isHindi ? 'हिन्दी में स्वतः भरें' : 'Auto-Fill Hindi'}</span>
                </button>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 flex items-center justify-center text-sm font-bold"
                >
                  ✕
                </button>
              </div>
            </div>

            {/* Modal Navigation Tabs */}
            <div className="flex border-b border-gray-200 mt-3 text-xs font-bold">
              <button
                type="button"
                onClick={() => setModalTab('basic')}
                className={`py-2 px-4 border-b-2 transition-all ${
                  modalTab === 'basic'
                    ? 'border-mandir-maroon text-mandir-maroon'
                    : 'border-transparent text-gray-500 hover:text-gray-800'
                }`}
              >
                1. {isHindi ? 'बुनियादी व मूल्य' : 'Basic & Pricing'}
              </button>
              <button
                type="button"
                onClick={() => setModalTab('details')}
                className={`py-2 px-4 border-b-2 transition-all ${
                  modalTab === 'details'
                    ? 'border-mandir-maroon text-mandir-maroon'
                    : 'border-transparent text-gray-500 hover:text-gray-800'
                }`}
              >
                2. {isHindi ? 'विस्तृत विवरण व स्थापना विधि' : 'Full Explanation & Vidhi'}
              </button>
              <button
                type="button"
                onClick={() => setModalTab('faqs')}
                className={`py-2 px-4 border-b-2 transition-all ${
                  modalTab === 'faqs'
                    ? 'border-mandir-maroon text-mandir-maroon'
                    : 'border-transparent text-gray-500 hover:text-gray-800'
                }`}
              >
                3. {isHindi ? `FAQ प्रश्नोत्तरी (${formData.faqs.length})` : `FAQs (${formData.faqs.length})`}
              </button>
            </div>

            {errorMsg && (
              <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-xs font-semibold">
                ⚠️ {errorMsg}
              </div>
            )}

            <form onSubmit={handleSave} className="space-y-4 mt-4 text-xs">
              {/* TAB 1: BASIC & PRICING */}
              {modalTab === 'basic' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'उत्पाद का नाम (अंग्रेज़ी) *' : 'Product Title / Name (English) *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Pure Sphatik Shivling"
                        value={formData.name}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.name ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.name && <p className="text-[10px] text-red-600 mt-1">{formErrors.name}</p>}
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1 flex items-center justify-between">
                        <span>{isHindi ? 'उत्पाद का नाम (हिन्दी)' : 'Product Title (Hindi)'}</span>
                        <span className="text-[10px] text-amber-700 font-normal">टोनी / ट्रांसलेशन हेतु</span>
                      </label>
                      <input
                        type="text"
                        placeholder="उदा. प्राण प्रतिष्ठित स्फटिक शिवलिंग"
                        value={formData.name_hi}
                        onChange={(e) => setFormData({ ...formData, name_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'उत्पाद श्रेणी *' : 'Category *'}
                      </label>
                      <select
                        value={formData.category}
                        onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon text-xs"
                      >
                        {CATEGORIES_DATA.map((cat) => (
                          <option key={cat.en} value={cat.en}>
                            {isHindi ? cat.hi : cat.en}
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'विक्रय मूल्य (₹) *' : 'Selling Price (₹) *'}
                      </label>
                      <input
                        type="number"
                        min="1"
                        placeholder="1250"
                        value={formData.price}
                        onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.price ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.price && <p className="text-[10px] text-red-600 mt-1">{formErrors.price}</p>}
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'मूल्य (कटौती हेतु ₹)' : 'Original MRP (₹)'}
                      </label>
                      <input
                        type="number"
                        min="1"
                        placeholder="1800"
                        value={formData.original_price}
                        onChange={(e) => setFormData({ ...formData, original_price: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'उपलब्ध स्टॉक मात्रा' : 'Stock Quantity'}
                      </label>
                      <input
                        type="number"
                        min="0"
                        value={formData.stock}
                        onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'निर्मित धातु (EN)' : 'Material (EN)'}
                      </label>
                      <input
                        type="text"
                        placeholder="Pure Himalayan Sphatik Quartz"
                        value={formData.material}
                        onChange={(e) => setFormData({ ...formData, material: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'निर्मित धातु (हिन्दी)' : 'Material (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="प्राकृतिक हिमालयी स्फटिक"
                        value={formData.material_hi}
                        onChange={(e) => setFormData({ ...formData, material_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-gray-700 font-bold mb-1">
                      {isHindi ? 'फोटो URL *' : 'Image URL *'}
                    </label>
                    <input
                      type="text"
                      placeholder="https://... or select preset below"
                      value={formData.image_url}
                      onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                      className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                        formErrors.image_url ? 'border-red-500 bg-red-50' : 'border-gray-200'
                      }`}
                    />
                    {formErrors.image_url && <p className="text-[10px] text-red-600 mt-1">{formErrors.image_url}</p>}

                    <div className="flex items-center gap-1.5 flex-wrap mt-2">
                      <span className="text-[10px] text-gray-500 font-semibold">{isHindi ? 'त्वरित फोटो चुनें:' : 'Presets:'}</span>
                      {PRODUCT_IMAGE_PRESETS.map((p) => (
                        <button
                          key={p.url}
                          type="button"
                          onClick={() => setFormData({ ...formData, image_url: p.url })}
                          className="text-[10px] px-2 py-0.5 bg-gray-100 hover:bg-gray-200 rounded-md border border-gray-200"
                        >
                          {p.label}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              )}

              {/* TAB 2: FULL EXPLANATION & VIDHI (SRI MANDIR STYLE) */}
              {modalTab === 'details' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  {/* Descriptions */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'उत्पाद विवरण (अंग्रेज़ी) *' : 'Product Description (English) *'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Detailed authentic description of the consecrated item..."
                        value={formData.description}
                        onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.description ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.description && <p className="text-[10px] text-red-600 mt-1">{formErrors.description}</p>}
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'उत्पाद विवरण (हिन्दी)' : 'Product Description (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="पवित्र सामग्री का विस्तृत एवं प्रामाणिक हिन्दी विवरण..."
                        value={formData.description_hi}
                        onChange={(e) => setFormData({ ...formData, description_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Spiritual Significance & Benefits */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'आध्यात्मिक महत्व व फलश्रुति (EN)' : 'Spiritual Significance & Divine Benefits (EN)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Why keep this at home? Radiates positive energy, dissolves negative vibrations..."
                        value={formData.benefits}
                        onChange={(e) => setFormData({ ...formData, benefits: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'आध्यात्मिक महत्व व फलश्रुति (हिन्दी)' : 'Spiritual Significance & Benefits (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="घर पर रखने का आध्यात्मिक लाभ: सकारात्मक ऊर्जा का संचार, वास्तु दोष शांति..."
                        value={formData.benefits_hi}
                        onChange={(e) => setFormData({ ...formData, benefits_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Sthapana Vidhi / How to Use */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'स्थापना एवं नित्य पूजन विधि (EN)' : 'Sthapana Vidhi / How to Clean & Worship (EN)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Place in Ishan Kon (North-East) on red silk. Clean with Gangajal before invocation..."
                        value={formData.how_to_use}
                        onChange={(e) => setFormData({ ...formData, how_to_use: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'स्थापना एवं नित्य पूजन विधि (हिन्दी)' : 'Sthapana Vidhi & Worship Method (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="ईशान कोण में लाल या पीले वस्त्र पर स्थापित करें। गंगाजल से शुद्ध कर धूप-दीप दिखाएं..."
                        value={formData.how_to_use_hi}
                        onChange={(e) => setFormData({ ...formData, how_to_use_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Package Contents / In the Box */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'पैकेज में समाविष्ट सामग्री (EN)' : 'Package Contents / In the Box (EN)'}
                      </label>
                      <input
                        type="text"
                        placeholder="1x Consecrated Item, Authenticity Certificate, Gangajal Vial, Roli"
                        value={formData.package_contents}
                        onChange={(e) => setFormData({ ...formData, package_contents: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'पैकेज में समाविष्ट सामग्री (हिन्दी)' : 'Package Contents (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="1x प्राण प्रतिष्ठित विग्रह, प्रामाणिकता प्रमाण पत्र, गंगाजल, रोली-चंदन"
                        value={formData.package_contents_hi}
                        onChange={(e) => setFormData({ ...formData, package_contents_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>
                </div>
              )}

              {/* TAB 3: FAQS EDITOR */}
              {modalTab === 'faqs' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                    <span className="font-bold text-gray-800">
                      {isHindi ? 'अक्सर पूछे जाने वाले प्रश्न (FAQ)' : 'Product FAQs & Answers'}
                    </span>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={loadDefaultFaqs}
                        className="px-2.5 py-1 bg-amber-100 hover:bg-amber-200 text-amber-900 rounded-lg text-xs font-bold"
                      >
                        {isHindi ? '⚡ डिफ़ॉल्ट FAQ लोड करें' : '⚡ Load Default FAQs'}
                      </button>
                      <button
                        type="button"
                        onClick={addFaq}
                        className="px-2.5 py-1 bg-mandir-maroon text-white rounded-lg text-xs font-bold"
                      >
                        {isHindi ? '+ नया प्रश्न जोड़ें' : '+ Add Question'}
                      </button>
                    </div>
                  </div>

                  {formData.faqs.length === 0 ? (
                    <div className="text-center py-6 bg-gray-50 rounded-xl border border-dashed border-gray-300">
                      <p className="text-gray-500 mb-2">
                        {isHindi ? 'कोई FAQ नहीं जोड़ा गया।' : 'No FAQs added for this product yet.'}
                      </p>
                      <button
                        type="button"
                        onClick={loadDefaultFaqs}
                        className="px-3 py-1.5 bg-mandir-maroon text-white rounded-xl font-bold"
                      >
                        {isHindi ? 'डिफ़ॉल्ट 4 प्रश्न जोड़ें' : 'Load Standard 4 FAQs'}
                      </button>
                    </div>
                  ) : (
                    <div className="space-y-4 max-h-72 overflow-y-auto pr-1">
                      {formData.faqs.map((faq, idx) => (
                        <div key={idx} className="p-3 bg-gray-50 border border-gray-200 rounded-xl space-y-2 relative">
                          <button
                            type="button"
                            onClick={() => removeFaq(idx)}
                            className="absolute top-2 right-2 text-red-500 hover:text-red-700 font-bold text-xs"
                            title="Remove FAQ"
                          >
                            ✕
                          </button>
                          <span className="font-bold text-gray-700 block text-[11px]">
                            FAQ #{idx + 1}
                          </span>

                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                            <input
                              type="text"
                              placeholder="Question (English)..."
                              value={faq.question}
                              onChange={(e) => updateFaq(idx, 'question', e.target.value)}
                              className="p-2 bg-white border border-gray-200 rounded-lg text-xs"
                            />
                            <input
                              type="text"
                              placeholder="प्रश्न (हिन्दी)..."
                              value={faq.question_hi || ''}
                              onChange={(e) => updateFaq(idx, 'question_hi', e.target.value)}
                              className="p-2 bg-amber-50/50 border border-amber-200 rounded-lg text-xs"
                            />
                          </div>

                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                            <textarea
                              rows={2}
                              placeholder="Answer (English)..."
                              value={faq.answer}
                              onChange={(e) => updateFaq(idx, 'answer', e.target.value)}
                              className="p-2 bg-white border border-gray-200 rounded-lg text-xs"
                            />
                            <textarea
                              rows={2}
                              placeholder="उत्तर (हिन्दी)..."
                              value={faq.answer_hi || ''}
                              onChange={(e) => updateFaq(idx, 'answer_hi', e.target.value)}
                              className="p-2 bg-amber-50/50 border border-amber-200 rounded-lg text-xs"
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* Submit & Cancel Buttons */}
              <div className="flex items-center justify-between pt-4 border-t border-gray-200">
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="is_featured"
                    checked={formData.is_featured}
                    onChange={(e) => setFormData({ ...formData, is_featured: e.target.checked })}
                    className="w-4 h-4 text-mandir-maroon rounded"
                  />
                  <label htmlFor="is_featured" className="text-gray-700 font-bold">
                    {isHindi ? 'विशेष उत्पाद (होमपेज पर दिखाएं)' : 'Featured Product (Show on Home)'}
                  </label>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setIsModalOpen(false)}
                    className="px-4 py-2 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 font-semibold"
                  >
                    {isHindi ? 'रद्द करें' : 'Cancel'}
                  </button>
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="px-5 py-2 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-xl font-bold shadow-md disabled:opacity-50"
                  >
                    {isSubmitting
                      ? (isHindi ? 'सुरक्षित हो रहा है...' : 'Saving...')
                      : selectedProduct
                      ? (isHindi ? 'अपडेट सुरक्षित करें' : 'Update Product')
                      : (isHindi ? 'डेटाबेस में जोड़ें' : 'Save Product')}
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
