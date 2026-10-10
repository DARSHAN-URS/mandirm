'use client';

import { useState } from 'react';

interface Consultation {
  id: string;
  devotee_name: string;
  astrologer_name: string;
  type: 'chat' | 'video' | 'voice';
  status: 'active' | 'completed' | 'requested';
  duration_minutes: number;
  total_amount: number;
  date: string;
  moderation_flag: boolean;
  flag_reason?: string;
  offending_text?: string;
}

const SEED_CONSULTATIONS: Consultation[] = [
  { id: 'CONS-402', devotee_name: 'Aditya Verma', astrologer_name: 'Pandit Radheshyam Shastri', type: 'chat', status: 'active', duration_minutes: 14, total_amount: 350, date: 'Today, 11:20 AM', moderation_flag: false },
  { id: 'CONS-401', devotee_name: 'Meenakshi Sundaram', astrologer_name: 'Acharya Vidyadhar Vyas', type: 'video', status: 'active', duration_minutes: 22, total_amount: 990, date: 'Today, 11:10 AM', moderation_flag: false },
  { id: 'CONS-399', devotee_name: 'Kunal Singhania', astrologer_name: 'Swami Anand Swaroop', type: 'chat', status: 'completed', duration_minutes: 8, total_amount: 160, date: 'Today, 10:45 AM', moderation_flag: true, flag_reason: 'contact_sharing', offending_text: 'Guruji, call me on 9876543210 for horoscope reading outside app' },
  { id: 'CONS-398', devotee_name: 'Rajesh Nair', astrologer_name: 'Dr. Jyotishacharya Devraj', type: 'chat', status: 'completed', duration_minutes: 18, total_amount: 630, date: 'Today, 10:15 AM', moderation_flag: false },
  { id: 'CONS-394', devotee_name: 'Anonymous Devotee', astrologer_name: 'Pandit Rameshwar Trivedi', type: 'chat', status: 'completed', duration_minutes: 5, total_amount: 100, date: 'Yesterday', moderation_flag: true, flag_reason: 'external_payment', offending_text: 'Please send dakshina directly to my upi handle: guru@oksbi' },
  { id: 'CONS-392', devotee_name: 'Kavita Chawla', astrologer_name: 'Swami Anand Swaroop', type: 'voice', status: 'completed', duration_minutes: 11, total_amount: 330, date: 'Yesterday', moderation_flag: false },
];

