'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';
import { autoTranslateText } from '@/lib/autoTranslate';
import SystemImageUpload from '@/components/common/SystemImageUpload';

interface FAQItem {
  question: string;
  answer: string;
  question_hi?: string;
  answer_hi?: string;
}

interface PujaService {
  id: string;
  temple_id?: string;
  temple_name: string;
  temple_name_hi?: string;
  title: string;
  title_hi?: string;
  deity: string;
  category: string;
  price: number;
  vip_price?: number;
  duration_minutes: number;
  description: string;
  description_hi?: string;
  benefits?: string;
  benefits_hi?: string;
  samagri_included?: string;
  samagri_included_hi?: string;
  image_url: string;
  is_popular: boolean;
  faqs?: FAQItem[];
}

const PUJA_IMAGE_PRESETS = [
  { label: 'Rudrabhishek (Shiva)', url: '/images/pujas/puja_rudrabhishek.jpg' },
  { label: 'Ganesha Homam', url: '/images/pujas/puja_ganesha_homam.jpg' },
  { label: 'Venkateswara Kalyan', url: '/images/pujas/puja_venkateswara.jpg' },
  { label: 'Kaal Sarp Nivaran', url: '/images/pujas/puja_kaal_sarp.jpg' },
  { label: 'Maa Chandi Path', url: '/images/pujas/puja_chandi_path.jpg' },
  { label: 'Navgrah Shanti Havan', url: '/images/pujas/puja_navgrah_shanti.jpg' },
];

const CATEGORIES_DATA = [
  { en: 'Health & Protection', hi: 'आरोग्य एवं रक्षा' },
  { en: 'Vighnaharta', hi: 'विघ्नहर्ता गणेश' },
  { en: 'Wealth & Prosperity', hi: 'लक्ष्मी व सुख-समृद्धि' },
  { en: 'Dosha Nivaran', hi: 'दोष निवारण' },
  { en: 'Planetary Peace', hi: 'नवग्रह शांति' },
  { en: 'Family & Harmony', hi: 'पारिवारिक शांति' },
];

const DEFAULT_PUJA_FAQS: FAQItem[] = [
  {
    question: "Do I need to fast or be physically present for the puja?",
    question_hi: "क्या पूजा के लिए मुझे व्रत रखना या उपस्थित रहना आवश्यक है?",
    answer: "No physical presence is required. In Sanatan tradition, a Vedic priest can take Sankalp on your behalf (Pratinidhi Seva) using your Gotra and Nakshatra.",
    answer_hi: "उपस्थिति आवश्यक नहीं है। सनातन परंपरा में तीर्थ पुरोहित प्रतिनिधि रूप से आपके नाम-गोत्र से शास्त्रसम्मत संकल्प लेते हैं।"
  },
  {
    question: "When and how will I receive the puja video?",
    question_hi: "मुझे पूजा का वीडियो कब और कैसे मिलेगा?",
    answer: "The video showing your name, Gotra, and the sacred ritual is shared on WhatsApp within 24 to 48 hours of puja completion.",
    answer_hi: "पूजा संपन्न होने के 24 से 48 घंटों के भीतर आपके नाम-गोत्र और अनुष्ठान का वीडियो व्हाट्सएप पर उपलब्ध कराया जाता है।"
  },
  {
    question: "How is the prasad packaged?",
    question_hi: "प्रसाद की पैकेजिंग कैसे की जाती है?",
    answer: "The prasad is hermetically sealed with food-grade standards and dispatched with Gangajal, Raksha Sutra, and sanctified temple mementos.",
    answer_hi: "प्रसाद को खाद्य-ग्रेड सीलबंद डिब्बे में गंगाजल, रक्षा सूत्र और मंदिर स्मृति चिन्ह के साथ सुरक्षित रूप से पैक किया जाता है।"
  }
];

