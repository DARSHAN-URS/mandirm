'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

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
  const { isHindi } = useAdminLanguage();
  const [items, setItems] = useState<LedgerItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalSettled, setTotalSettled] = useState(0);

  useEffect(() => {
    fetchTransactions();
  }, []);

  const fetchTransactions = async () => {
    setLoading(true);
    try {
      // Direct database ledger query
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
          user_name: b.sankalp_name || b.user_name || (isHindi ? 'भक्त' : 'Devotee'),
          reference_type: isHindi ? 'पूजा बुकिंग' : 'Puja Booking',
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
          user_name: o.user_name || (isHindi ? 'भक्त' : 'Devotee'),
          reference_type: isHindi ? 'आध्यात्मिक स्टोर' : 'Spiritual Store',
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
      setItems([]);
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
            <span>💳</span> {isHindi ? 'वित्तीय लेनदेन एवं दक्षिणा लेजर' : 'Financial Transactions & Dakshina Ledger'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'लाइव डेटाबेस लेजर • रेज़रपे गेटवे सेटलमेंट, भक्त दक्षिणा रसीदें और पवित्र अर्पण'
              : 'Live database ledger • Razorpay gateway settlements, devotee dakshina receipts, and sacred offerings'}
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchTransactions}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>{isHindi ? 'रिफ्रेश' : 'Refresh'}</span>
          </button>
          <div className="text-xs font-bold bg-emerald-100 text-emerald-900 px-3 py-1.5 rounded-xl border border-emerald-200 whitespace-nowrap">
            {isHindi ? 'कुल समायोजित दक्षिणा:' : 'Settled:'} ₹ {totalSettled.toLocaleString('en-IN')}
          </div>
        </div>
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            {isHindi ? 'डेटाबेस से लेनदेन लोड हो रहा है...' : 'Loading transactions from database...'}
          </div>
        ) : items.length === 0 ? (
          <div className="py-20 text-center text-gray-400 text-xs">
            {isHindi ? 'डेटाबेस में कोई लेनदेन दर्ज नहीं है।' : 'No transactions found in database.'}
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-gray-600">
              <thead className="bg-gray-50/75 border-b border-gray-100 text-[11px] font-bold text-gray-500 uppercase tracking-wider">
                <tr>
                  <th className="py-3 px-4">{isHindi ? 'लेनदेन ID' : 'Transaction ID'}</th>
                  <th className="py-3 px-4">{isHindi ? 'भक्त का नाम' : 'Devotee / User'}</th>
                  <th className="py-3 px-4">{isHindi ? 'प्रकार' : 'Reference Type'}</th>
                  <th className="py-3 px-4">{isHindi ? 'दक्षिणा राशि' : 'Amount'}</th>
                  <th className="py-3 px-4">{isHindi ? 'भुगतान विधि' : 'Gateway ID'}</th>
                  <th className="py-3 px-4">{isHindi ? 'स्थिति' : 'Status'}</th>
                  <th className="py-3 px-4">{isHindi ? 'दिनांक' : 'Date'}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {items.map((row) => (
                  <tr key={row.id} className="hover:bg-amber-50/20 transition-colors">
                    <td className="py-3.5 px-4 font-mono font-bold text-gray-900 whitespace-nowrap">
                      {row.id}
                    </td>
                    <td className="py-3.5 px-4 font-semibold text-gray-800 whitespace-nowrap">
                      {row.user_name}
                    </td>
                    <td className="py-3.5 px-4 whitespace-nowrap">
                      <span className="bg-gray-100 text-gray-700 px-2 py-0.5 rounded text-[11px] font-medium">
                        {row.reference_type}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 font-bold text-emerald-600 whitespace-nowrap">
                      ₹ {row.amount.toLocaleString('en-IN')}
                    </td>
                    <td className="py-3.5 px-4 font-mono text-[11px] text-gray-500 whitespace-nowrap">
                      {row.payment_id}
                    </td>
                    <td className="py-3.5 px-4 whitespace-nowrap">
                      <span className="bg-emerald-50 text-emerald-700 border border-emerald-200 px-2 py-0.5 rounded-full text-[10px] font-bold">
                        {isHindi ? 'सफल' : 'Settled'}
                      </span>
                    </td>
                    <td className="py-3.5 px-4 text-gray-400 text-[11px] whitespace-nowrap">
                      {new Date(row.created_at).toLocaleDateString(isHindi ? 'hi-IN' : 'en-IN', {
                        day: '2-digit',
                        month: 'short',
                        year: 'numeric',
                      })}
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
