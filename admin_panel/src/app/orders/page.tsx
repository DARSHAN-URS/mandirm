'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface Order {
  id: string;
  user_id?: string;
  user_name: string;
  user_phone?: string;
  shipping_address?: string;
  total_amount: number;
  payment_id?: string;
  payment_status?: string;
  order_status: string; // Pending, Processing, Shipped, Delivered, Cancelled
  created_at: string;
}

export default function OrdersPage() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('all');
  const [toast, setToast] = useState<string | null>(null);

  useEffect(() => {
    fetchOrders();
  }, []);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  };

  const fetchOrders = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('orders')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching orders:', error);
      } else {
        setOrders((data as Order[]) || []);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (id: string, st: string) => {
    try {
      const { error } = await supabase
        .from('orders')
        .update({ order_status: st })
        .eq('id', id);

      if (error) {
        showToast(`Failed: ${error.message}`);
      } else {
        showToast(`Order ${id} marked as ${st}`);
        setOrders(
          orders.map((o) => (o.id === id ? { ...o, order_status: st } : o))
        );
      }
    } catch (err: any) {
      showToast(`Error: ${err.message}`);
    }
  };

  const filtered = orders.filter(
    (o) =>
      statusFilter === 'all' ||
      (o.order_status || '').toLowerCase() === statusFilter.toLowerCase()
  );

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
            <span>📦</span> Spiritual Prasad & Samagri Orders Dispatch
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Live Supabase database • Fulfill store orders, track payments, and update courier shipments
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchOrders}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>Refresh</span>
          </button>
          <span className="px-3 py-1.5 rounded-xl bg-blue-100 text-blue-900 text-xs font-bold border border-blue-200 whitespace-nowrap">
            {orders.length} Total Orders
          </span>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
        {['all', 'pending', 'processing', 'shipped', 'delivered'].map((st) => (
          <button
            key={st}
            onClick={() => setStatusFilter(st)}
            className={`px-3 py-1.5 sm:py-1 rounded-xl text-xs font-semibold uppercase tracking-wider transition-colors shrink-0 ${
              statusFilter === st
                ? 'bg-mandir-maroon text-amber-200'
                : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
            }`}
          >
            {st}
          </button>
        ))}
      </div>

      {/* Mobile Swipe Hint */}
      <div className="lg:hidden text-[11px] text-gray-400 px-1">
        👈 Swipe horizontally to view customer shipping addresses & status 👉
      </div>

      {/* Orders Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            <span className="text-3xl block mb-2 animate-spin">⏳</span>
            <span>Loading live store orders from database...</span>
          </div>
        ) : filtered.length === 0 ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            <span className="text-4xl block mb-2">📦</span>
            <p className="font-semibold text-gray-700">No orders recorded in database yet</p>
            <p className="mt-1 text-[11px]">
              Orders placed by devotees on the store will arrive here in real time.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs min-w-[700px]">
              <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                <tr>
                  <th className="py-3 px-4">Order ID</th>
                  <th className="py-3 px-4">Devotee Name</th>
                  <th className="py-3 px-4">Shipping Destination</th>
                  <th className="py-3 px-4">Amount</th>
                  <th className="py-3 px-4">Payment</th>
                  <th className="py-3 px-4">Fulfillment Status</th>
                  <th className="py-3 px-4 text-right">Update Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-gray-700">
                {filtered.map((o) => (
                  <tr key={o.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="py-3 px-4 font-mono font-semibold text-gray-900">
                      {o.id}
                    </td>
                    <td className="py-3 px-4">
                      <span className="font-semibold text-gray-900 block">{o.user_name}</span>
                      {o.user_phone && (
                        <span className="text-[10px] text-gray-500 font-mono">{o.user_phone}</span>
                      )}
                    </td>
                    <td className="py-3 px-4 text-gray-600 max-w-xs truncate">
                      {o.shipping_address || 'Not specified'}
                    </td>
                    <td className="py-3 px-4 font-bold font-cinzel text-gray-900">
                      ₹ {Number(o.total_amount || 0).toLocaleString('en-IN')}
                    </td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 text-[10px] font-semibold">
                        {o.payment_status || 'Verified'}
                      </span>
                    </td>
                    <td className="py-3 px-4">
                      <span
                        className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-semibold capitalize ${
                          o.order_status === 'Delivered'
                            ? 'bg-emerald-100 text-emerald-800'
                            : o.order_status === 'Shipped'
                            ? 'bg-blue-100 text-blue-800'
                            : 'bg-amber-100 text-amber-800'
                        }`}
                      >
                        {o.order_status || 'Processing'}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <select
                        value={o.order_status}
                        onChange={(e) => updateStatus(o.id, e.target.value)}
                        className="p-1 rounded border border-gray-200 text-xs font-semibold bg-white"
                      >
                        <option value="Processing">Processing</option>
                        <option value="Shipped">Shipped</option>
                        <option value="Delivered">Delivered</option>
                        <option value="Cancelled">Cancelled</option>
                      </select>
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
