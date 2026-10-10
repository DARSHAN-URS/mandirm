'use client';

import { useState } from 'react';

interface Astrologer {
  id: string;
  name: string;
  title: string;
  specialties: string[];
  experience_years: number;
  languages: string[];
  call_rate: number;
  chat_rate: number;
  rating: number;
  consultations_count: number;
  kyc_status: 'verified' | 'pending' | 'suspended';
  phone: string;
}

const SEED_ASTROLOGERS: Astrologer[] = [
  { id: 'AST-01', name: 'Pandit Radheshyam Shastri', title: 'Jyotish Acharya & Gold Medalist', specialties: ['Vedic Astrology', 'Kundli Milan', 'Prashna Kundli'], experience_years: 18, languages: ['Hindi', 'Sanskrit', 'English'], call_rate: 35, chat_rate: 25, rating: 4.9, consultations_count: 3240, kyc_status: 'verified', phone: '+91 98765 43210' },
  { id: 'AST-02', name: 'Acharya Vidyadhar Vyas', title: 'Vedic Scholar & Vastu Specialist', specialties: ['Vastu Shastra', 'Muhurat', 'Navgrah Dosh'], experience_years: 22, languages: ['Hindi', 'Gujarati'], call_rate: 45, chat_rate: 30, rating: 5.0, consultations_count: 4890, kyc_status: 'verified', phone: '+91 98220 12345' },
  { id: 'AST-03', name: 'Dr. Jyotishacharya Devraj', title: 'Ph.D. in Vedic Astrology', specialties: ['Career Guidance', 'Medical Astrology', 'Gemology'], experience_years: 15, languages: ['Hindi', 'English', 'Bengali'], call_rate: 50, chat_rate: 35, rating: 4.8, consultations_count: 2150, kyc_status: 'verified', phone: '+91 94112 34567' },
  { id: 'AST-04', name: 'Swami Anand Swaroop', title: 'Kundli & Spiritual Mentor', specialties: ['Spiritual Healing', 'Mantra Shastra', 'Tarot'], experience_years: 12, languages: ['Hindi', 'English'], call_rate: 30, chat_rate: 20, rating: 4.7, consultations_count: 1420, kyc_status: 'pending', phone: '+91 97180 98765' },
  { id: 'AST-05', name: 'Smt. Gayatri Devi', title: 'Vedic Palmistry & Numerology Expert', specialties: ['Palmistry', 'Numerology', 'Marriage Matching'], experience_years: 10, languages: ['Hindi', 'Marathi'], call_rate: 25, chat_rate: 18, rating: 4.9, consultations_count: 980, kyc_status: 'pending', phone: '+91 98901 23456' },
  { id: 'AST-06', name: 'Pandit Rameshwar Trivedi', title: 'Karmakanda & Tantra Shanti Specialist', specialties: ['Dosha Nivaran', 'Karmakanda'], experience_years: 8, languages: ['Hindi'], call_rate: 20, chat_rate: 15, rating: 4.2, consultations_count: 410, kyc_status: 'suspended', phone: '+91 99887 76655' },
];

export default function AstrologersPage() {
  const [astrologers, setAstrologers] = useState<Astrologer[]>(SEED_ASTROLOGERS);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const filtered = astrologers.filter(a => {
    const matchSearch = a.name.toLowerCase().includes(search.toLowerCase()) ||
                        a.specialties.some(s => s.toLowerCase().includes(search.toLowerCase()));
    const matchStatus = statusFilter === 'all' || a.kyc_status === statusFilter;
    return matchSearch && matchStatus;
  });

  const toggleKyc = (id: string, status: Astrologer['kyc_status']) => {
    setAstrologers(astrologers.map(a => a.id === id ? { ...a, kyc_status: status } : a));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🧘‍♂️</span> Astrologers & Acharyas KYC Console
          </h1>
          <p className="text-xs text-gray-500">
            Verify Vedic Jyotish credentials, approve onboarding applications, and regulate call/chat dakshina rates
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="px-3 py-1.5 rounded-xl bg-indigo-100 text-indigo-900 text-xs font-bold border border-indigo-200">
            {astrologers.filter(a => a.kyc_status === 'pending').length} KYC Applications Awaiting Approval
          </span>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search by Acharya name or specialty..."
            className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        <div className="flex flex-wrap gap-1.5">
          {['all', 'verified', 'pending', 'suspended'].map(st => (
            <button
              key={st}
              onClick={() => setStatusFilter(st)}
              className={`px-3 py-1 rounded-lg text-xs font-semibold capitalize transition-all ${
                statusFilter === st
                  ? 'bg-mandir-maroon text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {st === 'pending' ? 'Pending KYC' : st}
            </button>
          ))}
        </div>
      </div>

      {/* Astrologers Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.map(a => (
          <div key={a.id} className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-all flex flex-col justify-between">
            <div className="p-5">
              {/* Profile Card Header */}
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-br from-amber-200 to-amber-300 text-mandir-maroon font-bold flex items-center justify-center text-xl shadow-inner">
                    🧘‍♂️
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-gray-900 font-cinzel leading-tight">{a.name}</h3>
                    <p className="text-[11px] text-amber-800 font-medium">{a.title}</p>
                    <p className="text-[10px] text-gray-400">{a.experience_years} Years Experience</p>
                  </div>
                </div>
                <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold uppercase ${
                  a.kyc_status === 'verified' ? 'bg-emerald-100 text-emerald-800' :
                  a.kyc_status === 'pending' ? 'bg-amber-100 text-amber-800 animate-pulse' :
                  'bg-red-100 text-red-800'
                }`}>
                  {a.kyc_status}
                </span>
              </div>

              {/* Specialties */}
              <div className="space-y-2 text-xs mb-4">
                <div className="flex flex-wrap gap-1">
                  {a.specialties.map(s => (
                    <span key={s} className="px-2 py-0.5 rounded-md bg-gray-100 text-gray-700 text-[10px] font-medium">
                      {s}
                    </span>
                  ))}
                </div>

                <div className="text-[11px] text-gray-500">
                  Languages: <strong>{a.languages.join(', ')}</strong>
                </div>

                {/* Rates & Consultations */}
                <div className="p-2.5 bg-gray-50 rounded-xl grid grid-cols-2 gap-2 text-center text-xs">
                  <div>
                    <span className="text-[10px] text-gray-400 block">Call Dakshina</span>
                    <strong className="text-gray-900">₹{a.call_rate}/min</strong>
                  </div>
                  <div>
                    <span className="text-[10px] text-gray-400 block">WhatsApp Chat</span>
                    <strong className="text-gray-900">₹{a.chat_rate}/min</strong>
                  </div>
                </div>
              </div>
            </div>

            {/* Actions Bar */}
            <div className="p-3 bg-gray-50/80 border-t border-gray-100 flex items-center justify-between">
              <span className="text-xs font-semibold text-gray-700">⭐ {a.rating} ({a.consultations_count} calls)</span>
              <div className="flex items-center gap-1.5">
                {a.kyc_status !== 'verified' && (
                  <button
                    onClick={() => toggleKyc(a.id, 'verified')}
                    className="px-2.5 py-1 bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg text-xs font-bold transition-all shadow-sm"
                  >
                    Approve KYC
                  </button>
                )}
                {a.kyc_status !== 'suspended' && (
                  <button
                    onClick={() => toggleKyc(a.id, 'suspended')}
                    className="px-2.5 py-1 bg-red-100 hover:bg-red-200 text-red-800 rounded-lg text-xs font-semibold transition-all"
                  >
                    Suspend
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
