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

interface ChadhawaOffering {
  id: string;
  temple_id?: string;
  temple_name: string;
  temple_name_hi?: string;
  title: string;
  title_hi?: string;
  category: string;
  price: number;
  description: string;
  description_hi?: string;
  items_included?: string;
  items_included_hi?: string;
  significance?: string;
  significance_hi?: string;
  benefits?: string;
  benefits_hi?: string;
  image_url: string;
  faqs?: FAQItem[];
}

const CHADAWA_PRESETS = [
  { label: 'Kashi Bilva Patra', url: '/images/chadhawa/chadhawa_bilva_patra.jpg' },
  { label: 'Tirupati Laddu Seva', url: '/images/chadhawa/chadhawa_tirupati_laddu.jpg' },
  { label: 'Siddhivinayak Modak Garland', url: '/images/chadhawa/chadhawa_modak_garland.jpg' },
  { label: 'Mahakal Akhand Jyoti', url: '/images/chadhawa/chadhawa_akhand_jyoti.jpg' },
  { label: 'Vaishno Devi Red Chunri', url: '/images/chadhawa/chadhawa_red_chunri.jpg' },
  { label: 'Somnath Dhwaja Seva', url: '/images/chadhawa/chadhawa_somnath_dhwaja.jpg' },
];

const CATEGORIES_DATA = [
  { en: 'Sacred Metals', hi: 'पावन धातु एवं छत्र' },
  { en: 'Special Bhog', hi: 'विशेष भोग सेवा' },
  { en: 'Vastra Seva', hi: 'जरी वस्त्र एवं चुनरी' },
  { en: 'Deepam & Jyoti', hi: 'अखंड दीप सेवा' },
  { en: 'Floral & Pushpa', hi: 'पुष्प एवं माला सेवा' },
  { en: 'Panchamrit & Abhishek', hi: 'पंचामृत अभिषेक सामग्री' },
];

const DEFAULT_CHADHAWA_FAQS: FAQItem[] = [
  {
    question: "How is the Chadhawa offered in the temple?",
    question_hi: "मंदिर के गर्भगृह में चढ़ावा कैसे अर्पित किया जाता है?",
    answer: "Our verified temple representative and authorized priests offer the consecrated items directly at the holy sanctum in your name and Gotra.",
    answer_hi: "हमारे अधिकृत तीर्थ पुरोहित गर्भगृह में मुख्य विग्रह के समक्ष आपके नाम व गोत्र का उच्चारण करते हुए पावन भेंट श्रद्धापूर्वक अर्पित करते हैं।"
  },
  {
    question: "How do I get proof of my sacred offering?",
    question_hi: "मुझे मेरी भेंट अर्पण का क्या प्रमाण मिलेगा?",
    answer: "A personalized video recording showing your name, Gotra recitation, and the actual offering at the temple altar will be sent directly to your registered WhatsApp number.",
    answer_hi: "आपके नाम-गोत्र के संकल्प और गर्भगृह में अर्पण का व्यक्तिगत वीडियो सीधे आपके पंजीकृत व्हाट्सएप नंबर पर भेजा जाएगा।"
  },
  {
    question: "Can I offer Chadhawa on behalf of parents or family members?",
    question_hi: "क्या मैं अपने माता-पिता या परिजनों के नाम से चढ़ावा अर्पित कर सकता हूँ?",
    answer: "Yes, you can enter the names and Gotras of your parents, spouse, or children during booking. The priest will include all of them in the sankalp.",
    answer_hi: "हाँ, आप अपने माता-पिता, जीवनसाथी या बच्चों के नाम और गोत्र जोड़ सकते हैं। पुरोहित जी सभी के नाम से संकल्प लेंगे।"
  },
  {
    question: "What prasad items will be delivered to my home?",
    question_hi: "मेरे घर पर क्या-क्या पावन प्रसाद भेजा जाएगा?",
    answer: "You will receive sanctified Dry Fruits prasad, Temple Vibhuti/Chandan, a consecrated coin, and sacred temple Raksha Sutra in protective sealed packaging.",
    answer_hi: "आपको पंचमेवा महाप्रसाद, पावन भस्म/चंदन, सिद्ध सिक्का और मंदिर का पावन रक्षा-सूत्र सुरक्षित रूप से प्राप्त होगा।"
  }
];

