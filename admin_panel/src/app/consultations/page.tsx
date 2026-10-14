'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

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
        showToast(`Session status updated to ${newStatus}`);
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
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>💬</span> Live Consultations & Chat Supervision Hub
          </h1>
          <p className="text-xs text-gray-500">
            Live Supabase database • Supervise Vedic consultations, session durations, and Agora RTC call channels
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={fetchConsultations}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>Refresh</span>
          </button>
          <span className="px-3 py-1.5 rounded-xl bg-emerald-100 text-emerald-900 text-xs font-bold border border-emerald-200">
            {consultations.filter((c) => c.status === 'active').length} Active Live
          </span>
        </div>
      </div>

      {/* Toolbar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">
            🔍
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search devotee, astrologer, or ID..."
            className="w-full pl-8 pr-3 py-1.5 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        {/* Tab Filters */}
        <div className="flex items-center gap-1.5">
          {(['all', 'active', 'completed'] as const).map((tab) => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className={`px-3 py-1 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors ${
                activeTab === tab
                  ? 'bg-mandir-maroon text-amber-200'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {tab}
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
              <span>Loading live consultation sessions...</span>
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-4xl block mb-2">💬</span>
              <p className="font-semibold text-gray-700">No consultation sessions found</p>
              <p className="mt-1 text-[11px]">
                Sessions started by devotees on the app or website will show here in real time.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                  <tr>
                    <th className="py-3 px-4">Session ID</th>
                    <th className="py-3 px-4">Devotee</th>
                    <th className="py-3 px-4">Astrologer</th>
                    <th className="py-3 px-4">Type</th>
                    <th className="py-3 px-4">Duration</th>
                    <th className="py-3 px-4">Amount</th>
                    <th className="py-3 px-4">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700">
                  {filtered.map((c) => (
                    <tr
                      key={c.id}
                      onClick={() => setSelectedConsultation(c)}
                      className={`hover:bg-emerald-50/30 cursor-pointer transition-colors ${
                        selectedConsultation?.id === c.id ? 'bg-emerald-50/60' : ''
                      }`}
                    >
                      <td className="py-3 px-4 font-mono font-semibold text-gray-900">
                        {c.id}
                      </td>
                      <td className="py-3 px-4 font-semibold text-gray-900">
                        {c.user_name || 'Devotee'}
                      </td>
                      <td className="py-3 px-4 text-gray-800">{c.astrologer_name}</td>
                      <td className="py-3 px-4 uppercase text-[10px] font-bold text-gray-500">
                        {c.type}
                      </td>
                      <td className="py-3 px-4 font-mono">{c.duration_minutes || 0} min</td>
                      <td className="py-3 px-4 font-bold font-cinzel text-gray-900">
                        ₹ {Number(c.total_amount || 0).toLocaleString('en-IN')}
                      </td>
                      <td className="py-3 px-4">
                        <span
                          className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-semibold capitalize ${
                            c.status === 'active'
                              ? 'bg-emerald-100 text-emerald-800 animate-pulse'
                              : 'bg-gray-100 text-gray-600'
                          }`}
                        >
                          {c.status}
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
        <div className="bg-white rounded-2xl border border-gray-100 p-5 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 border-b border-gray-100 pb-2">
            Session Details & Controls
          </h2>

          {!selectedConsultation ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span>Select any consultation to inspect live Agora channel and session data.</span>
            </div>
          ) : (
            <div className="space-y-4 text-xs">
              <div className="p-3 bg-gray-50 rounded-xl space-y-1">
                <div className="font-bold text-gray-900">{selectedConsultation.user_name}</div>
                <div className="text-gray-500 text-[11px]">
                  Consulting with <strong>{selectedConsultation.astrologer_name}</strong>
                </div>
                {selectedConsultation.problem_topic && (
                  <div className="pt-2 text-[11px] text-gray-700 border-t border-gray-200">
                    Topic: {selectedConsultation.problem_topic}
                  </div>
                )}
              </div>

              {selectedConsultation.call_room_id && (
                <div className="p-2.5 bg-indigo-50 border border-indigo-200 rounded-xl text-[11px]">
                  <span className="font-semibold text-indigo-900 block mb-0.5">Agora RTC Room ID:</span>
                  <code className="font-mono text-indigo-700 text-xs">{selectedConsultation.call_room_id}</code>
                </div>
              )}

              {/* Status Update */}
              <div>
                <label className="block text-gray-500 font-semibold mb-1.5">Manage Session</label>
                <div className="flex flex-wrap gap-1.5">
                  {['active', 'completed', 'cancelled'].map((st) => (
                    <button
                      key={st}
                      onClick={() => updateStatus(selectedConsultation.id, st)}
                      className={`px-3 py-1 rounded-lg text-xs font-semibold capitalize ${
                        selectedConsultation.status === st
                          ? 'bg-mandir-maroon text-amber-200'
                          : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                      }`}
                    >
                      {st}
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
