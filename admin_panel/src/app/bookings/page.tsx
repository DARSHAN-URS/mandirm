'use client';

import { useState } from 'react';

interface Booking {
  id: string;
  devotee_name: string;
  gotra: string;
  rashi: string;
  wishes: string;
  puja_title: string;
  temple_name: string;
  date: string;
  time_slot: string;
  dakshina: number;
  package_type: 'Regular' | 'VIP Sankalp';
  status: 'confirmed' | 'priest_assigned' | 'in_progress' | 'completed' | 'cancelled';
  assigned_priest?: string;
  live_stream_url?: string;
}

const SEED_BOOKINGS: Booking[] = [
  { id: 'BK-9801', devotee_name: 'Sunil Kumar Sharma', gotra: 'Kashyapa', rashi: 'Vrishabha (Taurus)', wishes: 'Good health for mother, obstacle removal in new business venture.', puja_title: 'Maha Mrityunjaya Jaap & Havan (54,000 Chants)', temple_name: 'Mahakaleshwar Jyotirlinga, Ujjain', date: '2026-10-11', time_slot: '06:30 AM - 08:30 AM', dakshina: 5100, package_type: 'VIP Sankalp', status: 'in_progress', assigned_priest: 'Pandit Someshwar Joshi', live_stream_url: 'https://mandirm.live/room/mahakal-sankalp-9801' },
  { id: 'BK-9799', devotee_name: 'Pooja Agarwal & Family', gotra: 'Garg', rashi: 'Kanya (Virgo)', wishes: 'Family peace, prosperous Griha Pravesh blessings.', puja_title: 'Kashi Vishwanath Rudrabhishek with Bilva Patra', temple_name: 'Kashi Vishwanath, Varanasi', date: '2026-10-11', time_slot: '08:00 AM - 09:00 AM', dakshina: 2100, package_type: 'Regular', status: 'priest_assigned', assigned_priest: 'Shastri Anand Mohan', live_stream_url: 'https://mandirm.live/room/kashi-9799' },
  { id: 'BK-9794', devotee_name: 'Rameshwar Iyer', gotra: 'Bharadwaja', rashi: 'Dhanu (Sagittarius)', wishes: 'Neutralize Rahu Mahadasha and health recovery.', puja_title: 'Navgrah Shanti Maha Puja with 9 Grains', temple_name: 'Kalahasti Temple, Andhra Pradesh', date: '2026-10-10', time_slot: '10:00 AM - 11:15 AM', dakshina: 3500, package_type: 'VIP Sankalp', status: 'completed', assigned_priest: 'Venkatesh Dikshitar' },
  { id: 'BK-9788', devotee_name: 'Ananya Deshmukh', gotra: 'Vashistha', rashi: 'Makar (Capricorn)', wishes: 'Success in civil services examinations.', puja_title: 'Siddhivinayak Sankat Nashan Ganesha Puja', temple_name: 'Siddhivinayak Temple, Mumbai', date: '2026-10-10', time_slot: '07:30 AM - 08:15 AM', dakshina: 1500, package_type: 'Regular', status: 'completed', assigned_priest: 'Guruji Prabhakar Kelkar' },
  { id: 'BK-9782', devotee_name: 'Vikramaditya Rathore', gotra: 'Gautam', rashi: 'Mesha (Aries)', wishes: 'Relief from ongoing ancestral Pitru Dosha.', puja_title: 'Kaal Sarp Dosh Nivaran Maha Puja', temple_name: 'Trimbakeshwar Shiva Temple, Nashik', date: '2026-10-12', time_slot: '09:00 AM - 10:30 AM', dakshina: 5500, package_type: 'VIP Sankalp', status: 'confirmed' },
];

