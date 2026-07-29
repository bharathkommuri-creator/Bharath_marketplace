# Booking Resale Marketplace (Flutter + Supabase)

A cross-platform (Web, Android, iOS) booking resale marketplace built with **Flutter** and **Supabase** that allows users to resell non-refundable service bookings (Hotels, Venues, Photography, Catering, Gyms, Events) at a discount.

Natively features a **3-Party Communication & Transfer Engine**:
1. **Service Provider**: Host/Vendor who verifies booking validity and approves guest reservation reassignment.
2. **Seller (Original Buyer)**: Canceled booking owner who lists the slot, sets the discount price, and releases the slot.
3. **New Buyer**: Browses categories, claims slots at 30%–60% off, and completes the 3-party transfer.

---

## 🎨 Color Palette & Aesthetics
- **Theme**: Clean White & Emerald Green palette
- **Primary**: Emerald Green (`#0F9D58` / `#00C853`)
- **Background Accent**: Mint Soft Green (`#F0FDF4` / `#E8F5E9`)
- **Container**: Pure Crisp White cards (`#FFFFFF`) with subtle depth shadows

---

## 🚀 Key Features

- **Multi-Category Engagement Homepage**:
  - Recent Resale Listings feed across Hotels, Venues, Photography, Catering, Gyms, Events.
  - Flash Sale row for High Savings (>40% Off) to maximize user session browsing.
  - Interactive "How 3-Party Transfer Works" guide.
  - Instant category filter chips and full-text search.
- **Booking Detail & Pricing Breakdown**:
  - Highlights Original Price, Deposit Lost by Seller, Resell Asking Price, and Net Buyer Savings.
  - Provider Verification status badge.
- **3-Party Transfer Stepper & Communication Stream**:
  - Real-time message thread between Service Provider, Seller, and Buyer.
  - Step 1: Listed $\rightarrow$ Step 2: Buyer Claimed $\rightarrow$ Step 3: Provider Verified $\rightarrow$ Step 4: Completed.
- **Seller Listing Flow**:
  - Form to upload cancelled booking, choose category, set deposit lost, and auto-calculate discount percentage.

---

## 📁 Database & Supabase Setup

The Postgres SQL schema migration script is located at:
`supabase/migrations/20260729000000_init_resale_marketplace.sql`

### How to apply database migrations to your Supabase project:
1. Create a project at [Supabase Dashboard](https://supabase.com).
2. Go to the **SQL Editor** tab.
3. Copy and execute the contents of `supabase/migrations/20260729000000_init_resale_marketplace.sql`.
4. Tables created:
   - `profiles`: User/Vendor profiles with `user_role` enum (`service_provider`, `seller`, `buyer`).
   - `bookings`: Original reservation records with verification status.
   - `resale_listings`: Resale asking price, discount %, transfer status.
   - `transfer_chats`: 3-party communication messages and status triggers.
   - `transactions`: Purchase transactions and escrow state.
5. Row Level Security (RLS) policies are automatically configured.

### Configuring Supabase Credentials in Flutter:
Open `lib/main.dart` and update the initialization parameters:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## 💻 Local Environment Setup & Commands

### Running Flutter Web & Mobile:
```bash
# Get dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on Web (Local Server)
flutter run -d web-server --web-port 8080

# Build Web Bundle
flutter build web
```

### Running Local Web Preview Server (Python):
```bash
py -m http.server 8080 --directory web
```
Then open `http://localhost:8080` in your web browser.