export default function PujaServicesPage() {
  const { isHindi } = useAdminLanguage();
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
  const [modalTab, setModalTab] = useState<'basic' | 'details' | 'faqs'>('basic');

  // Form State with bilingual & Sri Mandir full details
  const [formData, setFormData] = useState({
    title: '',
    title_hi: '',
    deity: '',
    category: 'Health & Protection',
    temple_name: '',
    temple_name_hi: '',
    price: '',
    vip_price: '',
    duration_minutes: '',
    description: '',
    description_hi: '',
    benefits: '',
    benefits_hi: '',
    samagri_included: '',
    samagri_included_hi: '',
    image_url: '',
    is_popular: true,
    faqs: [] as FAQItem[],
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
        setPujas((data as PujaService[]) || []);
      }
    } catch (_) {
      const { data } = await supabase.from('puja_services').select('*').order('title');
      setPujas((data as PujaService[]) || []);
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
      benefits_hi: prev.benefits_hi.trim() ? prev.benefits_hi : autoTranslateText(prev.benefits),
      samagri_included_hi: prev.samagri_included_hi.trim() ? prev.samagri_included_hi : autoTranslateText(prev.samagri_included),
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
      faqs: DEFAULT_PUJA_FAQS,
    }));
    showToast(isHindi ? 'डिफ़ॉल्ट पूजा FAQ लोड हो गए!' : 'Default Puja FAQs loaded!');
  };

  const validateForm = () => {
    const errs: Record<string, string> = {};
    if (!formData.title.trim()) errs.title = isHindi ? 'पूजा का नाम अनिवार्य है' : 'Puja title is required';
    if (!formData.temple_name.trim()) errs.temple_name = isHindi ? 'तीर्थ मंदिर अनिवार्य है' : 'Temple destination is required';
    if (!formData.deity.trim()) errs.deity = isHindi ? 'प्रधान देवता अनिवार्य हैं' : 'Deity is required';
    if (!formData.category.trim()) errs.category = isHindi ? 'श्रेणी अनिवार्य है' : 'Category is required';
    if (!formData.price || isNaN(Number(formData.price)) || Number(formData.price) <= 0) {
      errs.price = isHindi ? 'मान्य दक्षिणा राशि (₹) आवश्यक है' : 'Valid dakshina / price (₹) is required';
    }
    if (!formData.description.trim()) errs.description = isHindi ? 'विवरण आवश्यक है' : 'Puja description is required';
    if (!formData.image_url.trim()) errs.image_url = isHindi ? 'फोटो URL आवश्यक है' : 'Puja image URL is required';
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
      title_hi: formData.title_hi.trim() || undefined,
      temple_name: formData.temple_name.trim(),
      temple_name_hi: formData.temple_name_hi.trim() || undefined,
      deity: formData.deity.trim(),
      category: formData.category.trim(),
      price: Number(formData.price),
      vip_price: formData.vip_price ? Number(formData.vip_price) : Number(formData.price) * 1.5,
      duration_minutes: Number(formData.duration_minutes) || 60,
      description: formData.description.trim(),
      description_hi: formData.description_hi.trim() || undefined,
      benefits: formData.benefits.trim() || undefined,
      benefits_hi: formData.benefits_hi.trim() || undefined,
      samagri_included: formData.samagri_included.trim() || undefined,
      samagri_included_hi: formData.samagri_included_hi.trim() || undefined,
      image_url: formData.image_url.trim(),
      is_popular: formData.is_popular,
      faqs: formData.faqs,
    };

    try {
      const res = await fetch('/api/puja-services', {
        method: selectedPuja ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save puja');

      showToast(
        selectedPuja
          ? (isHindi ? 'पूजा सेवा सफलतापूर्वक अपडेट हुई!' : 'Puja service updated successfully!')
          : (isHindi ? 'नई वैदिक पूजा सेवा सफलतापूर्वक जोड़ी गई!' : 'New Vedic Puja listed successfully!')
      );
      setIsModalOpen(false);
      setSelectedPuja(null);
      fetchPujas();
    } catch (err: any) {
      const { error: sbErr } = await supabase.from('puja_services').upsert(payload);
      if (!sbErr) {
        showToast(isHindi ? 'पूजा सेवा डेटाबेस में सुरक्षित हो गई!' : 'Puja service saved to database!');
        setIsModalOpen(false);
        setSelectedPuja(null);
        fetchPujas();
      } else {
        setErrorMsg(err.message || sbErr.message || (isHindi ? 'त्रुटि उत्पन्न हुई' : 'Error saving puja'));
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
      showToast(isHindi ? 'पूजा सेवा हटाई गई।' : 'Puja service removed.');
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
      title_hi: '',
      deity: 'Lord Shiva',
      category: 'Health & Protection',
      temple_name: templeList[0] || 'Shree Kashi Vishwanath Temple',
      temple_name_hi: '',
      price: '',
      vip_price: '',
      duration_minutes: '60',
      description: '',
      description_hi: '',
      benefits: 'Scriptural fruit (Phalashruti): Eliminates doshas, invites Lakshmi grace, safeguards family health.',
      benefits_hi: 'पारिवारिक सुख-शांति, दरिद्रता निवारण, ग्रह दोष शांति तथा समस्त कार्यों में निर्विघ्न सिद्धि।',
      samagri_included: 'Pure Ghee, Sacred Gangajal, Belpatra, 51 Ayurvedic Herbs, Sandalwood',
      samagri_included_hi: 'शुद्ध गाय का घी, पावन गंगाजल, 51 वैदिक हवन औषधियां, अक्षत, कलावा, धूप',
      image_url: '',
      is_popular: true,
      faqs: DEFAULT_PUJA_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const openEdit = (puja: PujaService) => {
    setSelectedPuja(puja);
    setFormData({
      title: puja.title,
      title_hi: puja.title_hi || '',
      deity: puja.deity || '',
      category: puja.category || 'Health & Protection',
      temple_name: puja.temple_name,
      temple_name_hi: puja.temple_name_hi || '',
      price: puja.price.toString(),
      vip_price: puja.vip_price?.toString() || '',
      duration_minutes: (puja.duration_minutes || 60).toString(),
      description: puja.description || '',
      description_hi: puja.description_hi || '',
      benefits: puja.benefits || '',
      benefits_hi: puja.benefits_hi || '',
      samagri_included: puja.samagri_included || '',
      samagri_included_hi: puja.samagri_included_hi || '',
      image_url: puja.image_url || '',
      is_popular: puja.is_popular ?? true,
      faqs: puja.faqs && puja.faqs.length > 0 ? puja.faqs : DEFAULT_PUJA_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const filteredPujas = pujas.filter((p) => {
    const q = search.toLowerCase();
    const matchSearch =
      p.title.toLowerCase().includes(q) ||
      (p.title_hi && p.title_hi.toLowerCase().includes(q)) ||
      p.temple_name.toLowerCase().includes(q) ||
      p.deity.toLowerCase().includes(q) ||
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
            <span>🕉️ {isHindi ? 'वैदिक पूजा प्रबंधन' : 'Vedic Pujas Administration'}</span>
          </div>
          <h1 className="text-xl sm:text-2xl font-bold font-cinzel text-gray-900">
            {isHindi ? 'ऑनलाइन वैदिक पूजा एवं महाहवन' : 'Online Vedic Puja Services'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'संकल्प पूजा, सामग्री सूची, दक्षिणा पैकेज व FAQ का पूर्ण प्रबंधन'
              : 'Configure Gotra Sankalp rituals, durations, samagri inclusions & FAQs across holy shrines'}
          </p>
        </div>

        <button
          onClick={openAdd}
          className="px-4 py-2.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-95 shrink-0"
        >
          <span>✨</span>
          <span>{isHindi ? '+ नई पूजा जोड़ें' : '+ Add New Puja'}</span>
        </button>
      </div>

      {/* Filter & Search Bar */}
      <div className="flex flex-col sm:flex-row gap-3 bg-white p-3 rounded-2xl border border-gray-200 shadow-xs">
        <div className="relative flex-1">
          <input
            type="text"
            placeholder={isHindi ? 'पूजा खोजें (शीर्षक, मंदिर, देवता, विवरण)...' : 'Search pujas by title, temple, deity, description...'}
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

      {/* Pujas Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="bg-white rounded-2xl p-4 border border-gray-200 h-64 animate-pulse" />
          ))}
        </div>
      ) : filteredPujas.length === 0 ? (
        <div className="bg-white rounded-2xl p-12 text-center border border-gray-200 shadow-xs">
          <span className="text-4xl block mb-2">🪔</span>
          <h3 className="font-bold text-gray-800 text-sm">
            {isHindi ? 'कोई पूजा सेवा नहीं मिली' : 'No Puja Services Found'}
          </h3>
          <p className="text-xs text-gray-500 mt-1">
            {isHindi ? 'कृपया अपनी खोज बदलें अथवा नई पूजा सेवा जोड़ें।' : 'Try refining your search filter or add a new Vedic ritual.'}
          </p>
          <button
            onClick={openAdd}
            className="mt-4 px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl shadow-xs"
          >
            {isHindi ? '+ नई पूजा जोड़ें' : '+ Add Puja'}
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {filteredPujas.map((puja) => (
            <div
              key={puja.id}
              className="bg-white rounded-2xl border border-gray-200 p-4 shadow-xs hover:shadow-md transition-all flex flex-col justify-between"
            >
              <div>
                <div className="relative h-44 w-full rounded-xl overflow-hidden bg-gray-50 mb-3 border border-gray-100">
                  <img
                    src={puja.image_url}
                    alt={puja.title}
                    className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
                  />
                  <span className="absolute top-2 left-2 bg-black/70 backdrop-blur-md text-amber-200 text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    {puja.category}
                  </span>
                  <span className="absolute bottom-2 left-2 bg-white/90 text-mandir-maroon text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    📍 {puja.temple_name}
                  </span>
                </div>

                <div className="flex items-start justify-between gap-2">
                  <div>
                    <h3 className="font-bold text-sm text-gray-900 line-clamp-1">
                      {isHindi && puja.title_hi ? puja.title_hi : puja.title}
                    </h3>
                    {puja.title_hi && !isHindi && (
                      <p className="text-[10px] text-amber-800 font-medium line-clamp-1">{puja.title_hi}</p>
                    )}
                  </div>
                  <span className="text-sm font-bold text-mandir-maroon shrink-0">₹{puja.price}</span>
                </div>

                <p className="text-xs text-gray-500 mt-2 line-clamp-2 leading-relaxed">
                  {isHindi && puja.description_hi ? puja.description_hi : puja.description}
                </p>

                {/* Info Badges */}
                <div className="mt-3 pt-2 border-t border-gray-100 flex flex-wrap gap-1.5 text-[10px]">
                  <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded-md">
                    ⏱️ {puja.duration_minutes || 60} {isHindi ? 'मिनट' : 'Mins'}
                  </span>
                  {puja.benefits && (
                    <span className="bg-amber-50 text-amber-900 px-2 py-0.5 rounded-md line-clamp-1">
                      ✨ {isHindi ? 'फलश्रुति' : 'Benefits'}
                    </span>
                  )}
                  {puja.faqs && puja.faqs.length > 0 && (
                    <span className="bg-emerald-50 text-emerald-800 font-bold px-2 py-0.5 rounded-md">
                      ✓ {puja.faqs.length} FAQs
                    </span>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between gap-2">
                <button
                  onClick={() => openEdit(puja)}
                  className="flex-1 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-800 font-bold text-xs rounded-xl transition-colors flex items-center justify-center gap-1"
                >
                  <span>✏️</span>
                  <span>{isHindi ? 'संपादित करें' : 'Edit'}</span>
                </button>
                <button
                  onClick={() => setDeleteId(puja.id)}
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
              {isHindi ? 'पूजा सेवा हटाने की पुष्टि' : 'Confirm Puja Deletion'}
            </h4>
            <p className="text-xs text-gray-500">
              {isHindi
                ? 'क्या आप सचमुच इस पूजा सेवा को लाइव डेटाबेस से हटाना चाहते हैं?'
                : 'Are you sure you want to remove this puja from the live database?'}
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

      {/* Comprehensive Add / Edit Puja Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-center justify-center p-3 sm:p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-3xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-4 sm:my-8 max-h-[92vh] overflow-y-auto">
            {/* Modal Header with Auto-Translate Button */}
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🪔</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedPuja
                      ? (isHindi ? 'वैदिक पूजा विवरण एवं FAQ संपादित करें' : 'Edit Vedic Puja Details & FAQs')
                      : (isHindi ? 'नई वैदिक पूजा सेवा व विस्तृत विवरण जोड़ें' : 'Add New Vedic Puja & Sri Mandir Details')}
                  </h2>
                  <p className="text-[11px] text-gray-500">
                    {isHindi ? 'संकल्प विधान, समाविष्ट सामग्री व द्विभाषी (EN/HI) प्रबंधन' : 'Vedic ritual procedures, included samagri & bilingual transformation'}
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
                1. {isHindi ? 'बुनियादी पूजा विवरण' : 'Basic Puja Info'}
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
                2. {isHindi ? 'विधान, फलश्रुति व सामग्री' : 'Ritual Vidhi & Samagri'}
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
              {/* TAB 1: BASIC PUJA INFO */}
              {modalTab === 'basic' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'पूजा का शीर्षक (अंग्रेज़ी) *' : 'Puja Title (English) *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Maha Rudrabhishek & Mrityunjaya Havan"
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
                        {isHindi ? 'पूजा का शीर्षक (हिन्दी)' : 'Puja Title (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="उदा. महा रुद्राभिषेक एवं महामृत्युंजय हवन"
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
                        {isHindi ? 'प्रधान देवता *' : 'Deity *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Lord Shiva"
                        value={formData.deity}
                        onChange={(e) => setFormData({ ...formData, deity: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.deity ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.deity && <p className="text-[10px] text-red-600 mt-1">{formErrors.deity}</p>}
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
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'दक्षिणा राशि (₹) *' : 'Starting Dakshina (₹) *'}
                      </label>
                      <input
                        type="number"
                        min="1"
                        placeholder="1100"
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
                        {isHindi ? 'वीआईपी पैकेज (₹)' : 'VIP Dakshina (₹)'}
                      </label>
                      <input
                        type="number"
                        min="1"
                        placeholder="2500"
                        value={formData.vip_price}
                        onChange={(e) => setFormData({ ...formData, vip_price: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'अवधि (मिनट)' : 'Duration (Minutes)'}
                      </label>
                      <input
                        type="number"
                        min="15"
                        placeholder="60"
                        value={formData.duration_minutes}
                        onChange={(e) => setFormData({ ...formData, duration_minutes: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <SystemImageUpload
                    value={formData.image_url}
                    onChange={(url) => setFormData({ ...formData, image_url: url })}
                    label="Puja Ceremony Photo (Upload from System)"
                    labelHi="पूजा अनुष्ठान फोटो (सिस्टम से अपलोड करें)"
                    presets={PUJA_IMAGE_PRESETS}
                    required
                    error={formErrors.image_url}
                    folder="pujas"
                  />
                </div>
              )}

              {/* TAB 2: RITUAL VIDHI & SAMAGRI (SRI MANDIR STYLE) */}
              {modalTab === 'details' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  {/* Descriptions */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'पूजा का विवरण (अंग्रेज़ी) *' : 'Puja Description (English) *'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Complete spiritual description and ritual procedures..."
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
                        {isHindi ? 'पूजा का विवरण (हिन्दी)' : 'Puja Description (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="पावन वैदिक पूजा का विस्तृत एवं प्रमाणिक हिन्दी विवरण..."
                        value={formData.description_hi}
                        onChange={(e) => setFormData({ ...formData, description_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Divine Benefits */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'दैवीय फल व फलश्रुति (EN)' : 'Scriptural Benefits & Phalashruti (EN)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Eliminates doshas, invites prosperity and family well-being..."
                        value={formData.benefits}
                        onChange={(e) => setFormData({ ...formData, benefits: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'दैवीय फल व फलश्रुति (हिन्दी)' : 'Scriptural Benefits & Phalashruti (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="पारिवारिक सुख-शांति, दरिद्रता निवारण, ग्रह दोष शांति तथा समस्त मनोकामना सिद्धि..."
                        value={formData.benefits_hi}
                        onChange={(e) => setFormData({ ...formData, benefits_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Samagri Included */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'समाविष्ट पवित्र सामग्री (EN)' : 'Sacred Samagri Included (EN)'}
                      </label>
                      <input
                        type="text"
                        placeholder="Pure Ghee, Gangajal, Belpatra, 51 Ayurvedic Herbs, Sandalwood"
                        value={formData.samagri_included}
                        onChange={(e) => setFormData({ ...formData, samagri_included: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'समाविष्ट पवित्र सामग्री (हिन्दी)' : 'Sacred Samagri Included (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="शुद्ध गाय का घी, पावन गंगाजल, 51 वैदिक हवन औषधियां, अक्षत, कलावा, धूप"
                        value={formData.samagri_included_hi}
                        onChange={(e) => setFormData({ ...formData, samagri_included_hi: e.target.value })}
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
                      {isHindi ? 'पूजा संबंधित अक्सर पूछे जाने वाले प्रश्न' : 'Puja FAQs & Guidelines'}
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
                        {isHindi ? 'कोई FAQ नहीं जोड़ा गया।' : 'No FAQs added for this puja yet.'}
                      </p>
                      <button
                        type="button"
                        onClick={loadDefaultFaqs}
                        className="px-3 py-1.5 bg-mandir-maroon text-white rounded-xl font-bold"
                      >
                        {isHindi ? 'डिफ़ॉल्ट 3 प्रश्न जोड़ें' : 'Load Standard 3 FAQs'}
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
                    id="is_popular"
                    checked={formData.is_popular}
                    onChange={(e) => setFormData({ ...formData, is_popular: e.target.checked })}
                    className="w-4 h-4 text-mandir-maroon rounded"
                  />
                  <label htmlFor="is_popular" className="text-gray-700 font-bold">
                    {isHindi ? 'लोकप्रिय पूजा (शीर्ष पर दिखाएं)' : 'Popular Puja (Feature on Top)'}
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
                      : selectedPuja
                      ? (isHindi ? 'अपडेट सुरक्षित करें' : 'Update Puja')
                      : (isHindi ? 'डेटाबेस में जोड़ें' : 'Save Puja')}
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