export default function ChadhawaPage() {
  const { isHindi } = useAdminLanguage();
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
  const [modalTab, setModalTab] = useState<'basic' | 'details' | 'faqs'>('basic');

  // Form State with bilingual & Sri Mandir full details
  const [formData, setFormData] = useState({
    title: '',
    title_hi: '',
    temple_name: '',
    temple_name_hi: '',
    category: 'Sacred Metals',
    price: '',
    description: '',
    description_hi: '',
    items_included: '',
    items_included_hi: '',
    significance: '',
    significance_hi: '',
    benefits: '',
    benefits_hi: '',
    image_url: '',
    faqs: [] as FAQItem[],
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
        setOfferings((data as ChadhawaOffering[]) || []);
      }
    } catch (_) {
      const { data } = await supabase.from('chadhawa_offerings').select('*').order('title');
      setOfferings((data as ChadhawaOffering[]) || []);
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
      title_hi: prev.title_hi.trim() ? prev.title_hi : autoTranslateText(prev.title),
      temple_name_hi: prev.temple_name_hi.trim() ? prev.temple_name_hi : autoTranslateText(prev.temple_name),
      description_hi: prev.description_hi.trim() ? prev.description_hi : autoTranslateText(prev.description),
      items_included_hi: prev.items_included_hi.trim() ? prev.items_included_hi : autoTranslateText(prev.items_included),
      significance_hi: prev.significance_hi.trim() ? prev.significance_hi : autoTranslateText(prev.significance),
      benefits_hi: prev.benefits_hi.trim() ? prev.benefits_hi : autoTranslateText(prev.benefits),
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
      faqs: DEFAULT_CHADHAWA_FAQS,
    }));
    showToast(isHindi ? 'डिफ़ॉल्ट चढ़ावा FAQ लोड हो गए!' : 'Default Chadhawa FAQs loaded!');
  };

  const validateForm = () => {
    const errs: Record<string, string> = {};
    if (!formData.title.trim()) errs.title = isHindi ? 'अर्पण का नाम अनिवार्य है' : 'Offering title is required';
    if (!formData.temple_name.trim()) errs.temple_name = isHindi ? 'तीर्थ मंदिर अनिवार्य है' : 'Temple destination is required';
    if (!formData.category.trim()) errs.category = isHindi ? 'श्रेणी अनिवार्य है' : 'Category is required';
    if (!formData.price || isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      errs.price = isHindi ? 'मान्य दक्षिणा राशि (₹) आवश्यक है' : 'Valid dakshina / price (₹) is required';
    }
    if (!formData.description.trim()) errs.description = isHindi ? 'विवरण आवश्यक है' : 'Offering description is required';
    if (!formData.image_url.trim()) errs.image_url = isHindi ? 'फोटो URL आवश्यक है' : 'Offering image URL is required';
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
      title_hi: formData.title_hi.trim() || undefined,
      temple_name: formData.temple_name.trim(),
      temple_name_hi: formData.temple_name_hi.trim() || undefined,
      category: formData.category.trim(),
      price: Number(formData.price),
      description: formData.description.trim(),
      description_hi: formData.description_hi.trim() || undefined,
      items_included: formData.items_included.trim() || undefined,
      items_included_hi: formData.items_included_hi.trim() || undefined,
      significance: formData.significance.trim() || undefined,
      significance_hi: formData.significance_hi.trim() || undefined,
      benefits: formData.benefits.trim() || undefined,
      benefits_hi: formData.benefits_hi.trim() || undefined,
      image_url: formData.image_url.trim(),
      faqs: formData.faqs,
    };

    try {
      const res = await fetch('/api/chadhawa', {
        method: selectedOffering ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save offering');

      showToast(
        selectedOffering
          ? (isHindi ? 'चढ़ावा सेवा सफलतापूर्वक अपडेट हुई!' : 'Chadhawa seva updated successfully!')
          : (isHindi ? 'नई पावन चढ़ावा सेवा सफलतापूर्वक जोड़ी गई!' : 'New sacred Chadhawa listed successfully!')
      );
      setIsModalOpen(false);
      setSelectedOffering(null);
      fetchOfferings();
    } catch (err: any) {
      const { error: sbErr } = await supabase.from('chadhawa_offerings').upsert(payload);
      if (!sbErr) {
        showToast(isHindi ? 'चढ़ावा सेवा डेटाबेस में सुरक्षित हो गई!' : 'Chadhawa saved to database!');
        setIsModalOpen(false);
        setSelectedOffering(null);
        fetchOfferings();
      } else {
        setErrorMsg(err.message || sbErr.message || (isHindi ? 'त्रुटि उत्पन्न हुई' : 'Error saving chadhawa'));
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
      showToast(isHindi ? 'चढ़ावा सेवा हटाई गई।' : 'Offering seva removed.');
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
      title_hi: '',
      temple_name: templeList[0] || 'Shree Kashi Vishwanath Temple',
      temple_name_hi: '',
      category: 'Sacred Metals',
      price: '',
      description: '',
      description_hi: '',
      items_included: 'Panchamrit, Bilva Patra, Sacred Silk Chunri, Pure Silver Coin, Bhasma & Dry Fruits Prasad',
      items_included_hi: 'पंचामृत, पावन बेलपत्र, जरी चुनरी, शुद्ध चांदी का सिक्का, अभिमंत्रित भस्म एवं पंचमेवे का भोग प्रसाद',
      significance: 'Offering this sacred Chadhawa directly inside the Sanctum Sanctorum brings divine peace and eliminates obstacles.',
      significance_hi: 'गर्भगृह के मुख्य विग्रह पर यह पावन चढ़ावा अर्पित करने से समस्त विघ्न-बाधाओं का शमन होता है।',
      benefits: 'Scriptural blessings (Phalashruti): Family prosperity, removal of planetary afflictions, spiritual protection.',
      benefits_hi: 'पारिवारिक सुख-समृद्धि, ग्रह दोष शांति, रोग-शोक निवारण एवं अनंत पुण्य की प्राप्ति।',
      image_url: '',
      faqs: DEFAULT_CHADHAWA_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const openEdit = (offering: ChadhawaOffering) => {
    setSelectedOffering(offering);
    setFormData({
      title: offering.title,
      title_hi: offering.title_hi || '',
      temple_name: offering.temple_name,
      temple_name_hi: offering.temple_name_hi || '',
      category: offering.category || 'Sacred Metals',
      price: offering.price.toString(),
      description: offering.description || '',
      description_hi: offering.description_hi || '',
      items_included: offering.items_included || '',
      items_included_hi: offering.items_included_hi || '',
      significance: offering.significance || '',
      significance_hi: offering.significance_hi || '',
      benefits: offering.benefits || '',
      benefits_hi: offering.benefits_hi || '',
      image_url: offering.image_url || '',
      faqs: offering.faqs && offering.faqs.length > 0 ? offering.faqs : DEFAULT_CHADHAWA_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const filteredOfferings = offerings.filter((o) => {
    const q = search.toLowerCase();
    const matchSearch =
      o.title.toLowerCase().includes(q) ||
      (o.title_hi && o.title_hi.toLowerCase().includes(q)) ||
      o.temple_name.toLowerCase().includes(q) ||
      o.description.toLowerCase().includes(q);
    const matchCat = selectedCategory === 'all' || o.category.toLowerCase().includes(selectedCategory.toLowerCase());
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
            <span>🪔 {isHindi ? 'गर्भगृह चढ़ावा प्रबंधन' : 'Sanctum Chadhawa Operations'}</span>
          </div>
          <h1 className="text-xl sm:text-2xl font-bold font-cinzel text-gray-900">
            {isHindi ? 'पवित्र चढ़ावा एवं भेंट सेवा' : 'Sacred Chadhawa Offerings'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'प्रमुख ज्योतिर्लिंगों एवं शक्तिपीठों हेतु चढ़ावा अर्पण, समाविष्ट सामग्री व FAQ प्रबंधन'
              : 'Configure offerings, sanctum video guarantees, items included & FAQs for Jyotirlingas & Shaktipeeths'}
          </p>
        </div>

        <button
          onClick={openAdd}
          className="px-4 py-2.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-95 shrink-0"
        >
          <span>✨</span>
          <span>{isHindi ? '+ नया चढ़ावा जोड़ें' : '+ Add New Offering'}</span>
        </button>
      </div>

      {/* Filter & Search Bar */}
      <div className="flex flex-col sm:flex-row gap-3 bg-white p-3 rounded-2xl border border-gray-200 shadow-xs">
        <div className="relative flex-1">
          <input
            type="text"
            placeholder={isHindi ? 'चढ़ावा खोजें (शीर्षक, मंदिर, विवरण)...' : 'Search offerings by title, temple, description...'}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
          <span className="absolute left-3 top-2.5 text-gray-400 text-xs">🔍</span>
        </div>

        <select
          value={selectedCategory}
          onChange={(e) => setSelectedCategory(e.target.value)}
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

      {/* Offerings Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="bg-white rounded-2xl p-4 border border-gray-200 h-64 animate-pulse" />
          ))}
        </div>
      ) : filteredOfferings.length === 0 ? (
        <div className="bg-white rounded-2xl p-12 text-center border border-gray-200 shadow-xs">
          <span className="text-4xl block mb-2">🪔</span>
          <h3 className="font-bold text-gray-800 text-sm">
            {isHindi ? 'कोई चढ़ावा सेवा नहीं मिली' : 'No Chadhawa Offerings Found'}
          </h3>
          <p className="text-xs text-gray-500 mt-1">
            {isHindi ? 'कृपया अपनी खोज बदलें अथवा नई चढ़ावा सेवा जोड़ें।' : 'Try refining your search filter or add a new sacred offering.'}
          </p>
          <button
            onClick={openAdd}
            className="mt-4 px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl shadow-xs"
          >
            {isHindi ? '+ नया चढ़ावा जोड़ें' : '+ Add Offering'}
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {filteredOfferings.map((offering) => (
            <div
              key={offering.id}
              className="bg-white rounded-2xl border border-gray-200 p-4 shadow-xs hover:shadow-md transition-all flex flex-col justify-between"
            >
              <div>
                <div className="relative h-44 w-full rounded-xl overflow-hidden bg-gray-50 mb-3 border border-gray-100">
                  <img
                    src={offering.image_url}
                    alt={offering.title}
                    className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
                  />
                  <span className="absolute top-2 left-2 bg-black/70 backdrop-blur-md text-amber-200 text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    {offering.category}
                  </span>
                  <span className="absolute bottom-2 left-2 bg-white/90 text-mandir-maroon text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    📍 {offering.temple_name}
                  </span>
                </div>

                <div className="flex items-start justify-between gap-2">
                  <div>
                    <h3 className="font-bold text-sm text-gray-900 line-clamp-1">
                      {isHindi && offering.title_hi ? offering.title_hi : offering.title}
                    </h3>
                    {offering.title_hi && !isHindi && (
                      <p className="text-[10px] text-amber-800 font-medium line-clamp-1">{offering.title_hi}</p>
                    )}
                  </div>
                  <span className="text-sm font-bold text-mandir-maroon shrink-0">₹{offering.price}</span>
                </div>

                <p className="text-xs text-gray-500 mt-2 line-clamp-2 leading-relaxed">
                  {isHindi && offering.description_hi ? offering.description_hi : offering.description}
                </p>

                {/* Info Badges */}
                <div className="mt-3 pt-2 border-t border-gray-100 flex flex-wrap gap-1.5 text-[10px]">
                  {offering.items_included && (
                    <span className="bg-amber-50 text-amber-900 px-2 py-0.5 rounded-md line-clamp-1">
                      📦 {isHindi ? 'सामग्री समाविष्ट' : 'Items Included'}
                    </span>
                  )}
                  {offering.faqs && offering.faqs.length > 0 && (
                    <span className="bg-emerald-50 text-emerald-800 font-bold px-2 py-0.5 rounded-md">
                      ✓ {offering.faqs.length} FAQs
                    </span>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between gap-2">
                <button
                  onClick={() => openEdit(offering)}
                  className="flex-1 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-800 font-bold text-xs rounded-xl transition-colors flex items-center justify-center gap-1"
                >
                  <span>✏️</span>
                  <span>{isHindi ? 'संपादित करें' : 'Edit'}</span>
                </button>
                <button
                  onClick={() => setDeleteId(offering.id)}
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
              {isHindi ? 'चढ़ावा हटाने की पुष्टि' : 'Confirm Chadhawa Deletion'}
            </h4>
            <p className="text-xs text-gray-500">
              {isHindi
                ? 'क्या आप सचमुच इस चढ़ावा सेवा को लाइव डेटाबेस से हटाना चाहते हैं?'
                : 'Are you sure you want to remove this offering from the live database?'}
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

      {/* Comprehensive Add / Edit Chadhawa Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-center justify-center p-3 sm:p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-3xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-4 sm:my-8 max-h-[92vh] overflow-y-auto">
            {/* Modal Header with Auto-Translate Button */}
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🪔</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedOffering
                      ? (isHindi ? 'चढ़ावा विवरण एवं FAQ संपादित करें' : 'Edit Sacred Chadhawa & FAQs')
                      : (isHindi ? 'नई चढ़ावा सेवा व विस्तृत विवरण जोड़ें' : 'Add New Chadhawa & Sri Mandir Details')}
                  </h2>
                  <p className="text-[11px] text-gray-500">
                    {isHindi ? 'गर्भगृह भेंट, समाविष्ट सामग्री व द्विभाषी (EN/HI) प्रबंधन' : 'Sanctum offerings, included samagri & bilingual transformation'}
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
                1. {isHindi ? 'बुनियादी व दक्षिणा' : 'Basic & Dakshina'}
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
                2. {isHindi ? 'विस्तृत विवरण व सामग्री' : 'Full Explanation & Samagri'}
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
              {/* TAB 1: BASIC & DAKSHINA */}
              {modalTab === 'basic' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'चढ़ावे का शीर्षक (अंग्रेज़ी) *' : 'Offering Title (English) *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. 108 Sacred Bilva Patra Arpan"
                        value={formData.title}
                        onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.title ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.title && <p className="text-[10px] text-red-600 mt-1">{formErrors.title}</p>}
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'चढ़ावे का शीर्षक (हिन्दी)' : 'Offering Title (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="उदा. 108 पावन बेलपत्र एवं भस्म अर्पण"
                        value={formData.title_hi}
                        onChange={(e) => setFormData({ ...formData, title_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'तीर्थ मंदिर *' : 'Temple Destination *'}
                      </label>
                      <input
                        type="text"
                        list="temples-list"
                        placeholder="Select or enter temple"
                        value={formData.temple_name}
                        onChange={(e) => setFormData({ ...formData, temple_name: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.temple_name ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      <datalist id="temples-list">
                        {templeList.map((t) => (
                          <option key={t} value={t} />
                        ))}
                      </datalist>
                      {formErrors.temple_name && <p className="text-[10px] text-red-600 mt-1">{formErrors.temple_name}</p>}
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'श्रेणी *' : 'Category *'}
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
                        {isHindi ? 'दक्षिणा राशि (₹) *' : 'Dakshina Amount (₹) *'}
                      </label>
                      <input
                        type="number"
                        min="1"
                        placeholder="501"
                        value={formData.price}
                        onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.price ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.price && <p className="text-[10px] text-red-600 mt-1">{formErrors.price}</p>}
                    </div>
                  </div>

                  <div>
                    <label className="block text-gray-700 font-bold mb-1">
                      {isHindi ? 'फोटो URL *' : 'Offering Image URL *'}
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
                      {CHADAWA_PRESETS.map((p) => (
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

              {/* TAB 2: FULL EXPLANATION & SAMAGRI (SRI MANDIR STYLE) */}
              {modalTab === 'details' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  {/* Descriptions */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'चढ़ावे का विवरण (अंग्रेज़ी) *' : 'Offering Description (English) *'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Sacred explanation of offering this Chadhawa at the temple..."
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
                        {isHindi ? 'चढ़ावे का विवरण (हिन्दी)' : 'Offering Description (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="गर्भगृह में इस भेंट को अर्पित करने का पावन हिन्दी विवरण..."
                        value={formData.description_hi}
                        onChange={(e) => setFormData({ ...formData, description_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Included Items */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'समाविष्ट पावन सामग्री (EN)' : 'Items Included in Offering (EN)'}
                      </label>
                      <input
                        type="text"
                        placeholder="Panchamrit, Bilva Patra, Silk Chunri, Pure Silver Coin, Bhasma & Dry Fruits"
                        value={formData.items_included}
                        onChange={(e) => setFormData({ ...formData, items_included: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'समाविष्ट पावन सामग्री (हिन्दी)' : 'Items Included in Offering (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="पंचामृत, पावन बेलपत्र, जरी चुनरी, शुद्ध चांदी का सिक्का, भस्म एवं पंचमेवा"
                        value={formData.items_included_hi}
                        onChange={(e) => setFormData({ ...formData, items_included_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Spiritual Significance & Benefits */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'आध्यात्मिक महत्व व महिमा (EN)' : 'Spiritual Significance & Fruits (EN)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Brings divine peace, eliminates planetary doshas and invokes the deity's blessings..."
                        value={formData.significance}
                        onChange={(e) => setFormData({ ...formData, significance: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'आध्यात्मिक महत्व व महिमा (हिन्दी)' : 'Spiritual Significance & Fruits (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="गर्भगृह में अर्पण से समस्त विघ्न-बाधाओं का शमन और मनोवांछित फल की प्राप्ति..."
                        value={formData.significance_hi}
                        onChange={(e) => setFormData({ ...formData, significance_hi: e.target.value })}
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
                      {isHindi ? 'चढ़ावा संबंधित अक्सर पूछे जाने वाले प्रश्न' : 'Chadhawa FAQs & Guidelines'}
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
                        {isHindi ? 'कोई FAQ नहीं जोड़ा गया।' : 'No FAQs added for this offering yet.'}
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
              <div className="flex items-center justify-end gap-2 pt-4 border-t border-gray-200">
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
                    : selectedOffering
                    ? (isHindi ? 'अपडेट सुरक्षित करें' : 'Update Offering')
                    : (isHindi ? 'डेटाबेस में जोड़ें' : 'Save Offering')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