export default function ConsultationsPage() {
  const [consultations, setConsultations] = useState<Consultation[]>(SEED_CONSULTATIONS);
  const [activeTab, setActiveTab] = useState<'all' | 'flagged' | 'live'>('all');
  const [search, setSearch] = useState('');
  const [selectedConsultation, setSelectedConsultation] = useState<Consultation | null>(null);

  const filtered = consultations.filter(c => {
    const matchSearch = c.devotee_name.toLowerCase().includes(search.toLowerCase()) ||
                        c.astrologer_name.toLowerCase().includes(search.toLowerCase()) ||
                        c.id.toLowerCase().includes(search.toLowerCase());
    if (activeTab === 'flagged') return matchSearch && c.moderation_flag;
    if (activeTab === 'live') return matchSearch && c.status === 'active';
    return matchSearch;
  });

  const dismissFlag = (id: string) => {
    setConsultations(consultations.map(c => c.id === id ? { ...c, moderation_flag: false } : c));
    if (selectedConsultation && selectedConsultation.id === id) {
      setSelectedConsultation({ ...selectedConsultation, moderation_flag: false });
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>💬</span> Consultations & Real-Time Chat Moderation
          </h1>
          <p className="text-xs text-gray-500">
            Supervise 1-on-1 calls, WhatsApp-style live chats, and enforce anti-disintermediation safety shields
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="px-3 py-1.5 rounded-xl bg-red-100 text-red-900 text-xs font-bold border border-red-200 flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-red-500 animate-ping"></span>
            {consultations.filter(c => c.moderation_flag).length} Moderation Flags Pending Review
          </span>
        </div>
      </div>

      {/* Filter and Tab Bar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search devotee or astrologer..."
            className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setActiveTab('all')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'all' ? 'bg-mandir-maroon text-white shadow-sm' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All Consultations ({consultations.length})
          </button>
          <button
            onClick={() => setActiveTab('live')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all flex items-center gap-1 ${
              activeTab === 'live' ? 'bg-emerald-600 text-white shadow-sm' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            Live Active ({consultations.filter(c => c.status === 'active').length})
          </button>
          <button
            onClick={() => setActiveTab('flagged')}
            className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all flex items-center gap-1 ${
              activeTab === 'flagged' ? 'bg-red-600 text-white shadow-sm' : 'bg-red-50 text-red-700 hover:bg-red-100'
            }`}
          >
            <span>🛡️</span> Moderation Flags ({consultations.filter(c => c.moderation_flag).length})
          </button>
        </div>
      </div>

      {/* Consultations Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">Session ID</th>
                <th className="py-3 px-4">Devotee</th>
                <th className="py-3 px-4">Astrologer</th>
                <th className="py-3 px-4">Session Type</th>
                <th className="py-3 px-4">Duration & Dakshina</th>
                <th className="py-3 px-4">Safety Shield Status</th>
                <th className="py-3 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map(c => (
                <tr key={c.id} className={`hover:bg-amber-50/20 transition-colors ${c.moderation_flag ? 'bg-red-50/30' : ''}`}>
                  <td className="py-3.5 px-4 font-mono font-semibold text-gray-800">{c.id}</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900">{c.devotee_name}</td>
                  <td className="py-3.5 px-4 text-gray-800 font-medium">{c.astrologer_name}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      c.type === 'chat' ? 'bg-emerald-100 text-emerald-800' :
                      c.type === 'video' ? 'bg-indigo-100 text-indigo-800' :
                      'bg-purple-100 text-purple-800'
                    }`}>
                      {c.type === 'chat' ? '💬 WhatsApp Chat' : c.type === 'video' ? '📹 Agora Video' : '📞 Voice Call'}
                    </span>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-gray-900 font-mono">₹ {c.total_amount}</div>
                    <div className="text-[10px] text-gray-400">{c.duration_minutes} mins • {c.date}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    {c.moderation_flag ? (
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-bold bg-red-100 text-red-800 flex items-center gap-1 w-max animate-pulse">
                        ⚠️ Violation: {c.flag_reason?.replace('_', ' ')}
                      </span>
                    ) : (
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800 flex items-center gap-1 w-max">
                        ✓ Clean & Safe
                      </span>
                    )}
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <button
                      onClick={() => setSelectedConsultation(c)}
                      className={`px-3 py-1 font-semibold rounded-lg text-xs transition-colors shadow-sm ${
                        c.moderation_flag
                          ? 'bg-red-600 hover:bg-red-700 text-white font-bold'
                          : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                      }`}
                    >
                      {c.moderation_flag ? 'Review Flag' : 'Inspect'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Moderation Inspection Modal */}
      {selectedConsultation && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-gray-200 space-y-4 text-xs">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100">
              <div>
                <span className="text-[10px] font-mono font-bold text-gray-400">{selectedConsultation.id}</span>
                <h2 className="text-base font-bold font-cinzel text-gray-900">
                  {selectedConsultation.moderation_flag ? '⚠️ Safety Flag Review' : 'Consultation Session Detail'}
                </h2>
              </div>
              <button
                onClick={() => setSelectedConsultation(null)}
                className="text-gray-400 hover:text-gray-600 text-lg"
              >
                ✕
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3 p-3 bg-gray-50 rounded-xl">
              <div>
                <span className="text-gray-400 text-[10px] uppercase font-bold block">Devotee</span>
                <span className="font-bold text-gray-900 text-xs">{selectedConsultation.devotee_name}</span>
              </div>
              <div>
                <span className="text-gray-400 text-[10px] uppercase font-bold block">Astrologer</span>
                <span className="font-bold text-gray-900 text-xs">{selectedConsultation.astrologer_name}</span>
              </div>
              <div>
                <span className="text-gray-400 text-[10px] uppercase font-bold block">Type</span>
                <span className="font-semibold text-gray-800">{selectedConsultation.type.toUpperCase()}</span>
              </div>
              <div>
                <span className="text-gray-400 text-[10px] uppercase font-bold block">Dakshina</span>
                <span className="font-bold text-gray-900">₹ {selectedConsultation.total_amount} ({selectedConsultation.duration_minutes} min)</span>
              </div>
            </div>

            {selectedConsultation.moderation_flag && (
              <div className="p-3 bg-red-50 border border-red-200 rounded-xl space-y-2">
                <div className="flex items-center gap-1.5 text-red-800 font-bold">
                  <span>🚨 Violation Detected by Pre-Flight Shield:</span>
                  <span className="uppercase text-[11px] underline">{selectedConsultation.flag_reason}</span>
                </div>
                <div className="p-2 bg-white rounded-lg border border-red-100 font-mono text-[11px] text-red-900">
                  "{selectedConsultation.offending_text}"
                </div>
                <p className="text-[10px] text-red-700 leading-tight">
                  This message attempted off-platform disintermediation. The automated filter intercepted and quarantined the communication.
                </p>
              </div>
            )}

            <div className="pt-3 border-t border-gray-100 flex justify-end gap-2">
              {selectedConsultation.moderation_flag && (
                <>
                  <button
                    onClick={() => dismissFlag(selectedConsultation.id)}
                    className="px-3 py-1.5 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold rounded-lg text-xs"
                  >
                    Dismiss False Positive
                  </button>
                  <button
                    onClick={() => {
                      alert('Account warned for violating Mandirm Community Guidelines.');
                      dismissFlag(selectedConsultation.id);
                    }}
                    className="px-3 py-1.5 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg text-xs shadow-sm"
                  >
                    Issue Formal Warning / Strike
                  </button>
                </>
              )}
              <button
                onClick={() => setSelectedConsultation(null)}
                className="px-4 py-1.5 bg-gray-200 text-gray-700 font-semibold rounded-lg text-xs"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
