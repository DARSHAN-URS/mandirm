'use client';

import { useState, useEffect, Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';
import SystemImageUpload from '@/components/common/SystemImageUpload';

interface Astrologer {
  id: string;
  name: string;
  title: string;
  bio?: string;
  experience_years: number;
  per_minute_chat_rate: number;
  per_minute_call_rate: number;
  specialities?: string;
  languages?: string;
  rating: number;
  consultations_count: number;
  is_online: boolean;
  avatar_url?: string;
  phone?: string;
  created_at: string;
}

const ASTRO_IMAGE_PRESETS = [
  { label: 'Acharya 1', url: '/images/astrologers/astro_1.jpg' },
  { label: 'Acharya 2', url: '/images/astrologers/astro_2.jpg' },
  { label: 'Acharya 3', url: '/images/astrologers/astro_3.jpg' },
  { label: 'Acharya 4', url: '/images/astrologers/astro_4.jpg' },
  { label: 'Acharya 5', url: '/images/astrologers/astro_5.jpg' },
];

const HOLY_CITIES = [
  { key: 'Haridwar', labelEn: 'Haridwar, Uttarakhand', labelHi: 'हरिद्वार, उत्तराखण्ड', templeEn: 'Har Ki Pauri Sanctum Cell', templeHi: 'हर की पौड़ी तीर्थ प्रकोष्ठ', vedaEn: 'Rigveda Tradition', vedaHi: 'ऋग्वेद परंपरा' },
  { key: 'Varanasi', labelEn: 'Kashi (Varanasi), UP', labelHi: 'काशी (वाराणसी), उत्तर प्रदेश', templeEn: 'Kashi Vishwanath Vedic Cell', templeHi: 'काशी विश्वनाथ वैदिक प्रकोष्ठ', vedaEn: 'Shukla Yajurveda', vedaHi: 'शुक्ल यजुर्वेद' },
  { key: 'Ujjain', labelEn: 'Ujjain, Madhya Pradesh', labelHi: 'उज्जैन, मध्य प्रदेश', templeEn: 'Mahakaleshwar Jyotirlinga Cell', templeHi: 'महाकालेश्वर ज्योतिर्लिंग प्रकोष्ठ', vedaEn: 'Krishna Yajurveda', vedaHi: 'कृष्ण यजुर्वेद' },
  { key: 'Ayodhya', labelEn: 'Ayodhya, Uttar Pradesh', labelHi: 'अयोध्या, उत्तर प्रदेश', templeEn: 'Shri Ram Janmabhoomi Teerth', templeHi: 'श्री राम जन्मभूमि तीर्थ क्षेत्र', vedaEn: 'Samaveda Tradition', vedaHi: 'सामवेद परंपरा' },
  { key: 'Mathura', labelEn: 'Mathura-Vrindavan, UP', labelHi: 'मथुरा-वृन्दावन, उत्तर प्रदेश', templeEn: 'Bankey Bihari Temple Cell', templeHi: 'बांके बिहारी मंदिर प्रकोष्ठ', vedaEn: 'Vallabh Sampradaya', vedaHi: 'वल्लभ संप्रदाय परंपरा' },
  { key: 'Bengaluru', labelEn: 'Bengaluru, Karnataka', labelHi: 'बेंगलुरु, कर्नाटक', templeEn: 'South India Vedic Society', templeHi: 'दक्षिण भारत वैदिक समाज', vedaEn: 'Rigveda Tradition', vedaHi: 'ऋग्वेद परंपरा' },
];

const SUGGESTED_RITUALS_HI = [
  'गृह प्रवेश',
  'सत्यनारायण कथा',
  'रुद्राभिषेक',
  'महामृत्युंजय जाप',
  'कालसर्प दोष',
  'नवग्रह शांति',
  'वास्तु शांति',
  'विवाह संस्कार',
];

const SUGGESTED_RITUALS_EN = [
  'Griha Pravesh',
  'Satyanarayan Katha',
  'Rudrabhishek',
  'Mahamrityunjaya Jaap',
  'Kaal Sarp Dosha',
  'Navgraha Shanti',
  'Vastu Shanti',
  'Vivah Sanskar',
];

const getAstrologerImage = (astro: Astrologer) => {
  if (astro.avatar_url && astro.avatar_url.trim().length > 0) {
    return astro.avatar_url;
  }
  const idDigits = (astro.id || '').replace(/\D/g, '');
  const num = idDigits ? (parseInt(idDigits.slice(-2), 10) % 5) + 1 : 1;
  return `/images/astrologers/astro_${num}.jpg`;
};

const parseBio = (bio?: string) => {
  if (!bio) return { city: 'हरिद्वार, उत्तराखण्ड', temple: 'हर की पौड़ी तीर्थ प्रकोष्ठ', veda: 'ऋग्वेद परंपरा', about: '' };
  try {
    const parsed = JSON.parse(bio);
    let city = 'हरिद्वार, उत्तराखण्ड';
    let temple = 'हर की पौड़ी तीर्थ प्रकोष्ठ';
    let veda = 'ऋग्वेद परंपरा';
    let about = '';
    if (parsed.city) city = parsed.city;
    if (parsed.temple) temple = parsed.temple;
    if (parsed.veda) veda = parsed.veda;
    if (parsed.about) about = parsed.about;
    return { city, temple, veda, about };
  } catch {
    return { city: 'हरिद्वार, उत्तराखण्ड', temple: 'हर की पौड़ी तीर्थ प्रकोष्ठ', veda: 'ऋग्वेद परंपरा', about: bio };
  }
};

function AstrologersPageContent() {
  const { isHindi } = useAdminLanguage();
  const searchParams = useSearchParams();
  const [astrologers, setAstrologers] = useState<Astrologer[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState<string | null>(null);
  const [editingAstro, setEditingAstro] = useState<Astrologer | null>(null);
  const [showModal, setShowModal] = useState(false);

  const defaultForm = {
    name: '',
    title: isHindi ? 'वैदिक ज्योतिष एवं कर्मकाण्ड मर्मज्ञ' : 'Vedic Astrologer & Karmakand Scholar',
    avatar_url: '/images/astrologers/astro_1.jpg',
    city: isHindi ? 'हरिद्वार, उत्तराखण्ड' : 'Haridwar, Uttarakhand',
    temple_affiliation: isHindi ? 'हर की पौड़ी तीर्थ प्रकोष्ठ' : 'Har Ki Pauri Sanctum Cell',
    veda_branch: isHindi ? 'ऋग्वेद परंपरा' : 'Rigveda Tradition',
    bio: '',
    specialities: isHindi ? 'गृह प्रवेश, सत्यनारायण कथा, रुद्राभिषेक, वास्तु शांति' : 'Griha Pravesh, Satyanarayan Katha, Rudrabhishek, Vastu Shanti',
    languages: isHindi ? 'हिन्दी, संस्कृत, English' : 'Hindi, Sanskrit, English',
    experience_years: 12,
    per_minute_chat_rate: 25,
    per_minute_call_rate: 35,
    phone: '+91 98765 43210',
    rating: 4.95,
    consultations_count: 500,
    is_online: true,
  };

  const [formData, setFormData] = useState(defaultForm);

  useEffect(() => {
    fetchAstrologers();
    // If URL contains action=new or new=1, auto open Pandit registration modal
    if (searchParams.get('action') === 'new' || searchParams.get('new') === '1') {
      setEditingAstro(null);
      setFormData(defaultForm);
      setShowModal(true);
    }
  }, [searchParams]);

  const showToastMsg = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  };

  const fetchAstrologers = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('astrologers')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching astrologers:', error);
      } else {
        setAstrologers((data as Astrologer[]) || []);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleToggleOnline = async (id: string, current: boolean) => {
    try {
      const { error } = await supabase
        .from('astrologers')
        .update({ is_online: !current })
        .eq('id', id);

      if (error) throw error;
      setAstrologers((prev) =>
        prev.map((a) => (a.id === id ? { ...a, is_online: !current } : a))
      );
      showToastMsg(
        isHindi
          ? `पंडित अब ${!current ? 'ऑनलाइन' : 'ऑफलाइन'} हैं।`
          : `Pandit status set to ${!current ? 'Online' : 'Offline'}.`
      );
    } catch (err: any) {
      showToastMsg(`Error: ${err.message}`);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      showToastMsg(isHindi ? 'कृपया पंडित जी का नाम दर्ज करें' : 'Please enter Pandit name');
      return;
    }

    const structuredBio = JSON.stringify({
      city: formData.city,
      temple: formData.temple_affiliation,
      veda: formData.veda_branch,
      about: formData.bio || formData.title,
    });

    const payload = {
      name: formData.name.trim(),
      title: formData.title.trim(),
      avatar_url: formData.avatar_url.trim() || '/images/astrologers/astro_1.jpg',
      bio: structuredBio,
      specialities: formData.specialities.trim(),
      languages: formData.languages.trim(),
      experience_years: Number(formData.experience_years) || 10,
      per_minute_chat_rate: Number(formData.per_minute_chat_rate) || 20,
      per_minute_call_rate: Number(formData.per_minute_call_rate) || 30,
      phone: formData.phone.trim(),
      rating: Number(formData.rating) || 4.9,
      consultations_count: Number(formData.consultations_count) || 100,
      is_online: Boolean(formData.is_online),
    };

    try {
      if (editingAstro) {
        const { error } = await supabase
          .from('astrologers')
          .update(payload)
          .eq('id', editingAstro.id);
        if (error) throw error;
        showToastMsg(isHindi ? 'पंडित विवरण सफलतापूर्वक अपडेट किया गया!' : 'Pandit details successfully updated!');
      } else {
        const newId = `astro_${Date.now()}`;
        const { error } = await supabase
          .from('astrologers')
          .insert([{ id: newId, ...payload }]);
        if (error) throw error;
        showToastMsg(isHindi ? 'नये पूज्य पंडित जी सफलतापूर्वक पंजीकृत हुए!' : 'New Pandit registered successfully!');
      }

      setShowModal(false);
      setEditingAstro(null);
      fetchAstrologers();
    } catch (err: any) {
      showToastMsg(`Error: ${err.message}`);
    }
  };

  const handleEdit = (astro: Astrologer) => {
    const { city, temple, veda, about } = parseBio(astro.bio);
    setEditingAstro(astro);
    setFormData({
      name: astro.name || '',
      title: astro.title || '',
      avatar_url: astro.avatar_url || getAstrologerImage(astro),
      city,
      temple_affiliation: temple,
      veda_branch: veda,
      bio: about,
      specialities: astro.specialities || '',
      languages: astro.languages || '',
      experience_years: astro.experience_years || 10,
      per_minute_chat_rate: astro.per_minute_chat_rate || 20,
      per_minute_call_rate: astro.per_minute_call_rate || 30,
      phone: astro.phone || '',
      rating: astro.rating || 4.95,
      consultations_count: astro.consultations_count || 500,
      is_online: astro.is_online ?? true,
    });
    setShowModal(true);
  };

  const handleDelete = async (id: string, name: string) => {
    const confirmMsg = isHindi
      ? `क्या आप सचमुच पंडित "${name}" को हटाना चाहते हैं?`
      : `Are you sure you want to remove Pandit "${name}"?`;
    if (!confirm(confirmMsg)) return;

    try {
      const { error } = await supabase.from('astrologers').delete().eq('id', id);
      if (error) throw error;
      showToastMsg(isHindi ? 'पंडित रिकॉर्ड हटा दिया गया।' : 'Pandit record removed.');
      fetchAstrologers();
    } catch (err: any) {
      showToastMsg(`Error: ${err.message}`);
    }
  };

  const filtered = astrologers.filter((a) => {
    const q = search.toLowerCase();
    return (
      (a.name || '').toLowerCase().includes(q) ||
      (a.title || '').toLowerCase().includes(q) ||
      (a.specialities || '').toLowerCase().includes(q) ||
      (a.bio || '').toLowerCase().includes(q)
    );
  });

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Toast Alert */}
      {toast && (
        <div className="fixed top-20 right-6 z-50 bg-mandir-maroon text-amber-200 px-4 py-2.5 rounded-xl shadow-2xl border border-amber-400/40 text-xs font-semibold flex items-center gap-2 animate-bounce">
          <span>✓</span>
          <span>{toast}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-4">
        <div>
          <h1 className="text-lg sm:text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🧘‍♂️</span> {isHindi ? 'पंडित एवं ज्योतिषी प्रबंधन' : 'Pandits & Astrologers Management'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'यहाँ जोड़े गए पंडित सीधे "पंडित खोजें" (Find Pandit) पेज और कंसल्टेशन पर दिखाई देते हैं।'
              : 'Registered pandits here propagate directly to the "Find Pandit" and consultation pages.'}
          </p>
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <button
            onClick={() => {
              setEditingAstro(null);
              setFormData(defaultForm);
              setShowModal(true);
            }}
            className="flex-1 sm:flex-none px-4 py-2 bg-gradient-to-r from-amber-600 to-amber-700 hover:from-amber-500 hover:to-amber-600 text-white font-bold text-xs rounded-xl shadow-md transition-all flex items-center justify-center gap-1.5 active:scale-95 border border-amber-400/30"
          >
            <span>+</span>
            <span>{isHindi ? 'नया पंडित जोड़ें' : 'Add New Pandit'}</span>
          </button>
          <button
            onClick={fetchAstrologers}
            disabled={loading}
            className="px-3 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold rounded-xl flex items-center gap-1 transition-colors"
            title={isHindi ? 'रिफ्रेश करें' : 'Refresh'}
          >
            <span>{loading ? '⏳' : '🔄'}</span>
          </button>
        </div>
      </div>

      {/* Search Input */}
      <div className="flex items-center gap-3 bg-white p-3 rounded-2xl border border-gray-100 shadow-sm">
        <span className="text-gray-400 text-sm pl-2">🔍</span>
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder={isHindi ? 'नाम, पद, कर्मकाण्ड या तीर्थ नगर से खोजें...' : 'Search by name, title, ritual, or city...'}
          className="w-full text-xs bg-transparent focus:outline-none placeholder-gray-400"
        />
        {search && (
          <button
            onClick={() => setSearch('')}
            className="text-xs text-gray-400 hover:text-gray-600 px-2"
          >
            ✕
          </button>
        )}
      </div>

      {/* Grid of Astrologers / Pandits */}
      {loading ? (
        <div className="py-24 text-center text-xs text-gray-400">
          {isHindi ? 'डेटाबेस से पंडितों की सूची लोड हो रही है...' : 'Loading astrologers from database...'}
        </div>
      ) : filtered.length === 0 ? (
        <div className="py-24 text-center bg-white rounded-2xl border border-dashed border-gray-200 p-8">
          <div className="text-4xl mb-3">🧘‍♂️</div>
          <h3 className="text-sm font-bold text-gray-800">
            {isHindi ? 'डेटाबेस में कोई पंडित नहीं मिला' : 'No pandits found in database'}
          </h3>
          <p className="text-xs text-gray-500 mt-1 max-w-sm mx-auto">
            {isHindi
              ? 'ऊपर "नया पंडित जोड़ें" बटन दबाकर पहले वैदिक आचार्य को पंजीकृत करें।'
              : 'Click "Add New Pandit" above to register your first verified Vedic scholar.'}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((astro) => {
            const { city, temple, veda } = parseBio(astro.bio);
            const imgSrc = getAstrologerImage(astro);

            return (
              <div
                key={astro.id}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-all overflow-hidden flex flex-col justify-between"
              >
                <div className="p-4 sm:p-5">
                  <div className="flex items-start gap-3.5">
                    {/* Avatar Photo */}
                    <div className="relative shrink-0">
                      <img
                        src={imgSrc}
                        alt={astro.name}
                        className="w-16 h-16 rounded-2xl object-cover object-top border-2 border-amber-300 shadow-sm"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src = '/images/astrologers/astro_1.jpg';
                        }}
                      />
                      <span
                        className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full border-2 border-white ${
                          astro.is_online ? 'bg-emerald-500' : 'bg-gray-400'
                        }`}
                        title={astro.is_online ? (isHindi ? 'ऑनलाइन' : 'Online') : (isHindi ? 'ऑफलाइन' : 'Offline')}
                      />
                    </div>

                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between gap-1">
                        <h3 className="font-bold text-gray-900 text-sm truncate">{astro.name}</h3>
                        <span className="text-[10px] font-bold text-amber-700 bg-amber-50 px-2 py-0.5 rounded-full shrink-0">
                          ★ {astro.rating || 4.9}
                        </span>
                      </div>
                      <p className="text-[11px] text-amber-900/80 font-medium truncate mt-0.5">
                        {astro.title}
                      </p>
                      <div className="text-[10px] text-gray-500 mt-1 flex items-center gap-1 truncate">
                        <span>📍</span>
                        <span className="truncate">{city}</span>
                      </div>
                    </div>
                  </div>

                  {/* Badges / Temple & Veda */}
                  <div className="mt-3.5 pt-3 border-t border-gray-50 space-y-1.5 text-[11px]">
                    <div className="flex items-center justify-between text-gray-600">
                      <span className="text-gray-400">{isHindi ? 'तीर्थ प्रकोष्ठ:' : 'Sanctum:'}</span>
                      <span className="font-semibold text-gray-800 truncate max-w-[170px]">{temple}</span>
                    </div>
                    <div className="flex items-center justify-between text-gray-600">
                      <span className="text-gray-400">{isHindi ? 'वेद शाखा:' : 'Veda Branch:'}</span>
                      <span className="font-semibold text-amber-800">{veda}</span>
                    </div>
                    <div className="flex items-center justify-between text-gray-600">
                      <span className="text-gray-400">{isHindi ? 'अनुभव:' : 'Experience:'}</span>
                      <span className="font-semibold text-gray-800">
                        {astro.experience_years || 10} {isHindi ? 'वर्ष' : 'Yrs'}
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-gray-600">
                      <span className="text-gray-400">{isHindi ? 'परामर्श दक्षिणा:' : 'Dakshina Rate:'}</span>
                      <span className="font-bold text-mandir-maroon">
                        ₹{astro.per_minute_chat_rate || 20}/min (₹{(astro.per_minute_chat_rate || 20) * 60}/hr)
                      </span>
                    </div>
                  </div>

                  {/* Specialities pills */}
                  {astro.specialities && (
                    <div className="mt-3 flex flex-wrap gap-1">
                      {astro.specialities.split(',').slice(0, 3).map((s, i) => (
                        <span
                          key={i}
                          className="text-[9px] font-semibold bg-gray-50 border border-gray-200 text-gray-700 px-2 py-0.5 rounded-full"
                        >
                          {s.trim()}
                        </span>
                      ))}
                    </div>
                  )}
                </div>

                {/* Action Footer */}
                <div className="px-4 py-2.5 bg-gray-50/80 border-t border-gray-100 flex items-center justify-between gap-2 text-xs">
                  <button
                    onClick={() => handleToggleOnline(astro.id, Boolean(astro.is_online))}
                    className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-colors ${
                      astro.is_online
                        ? 'bg-emerald-100 text-emerald-800 hover:bg-emerald-200'
                        : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                    }`}
                  >
                    {astro.is_online ? (isHindi ? '🟢 ऑनलाइन' : '🟢 Online') : (isHindi ? '⚪ ऑफलाइन' : '⚪ Offline')}
                  </button>

                  <div className="flex items-center gap-1.5">
                    <button
                      onClick={() => handleEdit(astro)}
                      className="px-2.5 py-1 rounded-lg bg-amber-100 hover:bg-amber-200 text-amber-900 font-semibold text-[11px] transition-colors"
                    >
                      {isHindi ? 'संपादित करें' : 'Edit'}
                    </button>
                    <button
                      onClick={() => handleDelete(astro.id, astro.name)}
                      className="p-1 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-colors"
                      title={isHindi ? 'हटाएं' : 'Delete'}
                    >
                      🗑️
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Modal: Add or Edit Pandit */}
      {showModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-3 sm:p-4 overflow-y-auto">
          <div className="bg-white rounded-3xl max-w-2xl w-full p-4 sm:p-6 shadow-2xl border border-gray-200 my-8">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3 mb-4">
              <div>
                <h2 className="text-base sm:text-lg font-bold font-cinzel text-gray-900 flex items-center gap-2">
                  <span>🧘‍♂️</span>
                  <span>
                    {editingAstro
                      ? (isHindi ? 'पंडित विवरण संपादित करें' : 'Edit Pandit Details')
                      : (isHindi ? 'नये वैदिक पंडित / ज्योतिषी का पंजीकरण' : 'Register New Vedic Pandit / Astrologer')}
                  </span>
                </h2>
                <p className="text-[11px] text-gray-400 mt-0.5">
                  {isHindi
                    ? 'यहाँ दर्ज की गई जानकारी सीधे भक्त वेबसाइट के "पंडित खोजें" पेज पर दिखाई देगी।'
                    : 'Details entered here propagate directly to the consumer "Find Pandit" page.'}
                </p>
              </div>
              <button
                onClick={() => setShowModal(false)}
                className="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 flex items-center justify-center font-bold text-sm"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSave} className="space-y-4 text-xs">
              {/* Photo Upload from System */}
              <div className="bg-amber-50/60 p-3 sm:p-4 rounded-2xl border border-amber-200/80">
                <SystemImageUpload
                  value={formData.avatar_url}
                  onChange={(url) => setFormData({ ...formData, avatar_url: url })}
                  label="Pandit / Astrologer Photo (Upload from System)"
                  labelHi="पंडित जी की फोटो (सिस्टम से अपलोड करें)"
                  presets={ASTRO_IMAGE_PRESETS}
                  folder="astrologers"
                />
              </div>

              {/* Name & Title */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'पूरा नाम (उदा. पं. रामानंद शास्त्री)*' : 'Full Name (e.g. Pt. Ramanand Shastri)*'}
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    placeholder={isHindi ? 'पं. रामानंद शास्त्री' : 'Pt. Ramanand Shastri'}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'उपाधि / पद (Title)' : 'Spiritual Title / Designation'}
                  </label>
                  <input
                    type="text"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    placeholder={isHindi ? 'वैदिक ज्योतिष एवं कर्मकाण्ड मर्मज्ञ' : 'Vedic Astrologer & Karmakand Scholar'}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
              </div>

              {/* Holy City Preset, Temple Cell, Veda */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'पवित्र तीर्थ नगर (City)' : 'Holy City (Location)'}
                  </label>
                  <select
                    value={formData.city}
                    onChange={(e) => {
                      const selectedCity = e.target.value;
                      const match = HOLY_CITIES.find((c) => (isHindi ? c.labelHi : c.labelEn) === selectedCity || c.key === selectedCity);
                      if (match) {
                        setFormData({
                          ...formData,
                          city: isHindi ? match.labelHi : match.labelEn,
                          temple_affiliation: isHindi ? match.templeHi : match.templeEn,
                          veda_branch: isHindi ? match.vedaHi : match.vedaEn,
                        });
                      } else {
                        setFormData({ ...formData, city: selectedCity });
                      }
                    }}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs bg-white focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  >
                    {HOLY_CITIES.map((c) => (
                      <option key={c.key} value={isHindi ? c.labelHi : c.labelEn}>
                        {isHindi ? c.labelHi : c.labelEn}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'संबद्ध तीर्थ प्रकोष्ठ / मंदिर' : 'Affiliated Temple / Sanctum Cell'}
                  </label>
                  <input
                    type="text"
                    value={formData.temple_affiliation}
                    onChange={(e) => setFormData({ ...formData, temple_affiliation: e.target.value })}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'वेद शाखा (Veda Branch)' : 'Veda Branch (Tradition)'}
                  </label>
                  <input
                    type="text"
                    value={formData.veda_branch}
                    onChange={(e) => setFormData({ ...formData, veda_branch: e.target.value })}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
              </div>

              {/* Experience, Rates, Phone */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'अनुभव (वर्ष)' : 'Experience (Yrs)'}
                  </label>
                  <input
                    type="number"
                    min="1"
                    value={formData.experience_years}
                    onChange={(e) => setFormData({ ...formData, experience_years: Number(e.target.value) })}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'चैट दक्षिणा (₹/min)' : 'Chat Rate (₹/min)'}
                  </label>
                  <input
                    type="number"
                    min="5"
                    value={formData.per_minute_chat_rate}
                    onChange={(e) => setFormData({ ...formData, per_minute_chat_rate: Number(e.target.value) })}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none font-bold text-mandir-maroon"
                  />
                  <span className="text-[10px] text-gray-400 mt-0.5 block">
                    = ₹{(formData.per_minute_chat_rate || 0) * 60}/hr
                  </span>
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'कॉल दक्षिणा (₹/min)' : 'Call Rate (₹/min)'}
                  </label>
                  <input
                    type="number"
                    min="5"
                    value={formData.per_minute_call_rate}
                    onChange={(e) => setFormData({ ...formData, per_minute_call_rate: Number(e.target.value) })}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none font-bold text-mandir-maroon"
                  />
                  <span className="text-[10px] text-gray-400 mt-0.5 block">
                    = ₹{(formData.per_minute_call_rate || 0) * 60}/hr
                  </span>
                </div>

                <div>
                  <label className="block text-gray-700 font-semibold mb-1">
                    {isHindi ? 'संपर्क फ़ोन' : 'Phone Number'}
                  </label>
                  <input
                    type="text"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                  />
                </div>
              </div>

              {/* Specialities (Rituals) */}
              <div>
                <label className="block text-gray-700 font-semibold mb-1">
                  {isHindi ? 'विशेषज्ञता / सिद्ध कर्मकाण्ड (अल्पविराम से अलग करें):' : 'Specialities / Rituals (comma separated):'}
                </label>
                <input
                  type="text"
                  value={formData.specialities}
                  onChange={(e) => setFormData({ ...formData, specialities: e.target.value })}
                  placeholder={isHindi ? 'गृह प्रवेश, सत्यनारायण कथा, रुद्राभिषेक...' : 'Griha Pravesh, Satyanarayan Katha, Rudrabhishek...'}
                  className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                />
                <div className="flex flex-wrap gap-1.5 mt-1.5">
                  {(isHindi ? SUGGESTED_RITUALS_HI : SUGGESTED_RITUALS_EN).map((r, i) => (
                    <button
                      key={i}
                      type="button"
                      onClick={() => {
                        if (!formData.specialities.includes(r)) {
                          const next = formData.specialities ? `${formData.specialities}, ${r}` : r;
                          setFormData({ ...formData, specialities: next });
                        }
                      }}
                      className="text-[10px] bg-amber-50 text-amber-800 border border-amber-200 px-2 py-0.5 rounded-full hover:bg-amber-100 transition-colors"
                    >
                      + {r}
                    </button>
                  ))}
                </div>
              </div>

              {/* Languages */}
              <div>
                <label className="block text-gray-700 font-semibold mb-1">
                  {isHindi ? 'संवाद भाषाएँ:' : 'Languages Spoken:'}
                </label>
                <input
                  type="text"
                  value={formData.languages}
                  onChange={(e) => setFormData({ ...formData, languages: e.target.value })}
                  placeholder="हिन्दी, संस्कृत, English"
                  className="w-full p-2.5 border border-gray-200 rounded-xl text-xs focus:ring-2 focus:ring-amber-500 focus:outline-none"
                />
              </div>

              {/* Online Toggle & Submit Buttons */}
              <div className="pt-2 flex items-center justify-between border-t border-gray-100">
                <label className="flex items-center gap-2 cursor-pointer select-none">
                  <input
                    type="checkbox"
                    checked={formData.is_online}
                    onChange={(e) => setFormData({ ...formData, is_online: e.target.checked })}
                    className="w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500"
                  />
                  <span className="font-semibold text-gray-800">
                    {formData.is_online
                      ? (isHindi ? '🟢 अभी ऑनलाइन दिखाएं' : '🟢 Show as Online')
                      : (isHindi ? '⚪ ऑफलाइन रखें' : '⚪ Keep Offline')}
                  </span>
                </label>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 rounded-xl border border-gray-300 text-gray-700 font-semibold hover:bg-gray-50 transition-colors"
                  >
                    {isHindi ? 'रद्द करें' : 'Cancel'}
                  </button>
                  <button
                    type="submit"
                    className="px-5 py-2 rounded-xl bg-gradient-to-r from-amber-600 to-amber-700 hover:from-amber-500 hover:to-amber-600 text-white font-bold shadow-md transition-all active:scale-95"
                  >
                    {editingAstro
                      ? (isHindi ? 'परिवर्तन सुरक्षित करें' : 'Save Changes')
                      : (isHindi ? 'पंडित पंजीकृत करें' : 'Register Pandit')}
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

export default function AstrologersPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-xs text-gray-400">Loading...</div>}>
      <AstrologersPageContent />
    </Suspense>
  );
}
