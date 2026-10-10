'use client';

import { useState, useEffect, useCallback } from 'react';

// ─── Types ───────────────────────────────────────────────────────────────────
interface FAQ {
  id: string;
  question: string;
  answer: string;
  service_type: 'puja' | 'chadhawa' | 'general';
  service_id?: string;
  display_order: number;
  is_active: boolean;
  tags?: string;
  created_at: string;
  updated_at: string;
}

// ─── General FAQs seed data (copied from Sri Mandir style) ───────────────────
const GENERAL_FAQS_SEED: Omit<FAQ, 'id' | 'created_at' | 'updated_at'>[] = [
  // --- PUJA GENERAL FAQs ---
  {
    question: 'Do I need to be physically present at the temple for the puja?',
    answer: 'No, you do not need to be physically present. Our verified pandits will perform the puja on your behalf with your personalized Sankalp (your name, gotra, and wishes). You can watch it live via a private video link.',
    service_type: 'puja', display_order: 1, is_active: true, tags: 'presence,online,live',
  },
  {
    question: 'How will I receive the sacred Prasad?',
    answer: 'Consecrated Prasad — including Gangajal, dry fruits, Bhasma, and Kumkum — will be carefully packed and shipped to your registered address within 3–7 working days after the puja.',
    service_type: 'puja', display_order: 2, is_active: true, tags: 'prasad,delivery,shipping',
  },
  {
    question: 'What is Sankalp and why is it important?',
    answer: 'Sankalp is a sacred vow or intention that the priest recites on your behalf at the beginning of the ritual. It includes your name, Gotra (family lineage), and your wishes, ensuring the puja\'s benefits are specifically directed to you and your family.',
    service_type: 'puja', display_order: 3, is_active: true, tags: 'sankalp,gotra,ritual',
  },
  {
    question: 'Can I book a puja for someone else (gifting)?',
    answer: 'Yes, absolutely! You can book a puja as a gift for family members or loved ones. During booking, provide the beneficiary\'s name and Gotra in the Sankalp details.',
    service_type: 'puja', display_order: 4, is_active: true, tags: 'gift,family,booking',
  },
  {
    question: 'How do I get my payment refunded if I cancel?',
    answer: 'Cancellations made more than 48 hours before the scheduled puja are eligible for a full refund. Cancellations within 48 hours are eligible for 50% refund. Once the puja begins, no refund is possible. Contact support@mandiram.app for assistance.',
    service_type: 'puja', display_order: 5, is_active: true, tags: 'refund,cancellation,payment',
  },
  {
    question: 'Will I receive a certificate after the puja?',
    answer: 'Yes! After your puja is completed, you can download a personalized Sacred Participation Certificate from the "My Bookings" section of the Mandiram app. The certificate includes your name, the puja title, and the temple name.',
    service_type: 'puja', display_order: 6, is_active: true, tags: 'certificate,download,proof',
  },
  {
    question: 'Which pandits perform the puja? Are they qualified?',
    answer: 'All pujas are performed by Mandiram-verified Vedic pandits with a minimum of 10 years of experience. Each pandit is trained in traditional Vedic rituals and speaks Sanskrit fluently. Their credentials are verified by our spiritual advisory board.',
    service_type: 'puja', display_order: 7, is_active: true, tags: 'pandit,priest,verified',
  },
  {
    question: 'Can I watch the puja live?',
    answer: 'Yes! All pujas include a private live-stream link sent to your registered phone/email. For premium packages, you get a direct 1-on-1 video connection to the sanctum. The live link is shared 30 minutes before the puja starts.',
    service_type: 'puja', display_order: 8, is_active: true, tags: 'live,streaming,video',
  },
  {
    question: 'What if the puja is delayed due to temple timings?',
    answer: 'If the puja is delayed due to unforeseen temple circumstances (weather, festivals, power issues), you will be notified via SMS and in-app notification with the rescheduled time. No extra charges apply.',
    service_type: 'puja', display_order: 9, is_active: true, tags: 'delay,rescheduling,notification',
  },
  {
    question: 'Is GST included in the puja price?',
    answer: 'All prices displayed on Mandiram are inclusive of applicable GST. No hidden charges are added at checkout. The final amount shown is the total amount charged.',
    service_type: 'puja', display_order: 10, is_active: true, tags: 'gst,price,tax',
  },

  // --- CHADHAWA GENERAL FAQs ---
  {
    question: 'What is Chadava (Chadhawa)?',
    answer: 'Chadava (also called Chadhawa or Sewa) is the sacred act of offering specific items — flowers, fruits, sweets, silver articles, clothes, etc. — to a deity at a temple on your behalf. Each offering carries spiritual significance and is believed to invoke divine blessings.',
    service_type: 'chadhawa', display_order: 1, is_active: true, tags: 'definition,meaning,offering',
  },
  {
    question: 'How is the Chadava offered at the temple?',
    answer: 'Once you book a Chadava, our temple partner receives the order. On the specified auspicious day, a temple priest collects the offering items, performs a dedicated prayer (Sankalp with your name and Gotra), and places the offering at the deity\'s feet. A photo or video confirmation is sent to you.',
    service_type: 'chadhawa', display_order: 2, is_active: true, tags: 'process,how,offering',
  },
  {
    question: 'Will I get photo/video proof of my Chadava offering?',
    answer: 'Yes! For every Chadava, you will receive a photo or short video of your offering placed at the temple, along with a timestamp. This is sent to you via the Mandiram app within 24 hours of the offering being made.',
    service_type: 'chadhawa', display_order: 3, is_active: true, tags: 'proof,photo,video',
  },
  {
    question: 'Can I get a certificate for my Chadava offering?',
    answer: 'Yes, absolutely! After your Chadava is offered, you can download a personalized Chadava Certificate from "My Bookings" in the app. The certificate mentions your name, Gotra, the offering title, and the temple name — a beautiful keepsake of your devotion.',
    service_type: 'chadhawa', display_order: 4, is_active: true, tags: 'certificate,download,keepsake',
  },
  {
    question: 'Which temples are available for Chadava on Mandiram?',
    answer: 'Mandiram offers Chadava at over 50 famous temples across India, including Mahakaleshwar (Ujjain), Tirupati Balaji, Vaishno Devi, Siddhivinayak (Mumbai), Shirdi Sai Baba, Kashi Vishwanath (Varanasi), and many more. New temples are added regularly.',
    service_type: 'chadhawa', display_order: 5, is_active: true, tags: 'temples,list,india',
  },
  {
    question: 'What items are included in a typical Chadava?',
    answer: 'Depending on the Chadava package you select, items may include fresh flowers, Tulsi leaves, Bel Patra, Desi Ghee lamp, sweets (Laddoo, Pedha), dry fruits, silver coins, sacred cloth (Vastra), or Panchamrit. Exact items are listed on each Chadava detail page.',
    service_type: 'chadhawa', display_order: 6, is_active: true, tags: 'items,offerings,list',
  },
  {
    question: 'Is there a minimum amount for Chadava?',
    answer: 'Chadava offerings on Mandiram start from as low as ₹51. Each temple has its own pricing based on the type of offering and associated rituals. Premium packages include a larger variety of items and more elaborate rituals.',
    service_type: 'chadhawa', display_order: 7, is_active: true, tags: 'price,minimum,cost',
  },
  {
    question: 'Can I schedule a Chadava for a specific date or festival?',
    answer: 'Yes! You can select a specific auspicious date during booking, such as Ekadashi, Pradosh, Navratri, Mahashivratri, etc. We recommend booking at least 3–5 days in advance for specific date requests.',
    service_type: 'chadhawa', display_order: 8, is_active: true, tags: 'schedule,festival,date',
  },

  // --- GENERAL (Platform-wide) FAQs ---
  {
    question: 'Is Mandiram a trusted and verified platform?',
    answer: 'Yes. Mandiram is a registered spiritual services platform. All our partner temples, priests, and pandits are verified. We follow transparent pricing with no hidden charges. Our platform is used by over 5 lakh devotees across India.',
    service_type: 'general', display_order: 1, is_active: true, tags: 'trust,verified,platform',
  },
  {
    question: 'What payment methods are accepted?',
    answer: 'We accept all major payment methods: UPI (Google Pay, PhonePe, Paytm), Credit/Debit Cards (Visa, Mastercard, RuPay), Net Banking, and Wallets. All payments are secured by Razorpay with 256-bit SSL encryption.',
    service_type: 'general', display_order: 2, is_active: true, tags: 'payment,upi,card',
  },
  {
    question: 'How do I contact Mandiram customer support?',
    answer: 'You can reach our 24/7 support team via: \n• In-app Chat Support \n• WhatsApp: +91-XXXXX-XXXXX \n• Email: support@mandiram.app \n• Toll-free: 1800-XXX-XXXX (Mon–Sat, 9 AM–9 PM IST)',
    service_type: 'general', display_order: 3, is_active: true, tags: 'support,contact,help',
  },
];

