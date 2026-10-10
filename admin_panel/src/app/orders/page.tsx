'use client';

import { useState } from 'react';

interface Order {
  id: string;
  devotee_name: string;
  items: string;
  amount: number;
  delivery_city: string;
  date: string;
  status: 'processing' | 'shipped' | 'delivered';
  tracking_id?: string;
}

const SEED_ORDERS: Order[] = [
  { id: 'ORD-8910', devotee_name: 'Mehul Trivedi', items: 'Consecrated Brass Ganesha Murti + 5-Mukhi Mala', amount: 2100, delivery_city: 'Ahmedabad, Gujarat', date: 'Today, 09:30 AM', status: 'processing' },
  { id: 'ORD-8908', devotee_name: 'Priyanka Sen', items: 'Pure Parad Shivlinga + Jaladhari', amount: 2100, delivery_city: 'Kolkata, West Bengal', date: 'Today, 08:15 AM', status: 'shipped', tracking_id: 'BD-8891234IN' },
  { id: 'ORD-8902', devotee_name: 'Harish Chandra', items: 'Sandalwood Dhoop (x2) + Kashi Gangajal', amount: 950, delivery_city: 'Jaipur, Rajasthan', date: 'Yesterday', status: 'shipped', tracking_id: 'DEL-4412990IN' },
  { id: 'ORD-8895', devotee_name: 'Swati Ranganathan', items: 'Navgrah Yantra (Gold Plated Plate)', amount: 650, delivery_city: 'Bengaluru, Karnataka', date: '2026-10-09', status: 'delivered', tracking_id: 'EXP-1092881IN' },
];

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>(SEED_ORDERS);
  const [statusFilter, setStatusFilter] = useState('all');

  const filtered = orders.filter(o => statusFilter === 'all' || o.status === statusFilter);

  const updateStatus = (id: string, st: Order['status']) => {
    setOrders(orders.map(o => o.id === id ? { ...o, status: st } : o));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>📦</span> Spiritual Prasad & Samagri Orders Dispatch
          </h1>
          <p className="text-xs text-gray-500">
            Fulfill devotee merchandise orders, dispatch consecrated Prasad boxes, and track courier logistics
          </p>
        </div>
      </div>

      {/* Orders Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">Order ID</th>
                <th className="py-3 px-4">Devotee</th>
                <th className="py-3 px-4">Items Ordered</th>
                <th className="py-3 px-4">Destination</th>
                <th className="py-3 px-4">Order Total</th>
                <th className="py-3 px-4">Fulfillment Status</th>
                <th className="py-3 px-4 text-right">Update Logistics</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map(o => (
                <tr key={o.id} className="hover:bg-blue-50/20 transition-colors">
                  <td className="py-3.5 px-4 font-mono font-bold text-gray-800">{o.id}</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900">{o.devotee_name}</td>
                  <td className="py-3.5 px-4 text-gray-700 font-medium max-w-xs">{o.items}</td>
                  <td className="py-3.5 px-4 text-gray-500">{o.delivery_city}</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900 font-mono">₹ {o.amount}</td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold capitalize ${
                      o.status === 'delivered' ? 'bg-emerald-100 text-emerald-800' :
                      o.status === 'shipped' ? 'bg-blue-100 text-blue-800' :
                      'bg-amber-100 text-amber-800'
                    }`}>
                      {o.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <select
                      value={o.status}
                      onChange={e => updateStatus(o.id, e.target.value as Order['status'])}
                      className="p-1.5 border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 bg-white"
                    >
                      <option value="processing">Processing</option>
                      <option value="shipped">Shipped</option>
                      <option value="delivered">Delivered</option>
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
