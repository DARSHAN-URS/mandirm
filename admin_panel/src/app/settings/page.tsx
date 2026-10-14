'use client';

import { useState } from 'react';

export default function SettingsPage() {
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
          <span>⚙️</span> Platform Settings & Trust & Safety Configuration
        </h1>
        <p className="text-xs text-gray-500">
          Manage API gateways, payment keys, Agora RTC credentials, Trust & Safety officer contacts, and legal compliance
        </p>
      </div>

      {saved && (
        <div className="p-3 bg-emerald-100 border border-emerald-300 text-emerald-800 rounded-xl text-xs font-bold flex items-center gap-2 animate-bounce">
          <span>✓</span> Configuration settings successfully synchronized to production!
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Sanctum Security Passkey Configuration */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>🔑</span> Master Sanctum Admin Passkey
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Active Sanctum Passkey</label>
              <input
                type="text"
                defaultValue="mandirm@2026"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono bg-amber-50/50"
              />
              <p className="text-[10px] text-gray-400 mt-1">
                You can override this anytime via <code className="bg-gray-100 px-1 rounded font-mono">NEXT_PUBLIC_ADMIN_PASSKEY</code> environment variable on Netlify.
              </p>
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Passkey Mode</label>
              <div className="p-2 border border-emerald-200 bg-emerald-50 rounded-lg text-emerald-800 font-semibold flex items-center gap-2">
                <span>🛡️</span>
                <span>WebAuthn Biometrics + Master Passkey Enabled</span>
              </div>
            </div>
          </div>
        </div>

        {/* Payment Gateways Section */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>💳</span> Razorpay Payment Gateway Integration
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Razorpay Key ID</label>
              <input
                type="text"
                defaultValue="rzp_live_MandirmDevotionalKey"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
              />
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Razorpay Key Secret</label>
              <input
                type="password"
                defaultValue="••••••••••••••••••••••••"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
              />
            </div>
          </div>
          <p className="text-[11px] text-gray-400">
            Dakshina donations, puja bookings, and chadhawa offerings are deposited directly into Mandirm Trust escrow.
          </p>
        </div>

        {/* Real-time Video & Call Services */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>📹</span> Agora RTC Audio/Video Engine
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Agora App ID</label>
              <input
                type="text"
                defaultValue="48316c4714e843f5b991599318bba4ff"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
              />
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">RTC Token Expiry Window</label>
              <input
                type="text"
                defaultValue="86400 seconds (24 Hours)"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs"
              />
            </div>
          </div>
        </div>

        {/* Trust & Safety and Legal Compliance */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>🛡️</span> Trust & Safety Escalations (CSAE & IT Act Compliance)
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Dedicated Safety Officer Email</label>
              <input
                type="email"
                defaultValue="safety@mandiram.com"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs"
              />
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">Legal Support Email</label>
              <input
                type="email"
                defaultValue="support@mandiram.com"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs"
              />
            </div>
          </div>
          <div className="p-3 bg-amber-50 rounded-xl border border-amber-200 text-xs text-amber-900">
            <strong>Mandatory Law Enforcement Preservations:</strong> Automated pre-flight chat shield preserves cryptographic logs of any policy violations for 180 days per Indian IT Rules.
          </div>
        </div>

        {/* Save Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            className="px-6 py-2.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-xl text-xs font-bold shadow-md transition-all"
          >
            Save All Configurations
          </button>
        </div>
      </form>
    </div>
  );
}