export default function BookingsPage() {
  const [bookings, setBookings] = useState<Booking[]>(SEED_BOOKINGS);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [search, setSearch] = useState('');
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);

  const filtered = bookings.filter(b => {
    const matchSearch = b.devotee_name.toLowerCase().includes(search.toLowerCase()) ||
                        b.id.toLowerCase().includes(search.toLowerCase()) ||
                        b.puja_title.toLowerCase().includes(search.toLowerCase());
    const matchStatus = filterStatus === 'all' || b.status === filterStatus;
    return matchSearch && matchStatus;
  });

  const updateStatus = (id: string, newStatus: Booking['status']) => {
    setBookings(bookings.map(b => b.id === id ? { ...b, status: newStatus } : b));
    if (selectedBooking && selectedBooking.id === id) {
      setSelectedBooking({ ...selectedBooking, status: newStatus });
    }
  };

  const assignPriest = (id: string, priestName: string) => {
    setBookings(bookings.map(b => b.id === id ? { ...b, assigned_priest: priestName, status: 'priest_assigned' } : b));
    if (selectedBooking && selectedBooking.id === id) {
      setSelectedBooking({ ...selectedBooking, assigned_priest: priestName, status: 'priest_assigned' });
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
            <span>📜</span> Devotee Puja Bookings & Sacred Sankalps
          </h1>
          <p className="text-xs text-gray-500">
            Audit devotee Gotras, family intentions, assign Vedic priests, and manage live-stream broadcasts
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="px-3 py-1.5 rounded-xl bg-amber-100 text-amber-900 text-xs font-bold border border-amber-200">
            {bookings.filter(b => b.status === 'in_progress' || b.status === 'priest_assigned').length} Pending Execution
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
            placeholder="Search by Devotee, Gotra, or Booking ID..."
            className="w-full pl-8 pr-3 py-1.5 bg-gray-50 border border-gray-200 rounded-lg text-xs focus:outline-none focus:ring-1 focus:ring-mandir-maroon"
          />
        </div>

        {/* Status Tabs */}
        <div className="flex flex-wrap gap-1.5">
          {['all', 'confirmed', 'priest_assigned', 'in_progress', 'completed'].map(s => (
            <button
              key={s}
              onClick={() => setFilterStatus(s)}
              className={`px-3 py-1 rounded-lg text-xs font-semibold capitalize transition-all ${
                filterStatus === s
                  ? 'bg-mandir-maroon text-white shadow-sm'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {s.replace('_', ' ')}
            </button>
          ))}
        </div>
      </div>

      {/* Bookings Table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-gray-50 text-gray-400 font-semibold uppercase text-[10px] tracking-wider border-b border-gray-100">
              <tr>
                <th className="py-3 px-4">Booking ID</th>
                <th className="py-3 px-4">Devotee & Sankalp Gotra</th>
                <th className="py-3 px-4">Puja Ceremony & Temple</th>
                <th className="py-3 px-4">Schedule</th>
                <th className="py-3 px-4">Assigned Priest</th>
                <th className="py-3 px-4">Dakshina</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {filtered.map(b => (
                <tr key={b.id} className="hover:bg-amber-50/20 transition-colors">
                  <td className="py-3.5 px-4 font-mono font-semibold text-gray-800">{b.id}</td>
                  <td className="py-3.5 px-4">
                    <div className="font-bold text-gray-900">{b.devotee_name}</div>
                    <div className="text-[11px] text-amber-800 font-medium">Gotra: {b.gotra} • {b.rashi}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    <div className="font-semibold text-gray-900 max-w-xs truncate">{b.puja_title}</div>
                    <div className="text-[10px] text-gray-500">{b.temple_name}</div>
                  </td>
                  <td className="py-3.5 px-4 text-gray-600">
                    <div>{b.date}</div>
                    <div className="text-[10px] text-gray-400 font-medium">{b.time_slot}</div>
                  </td>
                  <td className="py-3.5 px-4">
                    {b.assigned_priest ? (
                      <span className="font-medium text-gray-800 flex items-center gap-1">
                        <span>🕉️</span> {b.assigned_priest}
                      </span>
                    ) : (
                      <span className="text-amber-700 italic text-[11px]">Pending Assignment</span>
                    )}
                  </td>
                  <td className="py-3.5 px-4 font-bold text-gray-900 font-mono">
                    ₹ {b.dakshina.toLocaleString('en-IN')}
                    <span className="block text-[9px] font-normal text-gray-400 uppercase">{b.package_type}</span>
                  </td>
                  <td className="py-3.5 px-4">
                    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold capitalize ${
                      b.status === 'in_progress' ? 'bg-amber-100 text-amber-800 animate-pulse' :
                      b.status === 'priest_assigned' ? 'bg-blue-100 text-blue-800' :
                      b.status === 'completed' ? 'bg-emerald-100 text-emerald-800' :
                      'bg-purple-100 text-purple-800'
                    }`}>
                      {b.status.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="py-3.5 px-4 text-right">
                    <button
                      onClick={() => setSelectedBooking(b)}
                      className="px-3 py-1 bg-mandir-maroon/10 hover:bg-mandir-maroon text-mandir-maroon hover:text-white font-semibold rounded-lg text-xs transition-colors"
                    >
                      Audit Sankalp
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Sankalp Audit Modal */}
      {selectedBooking && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-gray-200 space-y-4 text-xs">
            <div className="flex items-center justify-between pb-3 border-b border-gray-100">
              <div>
                <span className="text-[10px] font-mono font-bold text-gray-400">{selectedBooking.id}</span>
                <h2 className="text-base font-bold font-cinzel text-gray-900">Sankalp & Ritual Audit Sheet</h2>
              </div>
              <button
                onClick={() => setSelectedBooking(null)}
                className="text-gray-400 hover:text-gray-600 text-lg"
              >
                ✕
              </button>
            </div>

            <div className="p-3 bg-amber-50 rounded-xl border border-amber-200/60 space-y-2">
              <div className="flex justify-between">
                <span className="text-amber-800 font-bold uppercase text-[10px]">Devotee Primary Vow</span>
                <span className="text-amber-900 font-bold">{selectedBooking.devotee_name}</span>
              </div>
              <div className="grid grid-cols-2 gap-2 text-[11px]">
                <div>Gotra: <strong>{selectedBooking.gotra}</strong></div>
                <div>Rashi: <strong>{selectedBooking.rashi}</strong></div>
              </div>
              <div>
                <span className="text-amber-800 font-bold text-[10px] uppercase block">Special Sankalp Wishes</span>
                <p className="text-gray-800 italic mt-0.5">"{selectedBooking.wishes}"</p>
              </div>
            </div>

            <div className="space-y-2">
              <label className="block text-gray-700 font-bold">Assign Vedic Pandit</label>
              <div className="flex gap-2">
                <input
                  type="text"
                  defaultValue={selectedBooking.assigned_priest || ''}
                  id="priest_input"
                  placeholder="Enter Pandit name (e.g., Shastri Anand Mohan)"
                  className="flex-1 p-2 border border-gray-300 rounded-lg text-xs"
                />
                <button
                  onClick={() => {
                    const input = document.getElementById('priest_input') as HTMLInputElement;
                    if (input && input.value) assignPriest(selectedBooking.id, input.value);
                  }}
                  className="px-3 py-2 bg-mandir-maroon text-white font-bold rounded-lg text-xs"
                >
                  Assign
                </button>
              </div>
            </div>

            <div>
              <label className="block text-gray-700 font-bold mb-1">Ritual Execution Status</label>
              <div className="flex flex-wrap gap-2">
                {(['confirmed', 'priest_assigned', 'in_progress', 'completed'] as Booking['status'][]).map(st => (
                  <button
                    key={st}
                    onClick={() => updateStatus(selectedBooking.id, st)}
                    className={`px-3 py-1.5 rounded-lg text-xs font-bold capitalize transition-all ${
                      selectedBooking.status === st
                        ? 'bg-emerald-600 text-white shadow-md'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    {st.replace('_', ' ')}
                  </button>
                ))}
              </div>
            </div>

            <div className="pt-3 border-t border-gray-100 flex justify-end gap-2">
              <a
                href={`/certificates`}
                className="px-3 py-2 bg-amber-500 hover:bg-amber-400 text-mandir-maroon-deep font-bold rounded-lg text-xs"
              >
                Generate Sacred Certificate
              </a>
              <button
                onClick={() => setSelectedBooking(null)}
                className="px-4 py-2 bg-gray-200 text-gray-700 font-semibold rounded-lg text-xs"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
