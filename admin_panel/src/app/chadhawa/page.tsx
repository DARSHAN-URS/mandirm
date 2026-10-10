'use client';

import { useState } from 'react';

interface ChadhawaOrder {
  id: string;
  devotee_name: string;
  gotra: string;
  temple_name: string;
  offering_item: string;
  quantity: number;
  dakshina: number;
  date: string;
  status: 'ordered' | 'sanctum_delivered' | 'prasad_dispatched';
}

const SEED_CHADHAWA: ChadhawaOrder[] = [
  { id: 'CH-201', devotee_name: 'Gaurav Khandelwal', gotra: 'Mittal', temple_name: 'Mahakaleshwar Jyotirlinga, Ujjain', offering_item: 'Silver Chhatra (Silver Umbrella Offering)', quantity: 1, dakshina: 2100, date: '2026-10-11', status: 'sanctum_delivered' },
  { id: 'CH-200', devotee_name: 'Smita Sengupta', gotra: 'Sandilya', temple_name: 'Kashi Vishwanath, Varanasi', offering_item: 'Holy Tulsi & Rudraksha Mala Arpan', quantity: 2, dakshina: 501, date: '2026-10-11', status: 'sanctum_delivered' },
  { id: 'CH-198', devotee_name: 'Naveen Reddy', gotra: 'Koundinya', temple_name: 'Tirupati Balaji, Andhra', offering_item: 'Pure Ghee Akhand Deepa Seva', quantity: 1, dakshina: 1100, date: '2026-10-10', status: 'prasad_dispatched' },
  { id: 'CH-195', devotee_name: 'Deepak Malhotra', gotra: 'Kapila', temple_name: 'Siddhivinayak Temple, Mumbai', offering_item: 'Modak & Laddu Bhog (51 Sweets)', quantity: 1, dakshina: 751, date: '2026-10-10', status: 'ordered' },
  { id: 'CH-191', devotee_name: 'Bhavna Chauhan', gotra: 'Vatsa', temple_name: 'Somnath Temple, Gujarat', offering_item: 'Silk Pitambari Vastra Arpan to Shivlinga', quantity: 1, dakshina: 1500, date: '2026-10-09', status: 'prasad_dispatched' },
];

export default function ChadhawaPage() {
  const [orders, setOrders] = useState<ChadhawaOrder[]>(SEED_CHADHAWA);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const filtered = orders.filter(o => {
    const matchSearch = o.devotee_name.toLowerCase().includes(search.toLowerCase()) ||
                        o.offering_item.toLowerCase().includes(search.toLowerCase()) ||
                        o.id.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter === 'all' || o.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const toggleStatus = (id: string, newStatus: ChadhawaOrder['status']) => {
    setOrders(orders.map(o => o.id === id ? { ...o, status: newStatus } : o));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>🌸</span> Sacred Chadhawa Offerings Console
          </h1>
          <p className="text-xs text-gray-500">
            Track devotee offerings to deities (Silver Chhatra, Vastra, Diya, Flowers) and sanctum delivery proofs
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="px-3 py-1.5 rounded-xl bg-pink-100 text-pink-900 text-xs font-bold border border-pink-200">
            Total Offerings Value: ₹ {orders.reduce((sum, o) => sum + o.dakshina, 0).toLocaleString('en-IN')}
          </span>
        </div>
      </div>

      {/* Filter Toolbar */}
      <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">🔍</span>
          <input
            type="text"
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search devotee, offering item, or ID..."
            className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        <div className="flex flex-wrap gap-1.5">
          {['all', 'ordered', 'sanctum_delivered', 'prasad_dispatched'].map(st => (
            <button
              key={st}
              onClick={() => setStatusFilter(st)}
              className={`px-3 py-1 rounded-lg text-xs font-semibold capitalize transition-all ${
                statusFilter === st
                  ? 'bg-mandir-maroon text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {st.replace('_', ' ')}
            </button>
          ))}
        </div>
      </div>

      {/* Chadhawa Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">Offering ID</th>
                <th className="py-3 px-4">Devotee & Gotra</th>
                <th className="py-3 px-4">Sacred Offering Item</th>
                <th className="py-3 px-4">Temple Destination</th>
                <th className="py-3 px-4">Dakshina</th>
                <th className="py-3 px-4">Offering Status</th>
                <th className="py-3 px-4 text-right">Update Stage</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map(o => (
                <tr key={o.id} className="hover:bg-pink-50/20 transition-colors">
                  <td className="py-3.5 px-4 font-mono font-semibold text-gray-800">{o.id}</td>
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-gray-900">{o.devotee_name}</div>
                    <div className="text-[10px] text-amber-800">Gotra: {o.gotra}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-semibold text-gray-900">{o.offering_item}</div>
                    <div className="text-[10px] text-gray-400">Qty: {o.quantity} units</div>
                  </td>
                  <td className="py-3.5 px-4 text-gray-700 font-medium">{o.temple_name}</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900 font-mono">₹ {o.dakshina.toLocaleString('en-IN')}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold capitalize ${
                      o.status === 'sanctum_delivered' ? 'bg-purple-100 text-purple-800' :
                      o.status === 'prasad_dispatched' ? 'bg-emerald-100 text-emerald-800' :
                      'bg-amber-100 text-amber-800'
                    }`}>
                      {o.status.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <select
                      value={o.status}
                      onChange={e => toggleStatus(o.id, e.target.value as ChadhawaOrder['status'])}
                      className="p-1.5 border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 bg-white"
                    >
                      <option value="ordered">Ordered</option>
                      <option value="sanctum_delivered">Offered at Sanctum</option>
                      <option value="prasad_dispatched">Prasad Dispatched</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
