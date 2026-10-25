'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface Booking {
  id: string;
  user_id?: string;
  user_name?: string;
  user_phone?: string;
  sankalp_name: string;
  sankalp_gotra?: string;
  sankalp_rashi?: string;
  sankalp_wishes?: string;
  puja_id?: string;
  puja_title: string;
  temple_id?: string;
  temple_name: string;
  booking_date?: string;
  amount: number;
  package_type?: string;
  status: string;
  priest_assigned?: string;
  live_stream_url?: string;
  created_at: string;
}

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [search, setSearch] = useState('');
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const [priestInput, setPriestInput] = useState('');

  useEffect(() => {
    fetchBookings();
  }, []);

  const showToast = (msg: string) => {
    setToast(msg);
    setTimeout(() => setToast(null), 3500);
  };

  const fetchBookings = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching bookings:', error);
      } else {
        setBookings((data as Booking[]) || []);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const filtered = bookings.filter((b) => {
    const nameMatch =
      (b.sankalp_name || '').toLowerCase().includes(search.toLowerCase()) ||
      (b.user_name || '').toLowerCase().includes(search.toLowerCase()) ||
      (b.id || '').toLowerCase().includes(search.toLowerCase()) ||
      (b.puja_title || '').toLowerCase().includes(search.toLowerCase());
    const statusMatch =
      filterStatus === 'all' ||
      (b.status || '').toLowerCase() === filterStatus.toLowerCase();
    return nameMatch && statusMatch;
  });

  const updateStatus = async (id: string, newStatus: string) => {
    try {
      const { error } = await supabase
        .from('bookings')
        .update({ status: newStatus })
        .eq('id', id);

      if (error) {
        showToast(`Failed: ${error.message}`);
      } else {
        showToast(`Booking ${id} status updated to ${newStatus}`);
        setBookings(
          bookings.map((b) => (b.id === id ? { ...b, status: newStatus } : b))
        );
        if (selectedBooking && selectedBooking.id === id) {
          setSelectedBooking({ ...selectedBooking, status: newStatus });
        }
      }
    } catch (err: any) {
      showToast(`Error: ${err.message}`);
    }
  };

  const assignPriest = async (id: string, priestName: string) => {
    if (!priestName.trim()) return;
    try {
      const { error } = await supabase
        .from('bookings')
        .update({
          priest_assigned: priestName.trim(),
          status: 'In Progress',
        })
        .eq('id', id);

      if (error) {
        showToast(`Failed: ${error.message}`);
      } else {
        showToast(`Assigned ${priestName} to booking ${id}`);
        setBookings(
          bookings.map((b) =>
            b.id === id
              ? { ...b, priest_assigned: priestName.trim(), status: 'In Progress' }
              : b
          )
        );
        if (selectedBooking && selectedBooking.id === id) {
          setSelectedBooking({
            ...selectedBooking,
            priest_assigned: priestName.trim(),
            status: 'In Progress',
          });
        }
        setPriestInput('');
      }
    } catch (err: any) {
      showToast(`Error: ${err.message}`);
    }
  };

  return (
    <div className="space-y-6">
      {/* Toast Notification */}
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
            <span>📜</span> Devotee Puja Bookings & Sacred Sankalps
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            Real-time Supabase records • Audit Gotras, assign Vedic priests, and supervise execution
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchBookings}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>Refresh</span>
          </button>
          <span className="px-3 py-1.5 rounded-xl bg-amber-100 text-amber-900 text-xs font-bold border border-amber-200 whitespace-nowrap">
            {bookings.length} Bookings
          </span>
        </div>
      </div>

      {/* Filter Toolbar */}
      <div className="bg-white p-3.5 sm:p-4 rounded-xl border border-gray-200 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 shadow-sm">
        <div className="relative w-full sm:w-80">
          <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400 text-xs">
            🔍
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search devotee, Gotra, puja, or ID..."
            className="w-full pl-8 pr-3 py-2 sm:py-1.5 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        {/* Status Filter */}
        <div className="flex items-center gap-1.5 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
          {['all', 'confirmed', 'in progress', 'completed'].map((st) => (
            <button
              key={st}
              onClick={() => setFilterStatus(st)}
              className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors shrink-0 ${
                filterStatus === st
                  ? 'bg-mandir-maroon text-amber-200'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {st}
            </button>
          ))}
        </div>
      </div>

      {/* Mobile Swipe Hint */}
      <div className="lg:hidden flex items-center justify-between px-1 text-[11px] text-gray-400">
        <span>👈 Swipe horizontally to view full booking details 👉</span>
        {selectedBooking && (
          <a href="#booking-inspector" className="text-amber-800 font-semibold underline">
            Jump to Details ↓
          </a>
        )}
      </div>

      {/* Bookings Table & Inspector */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          {loading ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-3xl block mb-2 animate-spin">⏳</span>
              <span>Loading live bookings from database...</span>
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-4xl block mb-2">📜</span>
              <p className="font-semibold text-gray-600">No bookings found</p>
              <p className="mt-1 text-[11px]">
                Bookings made on the consumer website or mobile app will appear here in real time.
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs min-w-[650px]">
                <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
                  <tr>
                    <th className="py-3 px-4">Booking ID</th>
                    <th className="py-3 px-4">Devotee / Sankalp</th>
                    <th className="py-3 px-4">Puja Service</th>
                    <th className="py-3 px-4">Temple</th>
                    <th className="py-3 px-4">Dakshina</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4 text-right">Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-gray-700">
                  {filtered.map((b) => (
                    <tr
                      key={b.id}
                      onClick={() => {
                        setSelectedBooking(b);
                        if (typeof window !== 'undefined' && window.innerWidth < 1024) {
                          document.getElementById('booking-inspector')?.scrollIntoView({ behavior: 'smooth' });
                        }
                      }}
                      className={`hover:bg-amber-50/40 cursor-pointer transition-colors ${
                        selectedBooking?.id === b.id ? 'bg-amber-50/70' : ''
                      }`}
                    >
                      <td className="py-3 px-4 font-mono font-semibold text-gray-900">
                        {b.id}
                      </td>
                      <td className="py-3 px-4">
                        <span className="font-semibold text-gray-900 block">
                          {b.sankalp_name || b.user_name || 'Devotee'}
                        </span>
                        {b.sankalp_gotra && (
                          <span className="text-[10px] text-gray-500 font-mono">
                            Gotra: {b.sankalp_gotra}
                          </span>
                        )}
                      </td>
                      <td className="py-3 px-4 font-medium text-gray-800">
                        {b.puja_title}
                      </td>
                      <td className="py-3 px-4 text-gray-600">{b.temple_name}</td>
                      <td className="py-3 px-4 font-bold font-cinzel text-gray-900">
                        ₹ {Number(b.amount || 0).toLocaleString('en-IN')}
                      </td>
                      <td className="py-3 px-4">
                        <span
                          className={`inline-block px-2.5 py-0.5 rounded-full text-[10px] font-semibold capitalize ${
                            b.status === 'Completed' || b.status === 'completed'
                              ? 'bg-emerald-100 text-emerald-800'
                              : b.status === 'In Progress' || b.status === 'in progress'
                              ? 'bg-blue-100 text-blue-800'
                              : 'bg-amber-100 text-amber-800'
                          }`}
                        >
                          {b.status || 'Confirmed'}
                        </span>
                      </td>
                      <td className="py-3 px-4 text-right">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedBooking(b);
                            if (typeof window !== 'undefined' && window.innerWidth < 1024) {
                              document.getElementById('booking-inspector')?.scrollIntoView({ behavior: 'smooth' });
                            }
                          }}
                          className="px-2.5 py-1 rounded bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold text-[11px]"
                        >
                          Audit →
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Booking Inspector / Priest Assignment */}
        <div id="booking-inspector" className="bg-white rounded-2xl border border-gray-100 p-4 sm:p-5 shadow-sm space-y-4 scroll-mt-20">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 border-b border-gray-100 pb-2 flex items-center justify-between">
            <span className="flex items-center gap-1.5">
              <span>🔍</span> Sankalp Inspector
            </span>
            <div className="flex items-center gap-2">
              {selectedBooking && (
                <span className="font-mono text-xs font-normal text-amber-700">
                  {selectedBooking.id}
                </span>
              )}
              {selectedBooking && (
                <button
                  onClick={() => setSelectedBooking(null)}
                  className="lg:hidden text-gray-400 hover:text-gray-600 text-xs px-1.5 py-0.5 rounded"
                  title="Close Inspector"
                >
                  ✕
                </button>
              )}
            </div>
          </h2>

          {!selectedBooking ? (
            <div className="py-12 sm:py-20 text-center text-gray-400 text-xs">
              <span>Select any booking from the table to review Gotra details & assign priests.</span>
            </div>
          ) : (
            <div className="space-y-4 text-xs">
              <div className="p-3 bg-amber-50/60 rounded-xl border border-amber-200/50 space-y-1">
                <div className="font-bold text-gray-900 text-sm">
                  {selectedBooking.sankalp_name || selectedBooking.user_name || 'Devotee'}
                </div>
                <div className="text-gray-600 text-[11px]">
                  <strong>Gotra:</strong> {selectedBooking.sankalp_gotra || 'Not specified'} |{' '}
                  <strong>Rashi:</strong> {selectedBooking.sankalp_rashi || 'General'}
                </div>
                {selectedBooking.sankalp_wishes && (
                  <div className="pt-2 text-[11px] text-gray-700 italic border-t border-amber-200/40">
                    &ldquo;{selectedBooking.sankalp_wishes}&rdquo;
                  </div>
                )}
              </div>

              <div>
                <label className="block text-gray-500 font-semibold mb-1">Ritual Service</label>
                <div className="font-semibold text-gray-900">{selectedBooking.puja_title}</div>
                <div className="text-gray-500 text-[11px]">{selectedBooking.temple_name}</div>
              </div>

              {/* Status Update */}
              <div>
                <label className="block text-gray-500 font-semibold mb-1.5">Update Operational Status</label>
                <div className="flex flex-wrap gap-1.5">
                  {['Confirmed', 'In Progress', 'Completed'].map((st) => (
                    <button
                      key={st}
                      onClick={() => updateStatus(selectedBooking.id, st)}
                      className={`px-3 py-1 rounded-lg text-xs font-semibold ${
                        selectedBooking.status === st
                          ? 'bg-mandir-maroon text-amber-200'
                          : 'bg-gray-100 hover:bg-gray-200 text-gray-700'
                      }`}
                    >
                      {st}
                    </button>
                  ))}
                </div>
              </div>

              {/* Priest Assignment */}
              <div className="pt-2 border-t border-gray-100">
                <label className="block text-gray-500 font-semibold mb-1">Assigned Vedic Priest</label>
                <div className="text-gray-800 font-medium mb-2">
                  {selectedBooking.priest_assigned || 'None assigned yet'}
                </div>
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={priestInput}
                    onChange={(e) => setPriestInput(e.target.value)}
                    placeholder="Enter Pandit Name..."
                    className="flex-1 px-3 py-1.5 border border-gray-200 rounded-lg text-xs"
                  />
                  <button
                    onClick={() => assignPriest(selectedBooking.id, priestInput)}
                    className="px-3 py-1.5 bg-amber-500 hover:bg-amber-400 text-mandir-maroon font-bold rounded-lg text-xs"
                  >
                    Assign
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
