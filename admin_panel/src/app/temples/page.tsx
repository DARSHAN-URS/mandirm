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

interface Temple {
  id: string;
  name: string;
  name_hi?: string;
  deity: string;
  deity_hi?: string;
  city: string;
  city_hi?: string;
  state: string;
  state_hi?: string;
  address: string;
  description: string;
  description_hi?: string;
  history?: string;
  history_hi?: string;
  significance?: string;
  significance_hi?: string;
  image_url: string;
  live_darshan_url?: string;
  darshan_timings: string;
  aarti_timings: string;
  rating?: number;
  reviews_count?: number;
  is_featured?: boolean;
  faqs?: FAQItem[];
}

const TEMPLE_IMAGE_PRESETS = [
  { label: 'Kashi Vishwanath', url: '/images/temples/kashi_vishwanath.jpg' },
  { label: 'Tirupati Balaji', url: '/images/temples/tirupati_balaji.jpg' },
  { label: 'Siddhivinayak', url: '/images/temples/siddhivinayak.jpg' },
  { label: 'Mahakaleshwar', url: '/images/temples/mahakaleshwar.jpg' },
  { label: 'Vaishno Devi', url: '/images/temples/vaishno_devi.jpg' },
  { label: 'Somnath Jyotirlinga', url: '/images/temples/somnath.jpg' },
];

const DEFAULT_TEMPLE_FAQS: FAQItem[] = [
  {
    question: "What are the timings for Darshan and Aarti at this temple?",
    question_hi: "इस पावन मंदिर में दर्शन एवं आरती का क्या समय है?",
    answer: "Darshan is typically open throughout the day from morning 04:00 AM to night 11:00 PM. Special Mangala and Sandhya Aartis are performed by the chief priests at sanctified hours.",
    answer_hi: "दर्शन प्रातः 04:00 बजे से रात्रि 11:00 बजे तक खुले रहते हैं। मुख्य पुजारियों द्वारा मंगला, भोग और संध्या आरती विशिष्ट मुहूर्तों पर संपन्न कराई जाती है।"
  },
  {
    question: "How can I book an online Puja or Gotra Sankalp at this Mandir?",
    question_hi: "मैं इस मंदिर में अपने नाम-गोत्र से ऑनलाइन पूजा कैसे बुक कर सकता हूँ?",
    answer: "Simply click 'Book Online Puja', choose your seva and package, and enter your family members' names and Gotra. Verified temple priests perform the ritual on your behalf.",
    answer_hi: "बस 'पूजा बुक करें' पर क्लिक करें, अपनी पूजा सेवा चुनें और अपने परिजनों के नाम व गोत्र दर्ज करें। तीर्थ पुरोहित आपके निमित्त सस्वर संकल्प लेंगे।"
  },
  {
    question: "Will I receive physical prasad at my doorstep?",
    question_hi: "क्या मुझे पूजा या चढ़ावा के बाद घर पर प्रसाद प्राप्त होगा?",
    answer: "Yes, sanctified dry prasad, temple vibhuti/chandan, and sacred raksha-sutra are packed securely and dispatched via express courier to your delivery address.",
    answer_hi: "हाँ, अभिमंत्रित सूखा मेवा प्रसाद, मंदिर की भस्म/चंदन और पावन रक्षा सूत्र सुरक्षित सीलबंद पैकेज में आपके घर कूरियर द्वारा भेजा जाता है।"
  },
  {
    question: "Can I watch the puja or darshan recording?",
    question_hi: "क्या मुझे पूजा का वीडियो प्रमाण प्राप्त होगा?",
    answer: "Yes, a personalized WhatsApp video recording featuring your Gotra recitation and the priest's sankalp is sent directly to your WhatsApp number within 24-48 hours.",
    answer_hi: "हाँ, आपके नाम-गोत्र के सस्वर उच्चारण और संकल्प का व्यक्तिगत वीडियो 24-48 घंटों के भीतर सीधे आपके व्हाट्सएप नंबर पर भेजा जाता है।"
  }
];

