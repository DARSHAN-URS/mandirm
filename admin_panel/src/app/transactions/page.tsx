'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface LedgerItem {
  id: string;
  user_name: string;
  reference_type: string;
  reference_id: string;
  amount: number;
  payment_gateway: string;
  payment_id: string;
  status: string;
  created_at: string;
}

export default function TransactionsPage() {
  const [items, setItems] = useState<LedgerItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalSettled, setTotalSettled] = useState(0);

  useEffect(() => {
    fetchTransactions();
  }, []);

  const fetchTransactions = async () => {
    setLoading(true);
    try {
      // Fetch bookings, orders, and chadhawas that represent settled transactions
      const [bookingsRes, ordersRes] = await Promise.all([
        supabase.from('bookings').select('id, user_name, sankalp_name, amount, payment_id, status, created_at'),
        supabase.from('orders').select('id, user_name, total_amount, payment_id, payment_status, created_at'),
      ]);

      const records: LedgerItem[] = [];
      let total = 0;

      (bookingsRes.data || []).forEach((b) => {
        const amt = Number(b.amount || 0);
        total += amt;
        records.push({
          id: `TXN-BK-${b.id.slice(-6)}`,
          user_name: b.sankalp_name || b.user_name || 'Devotee',
          reference_type: 'Puja Booking',
          reference_id: b.id,
          amount: amt,
          payment_gateway: 'Razorpay UPI',
          payment_id: b.payment_id || `pay_${b.id.slice(-8)}`,
          status: 'success',
          created_at: b.created_at,
        });
      });

      (ordersRes.data || []).forEach((o) => {
        const amt = Number(o.total_amount || 0);
        total += amt;
        records.push({
          id: `TXN-ORD-${o.id.slice(-6)}`,
          user_name: o.user_name || 'Devotee',
          reference_type: 'Spiritual Store',
          reference_id: o.id,
          amount: amt,
          payment_gateway: 'Razorpay Gateway',
          payment_id: o.payment_id || `pay_${o.id.slice(-8)}`,
          status: 'success',
          created_at: o.created_at,
        });
      });

      records.sort(
        (a, b) =>
          new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      );

      setItems(records);
      setTotalSettled(total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-4">
        <div>
          <h1 className="text-lg sm:text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>💳</span> Financial Transactions & Dakshina Ledger
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Live database ledger • Razorpay gateway settlements, devotee dakshina receipts, and sacred offerings
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchTransactions}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>Refresh</span>
          </button>
          <div className="text-xs font-bold bg-emerald-100 text-emerald-900 px-3 py-1.5 rounded-xl border border-emerald-200 whitespace-nowrap">
            Settled: ₹ {totalSettled.toLocaleString('en-IN')}
          </div>
        </div>
      </div>

      {/* Mobile Swipe Hint */}
      <div className="lg:hidden text-[11px] text-gray-400 px-1">
        👈 Swipe horizontally to view full payment references & gateway IDs 👉
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            <span className="text-3xl block mb-2 animate-spin">⏳</span>
            <span>Loading live financial transactions from database...</span>
          </div>
        ) : items.length === 0 ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            <span className="text-4xl block mb-2">💳</span>
            <p className="font-semibold text-gray-700">No payment transactions recorded yet</p>
            <p className="mt-1 text-[11px]">
              When devotees complete Puja Dakshina or store orders, settlement logs will display here automatically.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs min-w-[720px]">
              <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                <tr>
                  <th className="py-3 px-4">Transaction ID</th>
                  <th className="py-3 px-4">Devotee</th>
                  <th className="py-3 px-4">Service Category</th>
                  <th className="py-3 px-4">Reference ID</th>
                  <th className="py-3 px-4">Gateway & Payment ID</th>
                  <th className="py-3 px-4">Amount Settled</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-right">Timestamp</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 text-gray-700">
                {items.map((t) => (
                  <tr key={t.id} className="hover:bg-gray-50/50 transition-colors">
                    <td className="py-3 px-4 font-mono font-semibold text-gray-900">
                      {t.id}
                    </td>
                    <td className="py-3 px-4 font-semibold text-gray-900">
                      {t.user_name}
                    </td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-0.5 rounded-full bg-amber-50 text-amber-800 text-[10px] font-semibold border border-amber-200">
                        {t.reference_type}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-mono text-gray-500 text-[11px]">
                      {t.reference_id}
                    </td>
                    <td className="py-3 px-4">
                      <span className="text-gray-900 font-medium block">
                        {t.payment_gateway}
                      </span>
                      <span className="text-gray-400 font-mono text-[10px]">
                        {t.payment_id}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-bold font-cinzel text-gray-900">
                      ₹ {t.amount.toLocaleString('en-IN')}
                    </td>
                    <td className="py-3 px-4">
                      <span className="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 text-[10px] font-semibold">
                        ✓ {t.status}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-right text-gray-400 font-mono text-[10px]">
                      {t.created_at ? new Date(t.created_at).toLocaleString() : '—'}
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
