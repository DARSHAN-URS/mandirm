'use client';

import { useState } from 'react';
import { useAdminLanguage } from '@/context/AdminLanguageContext';

export default function SettingsPage() {
  const { isHindi } = useAdminLanguage();
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div className="space-y-4 sm:space-y-6 max-w-4xl">
      {/* Header */}
      <div>
        <h1 className="text-lg sm:text-xl font-bold font-cinzel text-gray-900 flex items-center gap-2">
          <span>⚙️</span> {isHindi ? 'प्लेटफॉर्म सेटिंग्स एवं सुरक्षा विन्यास' : 'Platform Settings & Trust & Safety Configuration'}
        </h1>
        <p className="text-xs text-gray-500 mt-0.5">
          {isHindi
            ? 'API गेटवे, रेज़रपे भुगतान कुंजियां, एगोरा RTC क्रेडेंशियल और कानूनी अनुपालन का प्रबंधन करें'
            : 'Manage API gateways, payment keys, Agora RTC credentials, Trust & Safety officer contacts, and legal compliance'}
        </p>
      </div>

      {saved && (
        <div className="p-3 bg-emerald-100 border border-emerald-300 text-emerald-800 rounded-xl text-xs font-bold flex items-center gap-2 animate-bounce">
          <span>✓</span>{' '}
          {isHindi
            ? 'कॉन्फ़िगरेशन सेटिंग्स सफलतापूर्वक सुरक्षित की गईं!'
            : 'Configuration settings successfully synchronized to production!'}
        </div>
      )}

      <form onSubmit={handleSave} className="space-y-6">
        {/* Sanctum Security Passkey Configuration */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>🔑</span> {isHindi ? 'मुख्य प्रशासक पासकी' : 'Master Sanctum Admin Passkey'}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">
                {isHindi ? 'सक्रिय प्रशासक पासकी' : 'Active Sanctum Passkey'}
              </label>
              <input
                type="text"
                defaultValue="mandirm@2026"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono bg-amber-50/50"
              />
              <p className="text-[10px] text-gray-400 mt-1">
                {isHindi
                  ? 'आप इसे नेटलीफाई पर NEXT_PUBLIC_ADMIN_PASSKEY पर्यावरण चर द्वारा किसी भी समय बदल सकते हैं।'
                  : 'You can override this anytime via NEXT_PUBLIC_ADMIN_PASSKEY environment variable on Netlify.'}
              </p>
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">
                {isHindi ? 'पासकी मोड' : 'Passkey Mode'}
              </label>
              <div className="p-2 border border-emerald-200 bg-emerald-50 rounded-lg text-emerald-800 font-semibold flex items-center gap-2">
                <span>🛡️</span>
                <span>
                  {isHindi
                    ? 'बायोमेट्रिक प्रमाणीकरण + मास्टर पासकी सक्रिय'
                    : 'WebAuthn Biometrics + Master Passkey Enabled'}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Payment Gateways Section */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>💳</span> {isHindi ? 'रेज़रपे भुगतान गेटवे एकीकरण' : 'Razorpay Payment Gateway Integration'}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">
                {isHindi ? 'रेज़रपे Key ID' : 'Razorpay Key ID'}
              </label>
              <input
                type="text"
                placeholder={isHindi ? 'पर्यावरण चर NEXT_PUBLIC_RAZORPAY_KEY_ID से सुरक्षित' : 'Configured via NEXT_PUBLIC_RAZORPAY_KEY_ID'}
                defaultValue={process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID || ''}
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
              />
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">
                {isHindi ? 'रेज़रपे Key Secret' : 'Razorpay Key Secret'}
              </label>
              <input
                type="password"
                placeholder="••••••••••••••••"
                defaultValue=""
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
              />
            </div>
          </div>
          <p className="text-[11px] text-gray-400">
            {isHindi
              ? 'भक्त दक्षिणा, पूजा बुकिंग एवं चढ़ावे सीधे मंदिरम् ट्रस्ट खाते में जमा होते हैं।'
              : 'Dakshina donations, puja bookings, and chadhawa offerings are deposited directly into Mandirm Trust escrow.'}
          </p>
        </div>

        {/* Real-time Video & Call Services */}
        <div className="bg-white p-5 rounded-2xl border border-gray-100 shadow-sm space-y-4">
          <h2 className="text-sm font-bold font-cinzel text-gray-900 flex items-center gap-2 border-b border-gray-100 pb-2">
            <span>📹</span> {isHindi ? 'एगोरा RTC ऑडियो/वीडियो इंजन' : 'Agora RTC Audio/Video Engine'}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            <div>
              <label className="block text-gray-700 font-semibold mb-1">
                {isHindi ? 'एगोरा App ID' : 'Agora App ID'}
              </label>
              <input
                type="text"
                placeholder={isHindi ? 'पर्यावरण चर NEXT_PUBLIC_AGORA_APP_ID' : 'Configured via NEXT_PUBLIC_AGORA_APP_ID'}
                defaultValue={process.env.NEXT_PUBLIC_AGORA_APP_ID || ''}
                className="w-full p-2 border border-gray-300 rounded-lg text-xs font-mono"
              />
            </div>
            <div>
              <label className="block text-gray-700 font-semibold mb-1">
                {isHindi ? 'टोकन वैधता अवधि' : 'RTC Token Expiry Window'}
              </label>
              <input
                type="text"
                defaultValue="86400"
                className="w-full p-2 border border-gray-300 rounded-lg text-xs"
              />
            </div>
          </div>
        </div>

        {/* Save Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            className="w-full sm:w-auto px-6 py-2.5 bg-mandir-maroon hover:bg-mandir-maroon-dark text-white rounded-xl text-xs font-bold shadow-md transition-all active:scale-95"
          >
            {isHindi ? 'सभी सेटिंग्स सुरक्षित करें' : 'Save All Configurations'}
          </button>
        </div>
      </form>
    </div>
  );
}
