'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

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
  const { isHindi } = useAdminLanguage();
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
      setBookings([]);
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
        showToast(
          isHindi
            ? `बुकिंग स्थिति "${newStatus}" में अपडेट हुई`
            : `Booking ${id} status updated to ${newStatus}`
        );
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
        showToast(
          isHindi
            ? `पंडित ${priestName} सफलतापूर्वक नियुक्त हुए`
            : `Assigned ${priestName} to booking`
        );
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
            <span>📜</span> {isHindi ? 'भक्त पूजा बुकिंग एवं पवित्र संकल्प' : 'Devotee Puja Bookings & Sacred Sankalps'}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5">
            {isHindi
              ? 'सुपाबेस डेटाबेस से सीधी लाइव कतार • गोत्र सत्यापन, वैदिक पंडित आवंटन एवं अनुष्ठान निगरानी'
              : 'Real-time Supabase records • Audit Gotras, assign Vedic priests, and supervise execution'}
          </p>
        </div>
        <div className="flex items-center justify-between sm:justify-end gap-2 w-full sm:w-auto">
          <button
            onClick={fetchBookings}
            disabled={loading}
            className="px-3 py-1.5 rounded-xl bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <span>{loading ? '⏳' : '🔄'}</span>
            <span>{isHindi ? 'रिफ्रेश' : 'Refresh'}</span>
          </button>
          <span className="px-3 py-1.5 rounded-xl bg-amber-100 text-amber-900 text-xs font-bold border border-amber-200 whitespace-nowrap">
            {bookings.length} {isHindi ? 'बुकिंग दर्ज' : 'Bookings'}
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
            placeholder={isHindi ? 'भक्त का नाम, गोत्र, पूजा या ID से खोजें...' : 'Search devotee, Gotra, puja, or ID...'}
            className="w-full pl-8 pr-3 py-2 sm:py-1.5 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        {/* Status Filter */}
        <div className="flex items-center gap-1.5 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0 scrollbar-none">
          {[
            { key: 'all', labelEn: 'All', labelHi: 'सभी' },
            { key: 'confirmed', labelEn: 'Confirmed', labelHi: 'स्वीकृत' },
            { key: 'in progress', labelEn: 'In Progress', labelHi: 'प्रगति पर' },
            { key: 'completed', labelEn: 'Completed', labelHi: 'पूर्ण' },
          ].map((st) => (
            <button
              key={st.key}
              onClick={() => setFilterStatus(st.key)}
              className={`px-3 py-1.5 sm:py-1 rounded-lg text-xs font-semibold uppercase tracking-wider transition-colors shrink-0 ${
                filterStatus === st.key
                  ? 'bg-mandir-maroon text-amber-200'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {isHindi ? st.labelHi : st.labelEn}
            </button>
          ))}
        </div>
      </div>

      {/* Bookings Table & Inspector */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          {loading ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-3xl block mb-2 animate-spin">⏳</span>
              {isHindi ? 'डेटाबेस से बुकिंग लोड हो रही है...' : 'Loading bookings from database...'}
            </div>
          ) : filtered.length === 0 ? (
            <div className="py-20 text-center text-gray-400 text-xs">
              <span className="text-3xl block mb-2">📜</span>
              {isHindi ? 'कोई बुकिंग नहीं मिली।' : 'No bookings found.'}
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-gray-600">
                <thead className="bg-gray-50/75 border-b border-gray-100 text-[11px] font-bold text-gray-500 uppercase tracking-wider">
                  <tr>
                    <th className="py-3 px-4">{isHindi ? 'बुकिंग ID' : 'Booking ID'}</th>
                    <th className="py-3 px-4">{isHindi ? 'भक्त / संकल्प' : 'Devotee / Sankalp'}</th>
                    <th className="py-3 px-4">{isHindi ? 'पूजा अनुष्ठान' : 'Puja Ceremony'}</th>
                    <th className="py-3 px-4">{isHindi ? 'दक्षिणा' : 'Amount'}</th>
                    <th className="py-3 px-4">{isHindi ? 'स्थिति' : 'Status'}</th>
                    <th className="py-3 px-4 text-right">{isHindi ? 'क्रिया' : 'Action'}</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {filtered.map((b) => (
                    <tr
                      key={b.id}
                      onClick={() => setSelectedBooking(b)}
                      className={`hover:bg-amber-50/20 cursor-pointer transition-colors ${
                        selectedBooking?.id === b.id ? 'bg-amber-50/50' : ''
                      }`}
                    >
                      <td className="py-3.5 px-4 font-mono font-bold text-gray-900 whitespace-nowrap">
                        {b.id.slice(-8).toUpperCase()}
                      </td>
                      <td className="py-3.5 px-4 whitespace-nowrap">
                        <div className="font-semibold text-gray-900">
                          {b.sankalp_name || b.user_name || (isHindi ? 'अनाम भक्त' : 'Devotee')}
                        </div>
                        {b.sankalp_gotra && (
                          <div className="text-[10px] text-amber-800 bg-amber-50 px-1.5 py-0.2 rounded w-fit mt-0.5">
                            {isHindi ? 'गोत्र:' : 'Gotra:'} {b.sankalp_gotra}
                          </div>
                        )}
                      </td>
                      <td className="py-3.5 px-4 whitespace-nowrap">
                        <div className="font-medium text-gray-800">{b.puja_title}</div>
                        <div className="text-[11px] text-gray-400">{b.temple_name}</div>
                      </td>
                      <td className="py-3.5 px-4 font-bold text-mandir-maroon whitespace-nowrap">
                        ₹ {Number(b.amount || 0).toLocaleString('en-IN')}
                      </td>
                      <td className="py-3.5 px-4 whitespace-nowrap">
                        <span
                          className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
                            b.status?.toLowerCase() === 'completed'
                              ? 'bg-emerald-100 text-emerald-800'
                              : b.status?.toLowerCase() === 'in progress'
                              ? 'bg-blue-100 text-blue-800'
                              : 'bg-amber-100 text-amber-800'
                          }`}
                        >
                          {b.status || (isHindi ? 'स्वीकृत' : 'Confirmed')}
                        </span>
                      </td>
                      <td className="py-3.5 px-4 text-right whitespace-nowrap">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedBooking(b);
                          }}
                          className="px-2.5 py-1 bg-gray-100 hover:bg-amber-100 text-gray-700 hover:text-amber-900 rounded-lg text-xs font-semibold transition-colors"
                        >
                          {isHindi ? 'विवरण' : 'Inspect'}
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {/* Selected Booking Inspector */}
        <div id="booking-inspector" className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 border-b border-gray-100 pb-2 flex items-center gap-2">
            <span>🔍</span> {isHindi ? 'संकल्प एवं अनुष्ठान विवरण' : 'Sankalp & Ritual Inspector'}
          </h2>

          {selectedBooking ? (
            <div className="space-y-4 text-xs">
              <div className="bg-amber-50/50 p-3 rounded-xl border border-amber-200/60 space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-500">{isHindi ? 'यजमान नाम:' : 'Yajman Name:'}</span>
                  <span className="font-bold text-gray-900">
                    {selectedBooking.sankalp_name || selectedBooking.user_name || (isHindi ? 'अनाम भक्त' : 'Devotee')}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">{isHindi ? 'वैदिक गोत्र:' : 'Gotra:'}</span>
                  <span className="font-bold text-amber-900">{selectedBooking.sankalp_gotra || '—'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">{isHindi ? 'राशि:' : 'Rashi:'}</span>
                  <span className="font-semibold text-gray-700">{selectedBooking.sankalp_rashi || '—'}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">{isHindi ? 'फ़ोन नंबर:' : 'Phone:'}</span>
                  <span className="font-semibold text-gray-700">{selectedBooking.user_phone || '—'}</span>
                </div>
              </div>

              {selectedBooking.sankalp_wishes && (
                <div className="p-3 bg-gray-50 rounded-xl border border-gray-100">
                  <span className="font-bold text-gray-700 block mb-1">
                    {isHindi ? 'भक्त की विशेष प्रार्थना / मनोकामना:' : 'Devotee Wishes & Intentions:'}
                  </span>
                  <p className="text-gray-600 italic">"{selectedBooking.sankalp_wishes}"</p>
                </div>
              )}

              {/* Priest Assignment */}
              <div className="space-y-2 pt-2 border-t border-gray-100">
                <label className="block text-gray-700 font-bold">
                  {isHindi ? 'वैदिक पंडित नियुक्त करें:' : 'Assign Vedic Priest:'}
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={priestInput}
                    onChange={(e) => setPriestInput(e.target.value)}
                    placeholder={selectedBooking.priest_assigned || (isHindi ? 'पं. शास्त्री जी...' : 'Pt. Shastri...')}
                    className="flex-1 p-2 bg-gray-50 border border-gray-200 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
                  />
                  <button
                    onClick={() => assignPriest(selectedBooking.id, priestInput)}
                    className="px-3 py-2 bg-mandir-maroon text-white font-bold rounded-xl text-xs hover:bg-mandir-maroon-dark transition-all"
                  >
                    {isHindi ? 'सौंपें' : 'Assign'}
                  </button>
                </div>
              </div>

              {/* Status Update Actions */}
              <div className="pt-2 border-t border-gray-100 space-y-2">
                <span className="font-bold text-gray-700 block">{isHindi ? 'अनुष्ठान स्थिति बदलें:' : 'Update Status:'}</span>
                <div className="grid grid-cols-3 gap-2">
                  <button
                    onClick={() => updateStatus(selectedBooking.id, 'Confirmed')}
                    className="p-2 text-[11px] font-bold rounded-xl border border-amber-300 bg-amber-50 text-amber-900 hover:bg-amber-100"
                  >
                    {isHindi ? 'स्वीकृत' : 'Confirmed'}
                  </button>
                  <button
                    onClick={() => updateStatus(selectedBooking.id, 'In Progress')}
                    className="p-2 text-[11px] font-bold rounded-xl border border-blue-300 bg-blue-50 text-blue-900 hover:bg-blue-100"
                  >
                    {isHindi ? 'प्रगति पर' : 'In Progress'}
                  </button>
                  <button
                    onClick={() => updateStatus(selectedBooking.id, 'Completed')}
                    className="p-2 text-[11px] font-bold rounded-xl border border-emerald-300 bg-emerald-50 text-emerald-900 hover:bg-emerald-100"
                  >
                    {isHindi ? 'पूर्ण' : 'Completed'}
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="py-12 text-center text-gray-400 text-xs">
              {isHindi ? 'विवरण देखने के लिए तालिका से किसी बुकिंग पर क्लिक करें।' : 'Select any booking from the left list to inspect details.'}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
