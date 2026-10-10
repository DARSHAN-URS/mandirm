'use client';

import { useState } from 'react';

interface Devotee {
  id: string;
  full_name: string;
  email: string;
  phone: string;
  gotra: string;
  rashi: string;
  nakshatra: string;
  wallet_balance: number;
  created_at: string;
}

const SEED_DEVOTEES: Devotee[] = [
  { id: 'USR-101', full_name: 'Sunil Kumar Sharma', email: 'sunil.sharma@gmail.com', phone: '+91 98765 43210', gotra: 'Kashyapa', rashi: 'Vrishabha (Taurus)', nakshatra: 'Rohini', wallet_balance: 1250, created_at: '2026-08-14' },
  { id: 'USR-102', full_name: 'Pooja Agarwal', email: 'pooja.agarwal@outlook.com', phone: '+91 98110 54321', gotra: 'Garg', rashi: 'Kanya (Virgo)', nakshatra: 'Hasta', wallet_balance: 500, created_at: '2026-09-02' },
  { id: 'USR-103', full_name: 'Rameshwar Iyer', email: 'iyer.ramesh@gmail.com', phone: '+91 94440 12345', gotra: 'Bharadwaja', rashi: 'Dhanu (Sagittarius)', nakshatra: 'Moola', wallet_balance: 2100, created_at: '2026-09-18' },
  { id: 'USR-104', full_name: 'Ananya Deshmukh', email: 'ananya.deshmukh@yahoo.com', phone: '+91 98200 98765', gotra: 'Vashistha', rashi: 'Makar (Capricorn)', nakshatra: 'Shravana', wallet_balance: 350, created_at: '2026-10-01' },
];

export default function UsersPage() {
  const [devotees, setDevotees] = useState<Devotee[]>(SEED_DEVOTEES);
  const [search, setSearch] = useState('');

  const filtered = devotees.filter(d =>
    d.full_name.toLowerCase().includes(search.toLowerCase()) ||
    d.phone.includes(search) ||
    d.gotra.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>👥</span> Devotees & User Registry
          </h1>
          <p className="text-xs text-gray-500">
            Devotee spiritual profiles, Gotras, Vedic Rashis, Nakshatra lineages, and devotional wallets
          </p>
        </div>
        <div className="text-xs font-bold bg-purple-100 text-purple-900 px-3 py-1.5 rounded-xl border border-purple-200">
          Total Registered Devotees: 18,450
        </div>
      </div>

      {/* Devotees Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">User ID</th>
                <th className="py-3 px-4">Devotee Name</th>
                <th className="py-3 px-4">Contact Details</th>
                <th className="py-3 px-4">Gotra & Lineage</th>
                <th className="py-3 px-4">Rashi & Nakshatra</th>
                <th className="py-3 px-4">Wallet Balance</th>
                <th className="py-3 px-4 text-right">Member Since</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map(d => (
                <tr key={d.id} className="hover:bg-purple-50/20 transition-colors">
                  <td className="py-3.5 px-4 font-mono font-semibold text-gray-800">{d.id}</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900">{d.full_name}</td>
                  <td className="py-3.5 px-4">
                    <div className="text-gray-800 font-mono text-[11px]">{d.phone}</div>
                    <div className="text-[10px] text-gray-400">{d.email}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    <span className="font-semibold text-amber-900 bg-amber-50 px-2 py-0.5 rounded border border-amber-200">
                      Gotra: {d.gotra}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-gray-700">
                    <div>{d.rashi}</div>
                    <div className="text-[10px] text-gray-400 font-medium">Nakshatra: {d.nakshatra}</div>
                  </td>
                  <td className="py-3.5 px-4 font-bold text-emerald-700 font-mono">₹ {d.wallet_balance}</td>
                  <td className="py-3.5 px-4 text-right text-gray-500 font-mono">{d.created_at}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
