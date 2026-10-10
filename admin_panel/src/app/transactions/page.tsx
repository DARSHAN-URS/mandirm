'use client';

import { useState } from 'react';

interface Transaction {
  id: string;
  user_name: string;
  reference_type: 'puja' | 'chadhawa' | 'consultation' | 'store';
  reference_id: string;
  amount: number;
  payment_gateway: string;
  razorpay_payment_id: string;
  status: 'success' | 'refunded' | 'failed';
  date: string;
}

const SEED_TXNS: Transaction[] = [
  { id: 'TXN-901', user_name: 'Sunil Kumar Sharma', reference_type: 'puja', reference_id: 'BK-9801', amount: 5100, payment_gateway: 'Razorpay UPI', razorpay_payment_id: 'pay_Pq1029188x', status: 'success', date: '2026-10-11 06:15' },
  { id: 'TXN-900', user_name: 'Pooja Agarwal', reference_type: 'puja', reference_id: 'BK-9799', amount: 2100, payment_gateway: 'Razorpay NetBanking', razorpay_payment_id: 'pay_Pq1027110y', status: 'success', date: '2026-10-11 07:45' },
  { id: 'TXN-898', user_name: 'Gaurav Khandelwal', reference_type: 'chadhawa', reference_id: 'CH-201', amount: 2100, payment_gateway: 'Razorpay Card', razorpay_payment_id: 'pay_Pq0981123z', status: 'success', date: '2026-10-11 08:30' },
  { id: 'TXN-895', user_name: 'Aditya Verma', reference_type: 'consultation', reference_id: 'CONS-402', amount: 350, payment_gateway: 'Mandirm Wallet', razorpay_payment_id: 'wlt_debit_0041', status: 'success', date: '2026-10-11 11:15' },
  { id: 'TXN-892', user_name: 'Mehul Trivedi', reference_type: 'store', reference_id: 'ORD-8910', amount: 2100, payment_gateway: 'Razorpay UPI', razorpay_payment_id: 'pay_Pq0871144w', status: 'success', date: '2026-10-11 09:20' },
];

export default function TransactionsPage() {
  const [txns, setTxns] = useState<Transaction[]>(SEED_TXNS);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>💳</span> Financial Transactions & Dakshina Ledger
          </h1>
          <p className="text-xs text-gray-500">
            Real-time Razorpay payment gateway settlement records, devotee dakshina receipts, and wallet transactions
          </p>
        </div>
        <div className="text-xs font-bold bg-emerald-100 text-emerald-900 px-3 py-1.5 rounded-xl border border-emerald-200">
          Total Settled Volume: ₹ 8,42,650
        </div>
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">Transaction ID</th>
                <th className="py-3 px-4">Devotee</th>
                <th className="py-3 px-4">Service Category</th>
                <th className="py-3 px-4">Reference ID</th>
                <th className="py-3 px-4">Gateway & Payment Ref</th>
                <th className="py-3 px-4">Amount Settled</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4 text-right">Timestamp</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {txns.map(t => (
                <tr key={t.id} className="hover:bg-emerald-50/20 transition-colors">
                  <td className="py-3.5 px-4 font-mono font-bold text-gray-800">{t.id}</td>
                  <td className="py-3.5 px-4 font-bold text-gray-900">{t.user_name}</td>
                  <td className="py-3.5 px-4">
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold capitalize bg-gray-100 text-gray-800">
                      {t.reference_type}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 font-mono text-gray-600">{t.reference_id}</td>
                  <td className="py-3.5 px-4">
                    <div className="text-gray-800 font-medium">{t.payment_gateway}</div>
                    <div className="text-[10px] text-gray-400 font-mono">{t.razorpay_payment_id}</div>
                  </td>
                  <td className="py-3.5 px-4 font-bold text-emerald-700 font-mono text-sm">
                    ₹ {t.amount.toLocaleString('en-IN')}
                  </td>
                  <td className="py-3.5 px-4">
                    <span className="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800 uppercase">
                      {t.status}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-right font-mono text-gray-500">{t.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
