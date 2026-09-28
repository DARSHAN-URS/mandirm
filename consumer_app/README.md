# Mandiram - Consumer Mobile Application

A cross-platform Flutter application for the **Puja, Temple & Astrology Platform**, featuring Supabase Authentication, Live Darshan, Vedic Pujas, Chadhawa Prasad offerings, and Astrologer consultations.

---

## 🌟 Key Features Built
1. **Divine Animated Splash Screen**
   - Breathing golden aura and sacred glowing emblem with Mandiram branding.
   - Smooth scale, glow, and fade animations.
   - Automatic authentication verification and dynamic route dispatching.
2. **Supabase Authentication & State Management**
   - **Phone OTP Login** (India `+91` standard & international code picker) via Supabase Auth SMS.
   - **Email & Password Login / Signup** with tab toggle.
   - **Instant Devotee Guest Access** for quick preview and offline testing.
   - **Dev / Offline Mock Mode Fallback**: Allows the app to run and be tested seamlessly even before configuring live Supabase environment keys.
   - **Reactive BLoC Architecture** (`AuthBloc`, `AuthEvent`, `AuthState`) handling loading states, error dialogs, and session synchronization.
3. **6-Digit OTP Verification Screen**
   - Auto-advancing and backspace-responsive 6-digit PIN input.
   - 30-second resend countdown timer.
   - Test mode helper (`123456`).
4. **Cultural Devotional Profile Setup (Sankalp)**
   - User Name, Gotra selection (e.g., Kashyap, Bharadwaja, Vashishta, etc.).
   - Rashi (Moon Sign) and Date of Birth picker for Vedic Puja Sankalp and astrological charts.
   - Automatic upsert into Supabase `profiles` table.
5. **Consumer Home Hub**
   - Live Today's Panchang banner with Auspicious Muhurat and Tithi.
   - Quick action grid (Sacred Mandirs, Book Puja, Chadhawa Prasad, Astrologers).
   - Featured Mandirs with Live Darshan indicators (Kashi Vishwanath, Mahakaleshwar, Tirupati Balaji).
   - Special Puja listings with online Sankalp booking.
   - Vedic Astrologer profiles with live ratings and per-minute consultation rates.
   - Supabase connection status indicator and User Profile / Sign Out modal.

---

## 🚀 Running the App

### 1. Dev / Offline Mode (Works out-of-the-box)
```bash
cd consumer_app
flutter run
```
*Note: In Dev mode, enter any valid 10-digit number and use OTP `123456`, or tap **"Explore as Devotee Guest"**.*

### 2. Connected with Live Supabase Project
Provide your Supabase URL and Anon/Publishable Key using `--dart-define`:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 3. Testing
```bash
flutter test
flutter analyze
```