export default function TemplesPage() {
  const { isHindi } = useAdminLanguage();
  const [temples, setTemples] = useState<Temple[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [search, setSearch] = useState('');
  const [selectedTemple, setSelectedTemple] = useState<Temple | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successToast, setSuccessToast] = useState<string | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [modalTab, setModalTab] = useState<'basic' | 'heritage' | 'faqs'>('basic');

  // Form State with bilingual & Sri Mandir full details
  const [formData, setFormData] = useState({
    name: '',
    name_hi: '',
    deity: '',
    deity_hi: '',
    city: '',
    city_hi: '',
    state: '',
    state_hi: '',
    address: '',
    description: '',
    description_hi: '',
    history: '',
    history_hi: '',
    significance: '',
    significance_hi: '',
    image_url: '',
    live_darshan_url: '',
    darshan_timings: '04:00 AM - 11:00 PM',
    aarti_timings: 'Mangala: 04:00 AM | Sandhya: 07:00 PM',
    is_featured: true,
    faqs: [] as FAQItem[],
  });

  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    fetchTemples();
  }, []);

  const fetchTemples = async () => {
    setIsLoading(true);
    try {
      const res = await fetch('/api/temples');
      const json = await res.json();
      if (json.success && Array.isArray(json.data) && json.data.length > 0) {
        setTemples(json.data);
      } else {
        const { data } = await supabase.from('temples').select('*').order('name');
        setTemples((data as Temple[]) || []);
      }
    } catch (e) {
      const { data } = await supabase.from('temples').select('*').order('name');
      setTemples((data as Temple[]) || []);
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
      deity_hi: prev.deity_hi.trim() ? prev.deity_hi : autoTranslateText(prev.deity),
      city_hi: prev.city_hi.trim() ? prev.city_hi : autoTranslateText(prev.city),
      state_hi: prev.state_hi.trim() ? prev.state_hi : autoTranslateText(prev.state),
      description_hi: prev.description_hi.trim() ? prev.description_hi : autoTranslateText(prev.description),
      history_hi: prev.history_hi.trim() ? prev.history_hi : autoTranslateText(prev.history),
      significance_hi: prev.significance_hi.trim() ? prev.significance_hi : autoTranslateText(prev.significance || prev.description),
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
      faqs: DEFAULT_TEMPLE_FAQS,
    }));
    showToast(isHindi ? 'डिफ़ॉल्ट तीर्थ FAQ लोड हो गए!' : 'Default Temple FAQs loaded!');
  };

  const validateForm = () => {
    const errs: Record<string, string> = {};
    if (!formData.name.trim()) errs.name = isHindi ? 'मंदिर का नाम अनिवार्य है' : 'Temple name is required';
    if (!formData.deity.trim()) errs.deity = isHindi ? 'प्रधान देवता का नाम अनिवार्य है' : 'Deity name is required';
    if (!formData.city.trim()) errs.city = isHindi ? 'तीर्थ नगर अनिवार्य है' : 'City is required';
    if (!formData.state.trim()) errs.state = isHindi ? 'राज्य अनिवार्य है' : 'State is required';
    if (!formData.description.trim()) errs.description = isHindi ? 'मंदिर का विवरण अनिवार्य है' : 'Sanctum description is required';
    if (!formData.image_url.trim()) errs.image_url = isHindi ? 'फोटो URL अनिवार्य है' : 'Temple image URL is required';
    if (!formData.darshan_timings.trim()) errs.darshan_timings = isHindi ? 'दर्शन समय अनिवार्य है' : 'Darshan timings are required';
    if (!formData.aarti_timings.trim()) errs.aarti_timings = isHindi ? 'आरती समय अनिवार्य है' : 'Aarti timings are required';
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
      name: formData.name.trim(),
      name_hi: formData.name_hi.trim() || undefined,
      deity: formData.deity.trim(),
      deity_hi: formData.deity_hi.trim() || undefined,
      city: formData.city.trim(),
      city_hi: formData.city_hi.trim() || undefined,
      state: formData.state.trim(),
      state_hi: formData.state_hi.trim() || undefined,
      address: formData.address.trim() || `${formData.city.trim()}, ${formData.state.trim()}`,
      description: formData.description.trim(),
      description_hi: formData.description_hi.trim() || undefined,
      history: formData.history.trim() || undefined,
      history_hi: formData.history_hi.trim() || undefined,
      significance: formData.significance.trim() || undefined,
      significance_hi: formData.significance_hi.trim() || undefined,
      image_url: formData.image_url.trim(),
      live_darshan_url: formData.live_darshan_url.trim() || null,
      darshan_timings: formData.darshan_timings.trim(),
      aarti_timings: formData.aarti_timings.trim(),
      is_featured: formData.is_featured,
      faqs: formData.faqs,
    };

    try {
      const res = await fetch('/api/temples', {
        method: selectedTemple ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      const json = await res.json();
      if (!res.ok) throw new Error(json.error || 'Failed to save temple');

      showToast(
        selectedTemple
          ? (isHindi ? 'मंदिर विवरण सफलतापूर्वक अपडेट हुआ!' : 'Temple updated successfully in database!')
          : (isHindi ? 'नया पवित्र तीर्थ सफलतापूर्वक सूचीबद्ध हुआ!' : 'New sacred temple listed successfully!')
      );
      setIsModalOpen(false);
      setSelectedTemple(null);
      fetchTemples();
    } catch (err: any) {
      const { error: sbErr } = await supabase.from('temples').upsert(payload);
      if (!sbErr) {
        showToast(isHindi ? 'मंदिर डेटाबेस में सुरक्षित हो गया!' : 'Temple saved to database!');
        setIsModalOpen(false);
        setSelectedTemple(null);
        fetchTemples();
      } else {
        setErrorMsg(err.message || sbErr.message || (isHindi ? 'त्रुटि उत्पन्न हुई' : 'Error saving temple'));
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
      showToast(isHindi ? 'मंदिर सूची से हटाया गया।' : 'Temple listing removed.');
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
      name_hi: '',
      deity: '',
      deity_hi: '',
      city: '',
      city_hi: '',
      state: '',
      state_hi: '',
      address: '',
      description: '',
      description_hi: '',
      history: 'Ancient sanctum described in Puranas and Skanda Purana, celebrated across centuries of Sanatan devotion.',
      history_hi: 'स्कंद पुराण व प्राचीन सनातन ग्रंथों में वर्णित परम पावन धाम, जो सहस्रों वर्षों से भक्तों की आस्था का केंद्र है।',
      significance: 'Spiritual liberation, elimination of worldly sins, and fulfillment of heartfelt wishes.',
      significance_hi: 'समस्त पापों का नाश करने वाला एवं मोक्ष प्रदाता परम पावन तीर्थ धाम।',
      image_url: '',
      live_darshan_url: '',
      darshan_timings: '04:00 AM - 11:00 PM',
      aarti_timings: 'Mangala: 04:00 AM | Sandhya: 07:00 PM',
      is_featured: true,
      faqs: DEFAULT_TEMPLE_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const openEdit = (temple: Temple) => {
    setSelectedTemple(temple);
    setFormData({
      name: temple.name,
      name_hi: temple.name_hi || '',
      deity: temple.deity,
      deity_hi: temple.deity_hi || '',
      city: temple.city,
      city_hi: temple.city_hi || '',
      state: temple.state,
      state_hi: temple.state_hi || '',
      address: temple.address || '',
      description: temple.description,
      description_hi: temple.description_hi || '',
      history: temple.history || '',
      history_hi: temple.history_hi || '',
      significance: temple.significance || '',
      significance_hi: temple.significance_hi || '',
      image_url: temple.image_url,
      live_darshan_url: temple.live_darshan_url || '',
      darshan_timings: temple.darshan_timings || '04:00 AM - 11:00 PM',
      aarti_timings: temple.aarti_timings || 'Mangala: 04:00 AM | Sandhya: 07:00 PM',
      is_featured: temple.is_featured ?? true,
      faqs: temple.faqs && temple.faqs.length > 0 ? temple.faqs : DEFAULT_TEMPLE_FAQS,
    });
    setFormErrors({});
    setErrorMsg(null);
    setModalTab('basic');
    setIsModalOpen(true);
  };

  const filteredTemples = temples.filter((t) => {
    const q = search.toLowerCase();
    return (
      t.name.toLowerCase().includes(q) ||
      (t.name_hi && t.name_hi.toLowerCase().includes(q)) ||
      t.deity.toLowerCase().includes(q) ||
      t.city.toLowerCase().includes(q) ||
      t.state.toLowerCase().includes(q)
    );
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
            <span>🛕 {isHindi ? 'पवित्र तीर्थ प्रबंधन' : 'Holy Temples Directory'}</span>
          </div>
          <h1 className="text-xl sm:text-2xl font-bold font-cinzel text-gray-900">
            {isHindi ? 'पवित्र तीर्थ एवं ज्योतिर्लिंग' : 'Sacred Temples & Jyotirlingas'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'समस्त ज्योतिर्लिंगों, शक्तिपीठों, आरती समय, पौराणिक इतिहास व FAQ का पूर्ण प्रबंधन'
              : 'Direct production management of Jyotirlingas, Shaktipeeths, timings, heritage & FAQs'}
          </p>
        </div>

        <button
          onClick={openAdd}
          className="px-4 py-2.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-2 active:scale-95 shrink-0"
        >
          <span>✨</span>
          <span>{isHindi ? '+ नया तीर्थ जोड़ें' : '+ Add New Temple'}</span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-white p-3 rounded-2xl border border-gray-200 shadow-xs">
        <div className="relative">
          <input
            type="text"
            placeholder={isHindi ? 'तीर्थ खोजें (मंदिर, प्रधान देवता, नगर, राज्य)...' : 'Search temples by name, deity, city, state...'}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
          <span className="absolute left-3 top-2.5 text-gray-400 text-xs">🔍</span>
        </div>
      </div>

      {/* Temples Grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <div key={i} className="bg-white rounded-2xl p-4 border border-gray-200 h-64 animate-pulse" />
          ))}
        </div>
      ) : filteredTemples.length === 0 ? (
        <div className="bg-white rounded-2xl p-12 text-center border border-gray-200 shadow-xs">
          <span className="text-4xl block mb-2">🛕</span>
          <h3 className="font-bold text-gray-800 text-sm">
            {isHindi ? 'कोई तीर्थ नहीं मिला' : 'No Sacred Temples Found'}
          </h3>
          <p className="text-xs text-gray-500 mt-1">
            {isHindi ? 'कृपया अपनी खोज बदलें अथवा नया तीर्थ जोड़ें।' : 'Try refining your search filter or add a new temple.'}
          </p>
          <button
            onClick={openAdd}
            className="mt-4 px-4 py-2 bg-mandir-maroon text-white font-bold text-xs rounded-xl shadow-xs"
          >
            {isHindi ? '+ नया तीर्थ जोड़ें' : '+ Add Temple'}
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {filteredTemples.map((temple) => (
            <div
              key={temple.id}
              className="bg-white rounded-2xl border border-gray-200 p-4 shadow-xs hover:shadow-md transition-all flex flex-col justify-between"
            >
              <div>
                <div className="relative h-44 w-full rounded-xl overflow-hidden bg-gray-50 mb-3 border border-gray-100">
                  <img
                    src={temple.image_url}
                    alt={temple.name}
                    className="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
                  />
                  <span className="absolute top-2 left-2 bg-mandir-maroon text-white text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    🕉️ {isHindi && temple.deity_hi ? temple.deity_hi : temple.deity}
                  </span>
                  <span className="absolute bottom-2 left-2 bg-black/70 backdrop-blur-md text-amber-200 text-[10px] font-bold px-2 py-0.5 rounded shadow">
                    📍 {isHindi && temple.city_hi ? temple.city_hi : temple.city}, {isHindi && temple.state_hi ? temple.state_hi : temple.state}
                  </span>
                </div>

                <h3 className="font-bold text-sm text-gray-900 line-clamp-1">
                  {isHindi && temple.name_hi ? temple.name_hi : temple.name}
                </h3>
                {temple.name_hi && !isHindi && (
                  <p className="text-[10px] text-amber-800 font-medium line-clamp-1">{temple.name_hi}</p>
                )}

                <p className="text-xs text-gray-500 mt-2 line-clamp-2 leading-relaxed">
                  {isHindi && temple.description_hi ? temple.description_hi : temple.description}
                </p>

                {/* Info Badges */}
                <div className="mt-3 pt-2 border-t border-gray-100 flex flex-wrap gap-1.5 text-[10px]">
                  <span className="bg-amber-50 text-amber-900 px-2 py-0.5 rounded-md">
                    ⏰ {isHindi ? 'दर्शन:' : 'Darshan:'} {temple.darshan_timings}
                  </span>
                  {temple.faqs && temple.faqs.length > 0 && (
                    <span className="bg-emerald-50 text-emerald-800 font-bold px-2 py-0.5 rounded-md">
                      ✓ {temple.faqs.length} FAQs
                    </span>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between gap-2">
                <button
                  onClick={() => openEdit(temple)}
                  className="flex-1 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-800 font-bold text-xs rounded-xl transition-colors flex items-center justify-center gap-1"
                >
                  <span>✏️</span>
                  <span>{isHindi ? 'संपादित करें' : 'Edit'}</span>
                </button>
                <button
                  onClick={() => setDeleteId(temple.id)}
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
              {isHindi ? 'तीर्थ हटाने की पुष्टि' : 'Confirm Temple Deletion'}
            </h4>
            <p className="text-xs text-gray-500">
              {isHindi
                ? 'क्या आप सचमुच इस तीर्थ को लाइव डेटाबेस से हटाना चाहते हैं?'
                : 'Are you sure you want to remove this sacred temple from the live database?'}
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

      {/* Comprehensive Add / Edit Temple Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-center justify-center p-3 sm:p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-3xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-4 sm:my-8 max-h-[92vh] overflow-y-auto">
            {/* Modal Header with Auto-Translate Button */}
            <div className="flex items-center justify-between pb-4 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <span className="text-2xl">🛕</span>
                <div>
                  <h2 className="text-lg font-bold font-cinzel text-gray-900">
                    {selectedTemple
                      ? (isHindi ? 'तीर्थ विवरण एवं FAQ संपादित करें' : 'Edit Holy Temple Details & FAQs')
                      : (isHindi ? 'नया तीर्थ व विस्तृत विवरण जोड़ें' : 'Add New Sacred Temple & Full Details')}
                  </h2>
                  <p className="text-[11px] text-gray-500">
                    {isHindi ? 'श्री मंदिरम् एकीकृत तीर्थ विवरण, इतिहास व द्विभाषी (EN/HI) प्रबंधन' : 'Sri Mandir unified sanctum history, timings & bilingual transformation'}
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
                1. {isHindi ? 'बुनियादी तीर्थ विवरण' : 'Basic Sanctum Info'}
              </button>
              <button
                type="button"
                onClick={() => setModalTab('heritage')}
                className={`py-2 px-4 border-b-2 transition-all ${
                  modalTab === 'heritage'
                    ? 'border-mandir-maroon text-mandir-maroon'
                    : 'border-transparent text-gray-500 hover:text-gray-800'
                }`}
              >
                2. {isHindi ? 'महिमा, इतिहास व समय' : 'Heritage, Glory & Timings'}
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
              {/* TAB 1: BASIC SANCTUM INFO */}
              {modalTab === 'basic' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'मंदिर का नाम (अंग्रेज़ी) *' : 'Temple Name (English) *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Shree Kashi Vishwanath Temple"
                        value={formData.name}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.name ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.name && <p className="text-[10px] text-red-600 mt-1">{formErrors.name}</p>}
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'मंदिर का नाम (हिन्दी)' : 'Temple Name (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="उदा. श्री काशी विश्वनाथ ज्योतिर्लिंग मंदिर"
                        value={formData.name_hi}
                        onChange={(e) => setFormData({ ...formData, name_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'प्रधान देवता (अंग्रेज़ी) *' : 'Presiding Deity (English) *'}
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
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'प्रधान देवता (हिन्दी)' : 'Presiding Deity (Hindi)'}
                      </label>
                      <input
                        type="text"
                        placeholder="उदा. भगवान शिव"
                        value={formData.deity_hi}
                        onChange={(e) => setFormData({ ...formData, deity_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'तीर्थ नगर (City) *' : 'City *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Varanasi"
                        value={formData.city}
                        onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.city ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.city && <p className="text-[10px] text-red-600 mt-1">{formErrors.city}</p>}
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'राज्य (State) *' : 'State *'}
                      </label>
                      <input
                        type="text"
                        placeholder="e.g. Uttar Pradesh"
                        value={formData.state}
                        onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.state ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.state && <p className="text-[10px] text-red-600 mt-1">{formErrors.state}</p>}
                    </div>
                  </div>

                  <div>
                    <label className="block text-gray-700 font-bold mb-1">
                      {isHindi ? 'फोटो URL *' : 'Temple Photo URL *'}
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
                      {TEMPLE_IMAGE_PRESETS.map((p) => (
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

              {/* TAB 2: HERITAGE, GLORY & TIMINGS */}
              {modalTab === 'heritage' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  {/* Descriptions */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'मंदिर का विवरण (अंग्रेज़ी) *' : 'Sanctum Description (English) *'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Sacred explanation of this holy shrine and its divine presence..."
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
                        {isHindi ? 'मंदिर का विवरण (हिन्दी)' : 'Sanctum Description (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="पावन तीर्थ का विस्तृत एवं प्रामाणिक हिन्दी विवरण..."
                        value={formData.description_hi}
                        onChange={(e) => setFormData({ ...formData, description_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Puranic History & Heritage */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'पौराणिक इतिहास एवं सनातन धरोहर (EN)' : 'Puranic History & Heritage (EN)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="Celebrated in Skanda Purana, restored in historical eras..."
                        value={formData.history}
                        onChange={(e) => setFormData({ ...formData, history: e.target.value })}
                        className="w-full p-2.5 bg-gray-50 border border-gray-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>

                    <div>
                      <label className="block text-amber-900 font-bold mb-1">
                        {isHindi ? 'पौराणिक इतिहास एवं सनातन धरोहर (हिन्दी)' : 'Puranic History & Heritage (Hindi)'}
                      </label>
                      <textarea
                        rows={3}
                        placeholder="स्कंद पुराण व प्राचीन सनातन ग्रंथों में वर्णित परम पावन धाम..."
                        value={formData.history_hi}
                        onChange={(e) => setFormData({ ...formData, history_hi: e.target.value })}
                        className="w-full p-2.5 bg-amber-50/40 border border-amber-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                      />
                    </div>
                  </div>

                  {/* Timings */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'दर्शन समय *' : 'Darshan Timings *'}
                      </label>
                      <input
                        type="text"
                        placeholder="04:00 AM - 11:00 PM"
                        value={formData.darshan_timings}
                        onChange={(e) => setFormData({ ...formData, darshan_timings: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.darshan_timings ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.darshan_timings && <p className="text-[10px] text-red-600 mt-1">{formErrors.darshan_timings}</p>}
                    </div>

                    <div>
                      <label className="block text-gray-700 font-bold mb-1">
                        {isHindi ? 'आरती समय *' : 'Aarti Timings *'}
                      </label>
                      <input
                        type="text"
                        placeholder="Mangala: 04:00 AM | Bhog: 11:15 AM | Sandhya: 07:00 PM"
                        value={formData.aarti_timings}
                        onChange={(e) => setFormData({ ...formData, aarti_timings: e.target.value })}
                        className={`w-full p-2.5 bg-gray-50 border rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-mandir-maroon ${
                          formErrors.aarti_timings ? 'border-red-500 bg-red-50' : 'border-gray-200'
                        }`}
                      />
                      {formErrors.aarti_timings && <p className="text-[10px] text-red-600 mt-1">{formErrors.aarti_timings}</p>}
                    </div>
                  </div>
                </div>
              )}

              {/* TAB 3: FAQS EDITOR */}
              {modalTab === 'faqs' && (
                <div className="space-y-4 animate-in fade-in duration-150">
                  <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                    <span className="font-bold text-gray-800">
                      {isHindi ? 'तीर्थ संबंधित अक्सर पूछे जाने वाले प्रश्न' : 'Temple FAQs & Guidelines'}
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
                        {isHindi ? 'कोई FAQ नहीं जोड़ा गया।' : 'No FAQs added for this temple yet.'}
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
                    {isHindi ? 'विशेष तीर्थ (होमपेज पर दिखाएं)' : 'Featured Temple (Show on Home)'}
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
                      : selectedTemple
                      ? (isHindi ? 'अपडेट सुरक्षित करें' : 'Update Temple')
                      : (isHindi ? 'डेटाबेस में जोड़ें' : 'Save Temple')}
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
