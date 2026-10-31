'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

interface Profile {
  id: string;
  email?: string;
  phone?: string;
  full_name: string;
  role: string;
  gotra?: string;
  rashi?: string;
  nakshatra?: string;
  wallet_balance: number;
  created_at: string;
}

export default function UsersPage() {
  const { isHindi } = useAdminLanguage();
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    fetchProfiles();
  }, []);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  };

  const fetchProfiles = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching profiles:', error);
      } else {
        setProfiles((data as Profile[]) || []);
      }
    } catch (err) {
      console.error(err);
      setProfiles([]);
    } finally {
      setLoading(false);
    }
  };

  const filtered = profiles.filter((p) => {
    const q = search.toLowerCase();
    return (
      (p.full_name || '').toLowerCase().includes(q) ||
      (p.phone || '').includes(q) ||
      (p.email || '').toLowerCase().includes(q) ||
      (p.gotra || '').toLowerCase().includes(q)
    );
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
            <span>👥</span> {isHindi ? 'भक्त एवं उपयोगकर्ता पंजिका' : 'Devotees & User Registry'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'सुपाबेस डेटाबेस • भक्त आध्यात्मिक प्रोफाइल, गोत्र, वैदिक राशियां, नक्षत्र वंश एवं वॉलेट बैलेंस'
              : 'Live Supabase database • Devotee spiritual profiles, Gotras, Vedic Rashis, Nakshatra lineages, and wallets'}
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchProfiles}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>{isHindi ? 'रिफ्रेश' : 'Refresh'}</span>
          </button>
          <span className="px-3 py-1.5 rounded-xl bg-purple-100 text-purple-900 text-xs font-bold border border-purple-200 whitespace-nowrap">
            {profiles.length} {isHindi ? 'पंजीकृत भक्त' : 'Devotees'}
          </span>
        </div>
      </div>

      {/* Search Toolbar */}
      <div className="bg-white p-3.5 sm:p-4 rounded-xl border border-gray-200 flex items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">
            🔍
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={isHindi ? 'नाम, फ़ोन, ईमेल या गोत्र से खोजें...' : 'Search by name, phone, email, or Gotra...'}
            className="w-full pl-8 pr-3 py-2 sm:py-1.5 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>
      </div>

      {/* Profiles Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            <span className="text-3xl block mb-2 animate-spin">⏳</span>
            <span>{isHindi ? 'डेटाबेस से भक्त पंजिका लोड हो रही है...' : 'Loading real devotee registry from database...'}</span>
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            <span className="text-4xl block mb-2">👥</span>
            <p className="font-semibold text-gray-700">
              {isHindi ? 'डेटाबेस में कोई भक्त प्रोफाइल दर्ज नहीं है' : 'No devotee profiles recorded yet'}
            </p>
            <p className="mt-1 text-[11px]">
              {isHindi
                ? 'वेबसाइट या ऐप पर साइन-अप करने वाले भक्त यहाँ स्वतः प्रदर्शित होंगे।'
                : 'Users who sign up in the mobile app or website will automatically appear here.'}
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs min-w-[700px]">
              <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                <tr>
                  <th className="py-3 px-4">{isHindi ? 'प्रोफाइल ID' : 'Profile ID'}</th>
                  <th className="py-3 px-4">{isHindi ? 'भक्त का नाम' : 'Devotee Name'}</th>
                  <th className="py-3 px-4">{isHindi ? 'फ़ोन / ईमेल' : 'Phone / Email'}</th>
                  <th className="py-3 px-4">{isHindi ? 'गोत्र एवं राशि' : 'Gotra & Rashi'}</th>
                  <th className="py-3 px-4">{isHindi ? 'भूमिका' : 'Role'}</th>
                  <th className="py-3 px-4">{isHindi ? 'वॉलेट शेष' : 'Wallet Balance'}</th>
                  <th className="py-3 px-4 text-right">{isHindi ? 'शामिल हुए' : 'Joined'}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-gray-700">
                {filtered.map((p) => (
                  <tr key={p.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="py-3 px-4 font-mono text-gray-500 text-[11px] max-w-[120px] truncate">
                      {p.id}
                    </td>
                    <td className="py-3 px-4 font-semibold text-gray-900">
                      {p.full_name || (isHindi ? 'भक्त' : 'Devotee')}
                    </td>
                    <td className="py-3 px-4">
                      <span className="block font-mono text-[11px] text-gray-800">
                        {p.phone || '—'}
                      </span>
                      {p.email && (
                        <span className="text-[10px] text-gray-400 block">{p.email}</span>
                      )}
                    </td>
                    <td className="py-3 px-4 text-gray-600">
                      {p.gotra ? (
                        <span className="font-semibold text-amber-900 font-mono">
                          {isHindi ? 'गोत्र:' : 'Gotra:'} {p.gotra}
                        </span>
                      ) : (
                        '—'
                      )}
                      {p.rashi && (
                        <span className="text-[10px] text-gray-500 block">
                          {isHindi ? 'राशि:' : 'Rashi:'} {p.rashi}
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4">
                      <span
                        className={`inline-block px-2 py-0.5 rounded-full text-[10px] font-semibold uppercase ${
                          p.role === 'admin'
                            ? 'bg-amber-100 text-amber-800'
                            : p.role === 'astrologer'
                            ? 'bg-indigo-100 text-indigo-800'
                            : 'bg-gray-100 text-gray-600'
                        }`}
                      >
                        {p.role || 'user'}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-bold font-cinzel text-gray-900">
                      ₹ {Number(p.wallet_balance || 0).toLocaleString('en-IN')}
                    </td>
                    <td className="py-3 px-4 text-right text-gray-400 font-mono text-[10px]">
                      {p.created_at ? new Date(p.created_at).toLocaleDateString(isHindi ? 'hi-IN' : 'en-IN') : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