// ─── Badge color helper ───────────────────────────────────────────────────────
const TYPE_COLORS: Record<string, string> = {
  puja: 'bg-orange-100 text-orange-800 border border-orange-200',
  chadhawa: 'bg-purple-100 text-purple-800 border border-purple-200',
  general: 'bg-blue-100 text-blue-800 border border-blue-200',
};

// ─── FAQ Form Modal ───────────────────────────────────────────────────────────
function FAQModal({
  faq,
  onClose,
  onSave,
}: {
  faq: Partial<FAQ> | null;
  onClose: () => void;
  onSave: (data: Partial<FAQ>) => void;
}) {
  const [form, setForm] = useState<Partial<FAQ>>(
    faq ?? {
      question: '',
      answer: '',
      service_type: 'puja',
      service_id: '',
      display_order: 0,
      is_active: true,
      tags: '',
    }
  );

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.question?.trim() || !form.answer?.trim()) return;
    onSave(form);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-100">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-orange-100 flex items-center justify-center text-xl">🙏</div>
            <div>
              <h2 className="text-lg font-bold text-gray-900">{faq?.id ? 'Edit FAQ' : 'Add New FAQ'}</h2>
              <p className="text-sm text-gray-500">Fill in the details for this FAQ</p>
            </div>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-lg bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-gray-600 transition-colors">✕</button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          {/* Service Type */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Service Type *</label>
            <div className="flex gap-3">
              {(['puja', 'chadhawa', 'general'] as const).map((type) => (
                <button
                  key={type}
                  type="button"
                  onClick={() => setForm((f) => ({ ...f, service_type: type }))}
                  className={`flex-1 py-2 px-3 rounded-xl border-2 text-sm font-semibold capitalize transition-all ${
                    form.service_type === type
                      ? 'border-orange-500 bg-orange-50 text-orange-700'
                      : 'border-gray-200 text-gray-600 hover:border-gray-300'
                  }`}
                >
                  {type === 'puja' ? '🪔 Puja' : type === 'chadhawa' ? '🌸 Chadhawa' : '📋 General'}
                </button>
              ))}
            </div>
          </div>

          {/* Question */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Question *</label>
            <input
              type="text"
              required
              value={form.question || ''}
              onChange={(e) => setForm((f) => ({ ...f, question: e.target.value }))}
              placeholder="e.g. Do I need to be present at the temple?"
              className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
            />
          </div>

          {/* Answer */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Answer *</label>
            <textarea
              required
              rows={5}
              value={form.answer || ''}
              onChange={(e) => setForm((f) => ({ ...f, answer: e.target.value }))}
              placeholder="Provide a clear, helpful answer..."
              className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm resize-none"
            />
          </div>

          {/* Service ID + Display Order */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">
                Service ID <span className="text-gray-400 font-normal">(optional)</span>
              </label>
              <input
                type="text"
                value={form.service_id || ''}
                onChange={(e) => setForm((f) => ({ ...f, service_id: e.target.value }))}
                placeholder="e.g. puja_abc123 (blank = global)"
                className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Display Order</label>
              <input
                type="number"
                min={0}
                value={form.display_order ?? 0}
                onChange={(e) => setForm((f) => ({ ...f, display_order: parseInt(e.target.value) || 0 }))}
                className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
              />
            </div>
          </div>

          {/* Tags */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">
              Tags <span className="text-gray-400 font-normal">(comma-separated)</span>
            </label>
            <input
              type="text"
              value={form.tags || ''}
              onChange={(e) => setForm((f) => ({ ...f, tags: e.target.value }))}
              placeholder="e.g. prasad,delivery,online"
              className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
            />
          </div>

          {/* Active Toggle */}
          <div className="flex items-center gap-3 p-4 bg-gray-50 rounded-xl">
            <input
              type="checkbox"
              id="is_active"
              checked={form.is_active ?? true}
              onChange={(e) => setForm((f) => ({ ...f, is_active: e.target.checked }))}
              className="w-5 h-5 accent-orange-600"
            />
            <label htmlFor="is_active" className="text-sm font-semibold text-gray-700 cursor-pointer">
              Active — visible to devotees in the app
            </label>
          </div>

          {/* Buttons */}
          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-3 px-6 border border-gray-200 rounded-xl text-gray-700 font-semibold hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex-1 py-3 px-6 bg-gradient-to-r from-orange-600 to-red-700 text-white rounded-xl font-semibold hover:opacity-90 transition-opacity shadow-md"
            >
              {faq?.id ? 'Update FAQ' : 'Create FAQ'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ─── Main FAQ Management Page ─────────────────────────────────────────────────
export default function FAQsPage() {
  const [faqs, setFaqs] = useState<FAQ[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<'all' | 'puja' | 'chadhawa' | 'general'>('all');
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editingFaq, setEditingFaq] = useState<Partial<FAQ> | null>(null);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [seedLoading, setSeedLoading] = useState(false);
  const [toast, setToast] = useState<{ msg: string; type: 'success' | 'error' } | null>(null);

  const API_BASE = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000';
  const ADMIN_TOKEN = typeof window !== 'undefined' ? localStorage.getItem('adminToken') || '' : '';

  const showToast = (msg: string, type: 'success' | 'error' = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3500);
  };

  const fetchFAQs = useCallback(async () => {
    setLoading(true);
    try {
      const url = filter === 'all'
        ? `${API_BASE}/api/v1/faqs?limit=200`
        : `${API_BASE}/api/v1/faqs?service_type=${filter}&limit=200`;
      const res = await fetch(url);
      const data = await res.json();
      setFaqs(data.data || []);
    } catch {
      // Use local seed data when backend is unavailable
      setFaqs(
        GENERAL_FAQS_SEED.map((f, i) => ({
          ...f,
          id: `local_${i}`,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })) as FAQ[]
      );
    } finally {
      setLoading(false);
    }
  }, [API_BASE, filter]);

  useEffect(() => {
    fetchFAQs();
  }, [fetchFAQs]);

  const handleSeed = async () => {
    setSeedLoading(true);
    try {
      const res = await fetch(`${API_BASE}/api/v1/faqs/bulk`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${ADMIN_TOKEN}` },
        body: JSON.stringify(GENERAL_FAQS_SEED),
      });
      if (res.ok) {
        showToast(`✅ ${GENERAL_FAQS_SEED.length} General FAQs seeded successfully!`);
        fetchFAQs();
      } else {
        showToast('Failed to seed FAQs', 'error');
      }
    } catch {
      showToast('Backend unavailable — FAQs shown from local data', 'error');
    } finally {
      setSeedLoading(false);
    }
  };

  const handleSave = async (data: Partial<FAQ>) => {
    try {
      const isEdit = !!data.id;
      const url = isEdit ? `${API_BASE}/api/v1/faqs/${data.id}` : `${API_BASE}/api/v1/faqs`;
      const res = await fetch(url, {
        method: isEdit ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${ADMIN_TOKEN}` },
        body: JSON.stringify(data),
      });
      if (res.ok) {
        showToast(isEdit ? '✅ FAQ updated successfully!' : '✅ FAQ created successfully!');
        setShowModal(false);
        setEditingFaq(null);
        fetchFAQs();
      } else {
        showToast('Failed to save FAQ', 'error');
      }
    } catch {
      showToast('Backend unavailable', 'error');
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this FAQ? This action cannot be undone.')) return;
    try {
      const res = await fetch(`${API_BASE}/api/v1/faqs/${id}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${ADMIN_TOKEN}` },
      });
      if (res.ok) {
        showToast('🗑️ FAQ deleted');
        fetchFAQs();
      }
    } catch {
      showToast('Backend unavailable', 'error');
    }
  };

  const filtered = faqs.filter((f) => {
    const matchesSearch =
      !search ||
      f.question.toLowerCase().includes(search.toLowerCase()) ||
      f.answer.toLowerCase().includes(search.toLowerCase()) ||
      (f.tags || '').toLowerCase().includes(search.toLowerCase());
    return matchesSearch;
  });

  const counts = {
    all: faqs.length,
    puja: faqs.filter((f) => f.service_type === 'puja').length,
    chadhawa: faqs.filter((f) => f.service_type === 'chadhawa').length,
    general: faqs.filter((f) => f.service_type === 'general').length,
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Toast */}
      {toast && (
        <div
          className={`fixed top-5 right-5 z-[100] px-5 py-3 rounded-xl shadow-xl text-sm font-semibold transition-all ${
            toast.type === 'success' ? 'bg-green-600 text-white' : 'bg-red-600 text-white'
          }`}
        >
          {toast.msg}
        </div>
      )}

      <div className="max-w-6xl mx-auto px-6 py-8">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
              <span className="text-3xl">🙏</span> FAQ Management
            </h1>
            <p className="text-gray-500 mt-1">Manage FAQs for Puja, Chadhawa & General enquiries</p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={handleSeed}
              disabled={seedLoading}
              className="px-4 py-2.5 border border-orange-300 bg-orange-50 text-orange-700 rounded-xl text-sm font-semibold hover:bg-orange-100 transition-colors disabled:opacity-50 flex items-center gap-2"
            >
              {seedLoading ? '⏳ Seeding...' : '🌱 Seed General FAQs'}
            </button>
            <button
              onClick={() => { setEditingFaq(null); setShowModal(true); }}
              className="px-5 py-2.5 bg-gradient-to-r from-orange-600 to-red-700 text-white rounded-xl text-sm font-semibold hover:opacity-90 transition-opacity shadow-md flex items-center gap-2"
            >
              <span className="text-lg">+</span> Add FAQ
            </button>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-7">
          {(['all', 'puja', 'chadhawa', 'general'] as const).map((t) => (
            <button
              key={t}
              onClick={() => setFilter(t)}
              className={`p-4 rounded-2xl border-2 transition-all text-left ${
                filter === t
                  ? 'border-orange-500 bg-orange-50 shadow-sm'
                  : 'border-gray-200 bg-white hover:border-gray-300'
              }`}
            >
              <div className="text-2xl font-bold text-gray-900">{counts[t]}</div>
              <div className={`text-xs font-semibold mt-0.5 capitalize ${filter === t ? 'text-orange-700' : 'text-gray-500'}`}>
                {t === 'all' ? 'All FAQs' : t === 'puja' ? '🪔 Puja FAQs' : t === 'chadhawa' ? '🌸 Chadhawa FAQs' : '📋 General FAQs'}
              </div>
            </button>
          ))}
        </div>

        {/* Search bar */}
        <div className="relative mb-6">
          <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 text-lg">🔍</span>
          <input
            type="text"
            placeholder="Search FAQs by question, answer or tags..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-12 pr-4 py-3 bg-white border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm shadow-sm"
          />
        </div>

        {/* FAQ List */}
        {loading ? (
          <div className="flex items-center justify-center py-24">
            <div className="w-10 h-10 border-4 border-orange-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="text-center py-24">
            <div className="text-6xl mb-4">🔍</div>
            <h3 className="text-xl font-bold text-gray-700 mb-2">No FAQs found</h3>
            <p className="text-gray-500 mb-6">
              {faqs.length === 0
                ? 'Start by seeding the general FAQs or create a new one'
                : 'Try adjusting your search or filter'}
            </p>
            {faqs.length === 0 && (
              <button
                onClick={handleSeed}
                className="px-6 py-3 bg-orange-600 text-white rounded-xl font-semibold hover:bg-orange-700"
              >
                🌱 Seed General FAQs Now
              </button>
            )}
          </div>
        ) : (
          <div className="space-y-3">
            {filtered.map((faq) => (
              <div
                key={faq.id}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow"
              >
                <div
                  className="flex items-start gap-4 p-5 cursor-pointer"
                  onClick={() => setExpandedId(expandedId === faq.id ? null : faq.id)}
                >
                  {/* Order badge */}
                  <div className="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center text-xs font-bold text-gray-600 shrink-0 mt-0.5">
                    {faq.display_order || '—'}
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex flex-wrap items-center gap-2 mb-1.5">
                      <span className={`px-2 py-0.5 rounded-lg text-xs font-semibold capitalize ${TYPE_COLORS[faq.service_type] || 'bg-gray-100 text-gray-600'}`}>
                        {faq.service_type === 'puja' ? '🪔 Puja' : faq.service_type === 'chadhawa' ? '🌸 Chadhawa' : '📋 General'}
                      </span>
                      {faq.service_id && (
                        <span className="px-2 py-0.5 rounded-lg text-xs font-mono bg-gray-100 text-gray-600">
                          {faq.service_id}
                        </span>
                      )}
                      {!faq.is_active && (
                        <span className="px-2 py-0.5 rounded-lg text-xs font-semibold bg-red-100 text-red-700">
                          Inactive
                        </span>
                      )}
                    </div>
                    <p className="text-sm font-semibold text-gray-900 leading-snug">{faq.question}</p>
                    {faq.tags && (
                      <div className="flex flex-wrap gap-1 mt-2">
                        {faq.tags.split(',').map((t) => (
                          <span key={t} className="px-2 py-0.5 rounded-full bg-gray-100 text-xs text-gray-500">
                            #{t.trim()}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      onClick={(e) => { e.stopPropagation(); setEditingFaq(faq); setShowModal(true); }}
                      className="w-8 h-8 rounded-lg bg-blue-50 hover:bg-blue-100 flex items-center justify-center text-blue-600 transition-colors"
                      title="Edit"
                    >
                      ✏️
                    </button>
                    <button
                      onClick={(e) => { e.stopPropagation(); handleDelete(faq.id); }}
                      className="w-8 h-8 rounded-lg bg-red-50 hover:bg-red-100 flex items-center justify-center text-red-600 transition-colors"
                      title="Delete"
                    >
                      🗑️
                    </button>
                    <span className="text-gray-400 text-lg transition-transform duration-200" style={{ transform: expandedId === faq.id ? 'rotate(180deg)' : 'rotate(0deg)' }}>
                      ▾
                    </span>
                  </div>
                </div>

                {/* Expanded answer */}
                {expandedId === faq.id && (
                  <div className="px-5 pb-5 border-t border-gray-50 pt-4">
                    <p className="text-sm text-gray-600 leading-relaxed whitespace-pre-line">{faq.answer}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal */}
      {showModal && (
        <FAQModal
          faq={editingFaq}
          onClose={() => { setShowModal(false); setEditingFaq(null); }}
          onSave={handleSave}
        />
      )}
    </div>
  );
}
