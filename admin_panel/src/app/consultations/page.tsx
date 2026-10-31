'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

interface Consultation {
  id: string;
  astrologer_id: string;
  astrologer_name: string;
  user_id: string;
  user_name: string;
  user_phone?: string;
  type: string; // chat, voice, video
  status: string; // requested, active, completed, cancelled
  birth_dob?: string;
  birth_time?: string;
  birth_place?: string;
  problem_topic?: string;
  duration_minutes: number;
  per_minute_rate: number;
  total_amount: number;
  call_room_id?: string;
  notes?: string;
  created_at: string;
}

export default function ConsultationsPage() {
  const { isHindi } = useAdminLanguage();
  const [consultations, setConsultations] = useState<Consultation[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'all' | 'active' | 'completed'>('all');
  const [search, setSearch] = useState('');
  const [selectedConsultation, setSelectedConsultation] = useState<Consultation | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    fetchConsultations();
  }, []);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  };

  const fetchConsultations = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('consultations')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching consultations:', error);
      } else {
        setConsultations((data as Consultation[]) || []);
      }
    } catch (err) {
      console.error(err);
      setConsultations([]);
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (id: string, newStatus: string) => {
    try {
      const { error } = await supabase
        .from('consultations')
        .update({ status: newStatus })
        .eq('id', id);

      if (error) {
        showToast(`Failed: ${error.message}`);
      } else {
        showToast(
          isHindi
            ? `परामर्श स्थिति "${newStatus}" में अपडेट हुई`
            : `Session status updated to ${newStatus}`
        );
        setConsultations(
          consultations.map((c) => (c.id === id ? { ...c, status: newStatus } : c))
        );
        if (selectedConsultation && selectedConsultation.id === id) {
          setSelectedConsultation({ ...selectedConsultation, status: newStatus });
        }
      }
    } catch (err: any) {
      showToast(`Error: ${err.message}`);
    }
  };

  const filtered = consultations.filter((c) => {
    const matchSearch =
      (c.user_name || '').toLowerCase().includes(search.toLowerCase()) ||
      (c.astrologer_name || '').toLowerCase().includes(search.toLowerCase()) ||
      (c.id || '').toLowerCase().includes(search.toLowerCase());
    if (activeTab === 'active') return matchSearch && c.status === 'active';
    if (activeTab === 'completed') return matchSearch && c.status === 'completed';
    return matchSearch;
  });

  return (
    <div className="space-y-6">
      {/* Toast */}
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
            <span>💬</span> {isHindi ? 'लाइव परामर्श एवं संवाद निगरानी हब' : 'Live Consultations & Chat Supervision Hub'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'सुपाबेस डेटाबेस • वैदिक परामर्श, सत्र अवधि एवं एगोरा (Agora RTC) कॉल चैनल की सीधी निगरानी'
              : 'Live Supabase database • Supervise Vedic consultations, session durations, and Agora RTC call channels'}
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchConsultations}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>{isHindi ? 'रिफ्रेश' : 'Refresh'}</span>
          </button>
          <span className="px-3 py-1.5 rounded-xl bg-emerald-100 text-emerald-900 text-xs font-bold border border-emerald-200 whitespace-nowrap">
            {consultations.filter((c) => c.status === 'active').length} {isHindi ? 'सत्र सक्रिय' : 'Active Live'}
          </span>
        </div>
      </div>

      {/* Toolbar */}
      <div className="bg-white p-3.5 sm:p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">
            🔍
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={isHindi ? 'भक्त, ज्योतिषी या ID से खोजें...' : 'Search devotee, astrologer, or ID...'}
            className="w-full pl-8 pr-3 py-2 sm:py-1.5 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        {/* Tab Filters */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
          {[
            { key: 'all', labelEn: 'All', labelHi: 'सभी सत्र' },
            { key: 'active', labelEn: 'Active', labelHi: 'सक्रिय' },
            { key: 'completed', labelEn: 'Completed', labelHi: 'पूर्ण' },
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors shrink-0 ${
                activeTab === tab.key
                  ? 'bg-mandir-maroon text-amber-200'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {isHindi ? tab.labelHi : tab.labelEn}
            </button>
          ))}
        </div>
      </div>

      {/* Consultations Table & Detail Panel */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          {loading ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-3xl block mb-2 animate-spin">⏳</span>
              <span>{isHindi ? 'परामर्श सत्र लोड हो रहे हैं...' : 'Loading live consultation sessions...'}</span>
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-4xl block mb-2">💬</span>
              <p className="font-semibold text-gray-700">
                {isHindi ? 'कोई परामर्श सत्र नहीं मिला' : 'No consultation sessions found'}
              </p>
              <p className="mt-1 text-[11px]">
                {isHindi
                  ? 'भक्तों द्वारा प्रारंभ किए गए परामर्श यहाँ वास्तविक समय में दिखाई देंगे।'
                  : 'Sessions started by devotees on the app or website will show here in real time.'}
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs min-w-[650px]">
                <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                  <tr>
                    <th className="py-3 px-4">{isHindi ? 'सत्र ID' : 'Session ID'}</th>
                    <th className="py-3 px-4">{isHindi ? 'भक्त का नाम' : 'Devotee'}</th>
                    <th className="py-3 px-4">{isHindi ? 'पंडित / ज्योतिषी' : 'Astrologer'}</th>
                    <th className="py-3 px-4">{isHindi ? 'माध्यम' : 'Type'}</th>
                    <th className="py-3 px-4">{isHindi ? 'अवधि' : 'Duration'}</th>
                    <th className="py-3 px-4">{isHindi ? 'दक्षिणा' : 'Amount'}</th>
                    <th className="py-3 px-4">{isHindi ? 'स्थिति' : 'Status'}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700">
                  {filtered.map((c) => (
                    <tr
                      key={c.id}
                      onClick={() => {
                        setSelectedConsultation(c);
                        if (typeof window !== 'undefined' && window.innerWidth < 1024) {
                          document.getElementById('consultation-inspector')?.scrollIntoView({ behavior: 'smooth' });
                        }
                      }}
                      className={`hover:bg-emerald-50/30 cursor-pointer transition-colors ${
                        selectedConsultation?.id === c.id ? 'bg-emerald-50/60' : ''
                      }`}
                    >
                      <td className="py-3 px-4 font-mono font-semibold text-gray-900">
                        {c.id}
                      </td>
                      <td className="py-3 px-4 font-semibold text-gray-900">
                        {c.user_name || (isHindi ? 'भक्त' : 'Devotee')}
                      </td>
                      <td className="py-3 px-4 text-gray-800">{c.astrologer_name}</td>
                      <td className="py-3 px-4 uppercase text-[10px] font-bold text-gray-500">
                        {c.type === 'chat' ? (isHindi ? '💬 चैट' : 'Chat') : (isHindi ? '📞 कॉल' : 'Voice')}
                      </td>
                      <td className="py-3 px-4 font-mono">
                        {c.duration_minutes || 0} {isHindi ? 'मिनट' : 'min'}
                      </td>
                      <td className="py-3 px-4 font-bold font-cinzel text-gray-900">
                        ₹ {Number(c.total_amount || 0).toLocaleString('en-IN')}
                      </td>
                      <td className="py-3 px-4">
                        <span
                          className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-semibold capitalize ${
                            c.status === 'active'
                              ? 'bg-emerald-100 text-emerald-800 animate-pulse'
                              : 'bg-gray-100 text-gray-700'
                          }`}
                        >
                          {c.status || (isHindi ? 'पूर्ण' : 'Completed')}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Inspector */}
        <div id="consultation-inspector" className="bg-white rounded-2xl border border-gray-100 p-4 sm:p-5 shadow-sm space-y-4 scroll-mt-20">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 border-b border-gray-100 pb-2 flex items-center justify-between">
            <span>{isHindi ? 'परामर्श सत्र विवरण एवं नियंत्रण' : 'Session Details & Controls'}</span>
            {selectedConsultation && (
              <button
                onClick={() => setSelectedConsultation(null)}
                className="lg:hidden text-gray-400 hover:text-gray-600 text-xs px-1.5 py-0.5 rounded"
                title="Close Inspector"
              >
                ✕
              </button>
            )}
          </h2>

          {!selectedConsultation ? (
            <div className="py-12 sm:py-20 text-center text-gray-400 text-xs">
              <span>{isHindi ? 'विवरण देखने के लिए किसी सत्र पर क्लिक करें।' : 'Select any consultation to inspect live Agora channel and session data.'}</span>
            </div>
          ) : (
            <div className="space-y-4 text-xs">
              <div className="p-3 bg-gray-50 rounded-xl space-y-1">
                <div className="font-bold text-gray-900">{selectedConsultation.user_name}</div>
                <div className="text-gray-500 text-[11px]">
                  {isHindi ? 'पंडित:' : 'Consulting with'} <strong>{selectedConsultation.astrologer_name}</strong>
                </div>
                {selectedConsultation.problem_topic && (
                  <div className="pt-2 text-[11px] text-gray-700 border-t border-gray-200">
                    {isHindi ? 'विषय:' : 'Topic:'} {selectedConsultation.problem_topic}
                  </div>
                )}
              </div>

              {selectedConsultation.call_room_id && (
                <div className="p-2.5 bg-indigo-50 border border-indigo-200 rounded-xl text-[11px] break-all">
                  <span className="font-semibold text-indigo-900 block mb-0.5">
                    {isHindi ? 'एगोरा RTC कक्ष ID:' : 'Agora RTC Room ID:'}
                  </span>
                  <code className="font-mono text-indigo-700 text-xs">{selectedConsultation.call_room_id}</code>
                </div>
              )}

              {/* Status Update */}
              <div>
                <label className="block text-gray-500 font-semibold mb-1.5">
                  {isHindi ? 'सत्र स्थिति बदलें' : 'Manage Session'}
                </label>
                <div className="flex flex-wrap gap-1.5">
                  {[
                    { key: 'active', labelEn: 'Active', labelHi: 'सक्रिय' },
                    { key: 'completed', labelEn: 'Completed', labelHi: 'पूर्ण' },
                    { key: 'cancelled', labelEn: 'Cancelled', labelHi: 'रद्द' },
                  ].map((st) => (
                    <button
                      key={st.key}
                      onClick={() => updateStatus(selectedConsultation.id, st.key)}
                      className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold capitalize ${
                        selectedConsultation.status === st.key
                          ? 'bg-mandir-maroon text-amber-200'
                          : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                      }`}
                    >
                      {isHindi ? st.labelHi : st.labelEn}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
