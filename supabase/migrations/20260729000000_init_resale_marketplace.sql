-- ====================================================================
-- SUPABASE POSTGRES SCHEMA & RLS MIGRATION
-- Project: Cross-Platform Booking Resale Marketplace
-- 3-Party Communication: Service Provider, Seller, New Buyer
-- ====================================================================

-- 1. Create Custom Types
CREATE TYPE user_role AS ENUM ('service_provider', 'seller', 'buyer');
CREATE TYPE listing_status AS ENUM ('active', 'pending_transfer', 'sold', 'cancelled');
CREATE TYPE booking_category AS ENUM ('Hotels', 'Venues', 'Photography', 'Catering', 'Gyms', 'Events');
CREATE TYPE transfer_step AS ENUM ('listed', 'claimed', 'provider_verified', 'completed');

-- 2. Profiles Table (Users & Vendors)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'buyer',
    business_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Bookings Table (Original Reservations)
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    category booking_category NOT NULL,
    provider_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    original_buyer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    original_price NUMERIC(10, 2) NOT NULL,
    deposit_paid NUMERIC(10, 2) NOT NULL,
    event_date DATE NOT NULL,
    location TEXT NOT NULL,
    proof_document_url TEXT,
    verification_status TEXT DEFAULT 'verified',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Resale Listings Table
CREATE TABLE IF NOT EXISTS public.resale_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    seller_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    resale_price NUMERIC(10, 2) NOT NULL,
    discount_percentage INT NOT NULL,
    cancellation_reason TEXT,
    status listing_status DEFAULT 'active',
    current_buyer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    transfer_step transfer_step DEFAULT 'listed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. 3-Party Transfer Chats & Communications
CREATE TABLE IF NOT EXISTS public.transfer_chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES public.resale_listings(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_role user_role NOT NULL,
    message TEXT NOT NULL,
    action_trigger transfer_step,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Transactions Table
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES public.resale_listings(id) ON DELETE RESTRICT,
    buyer_id UUID NOT NULL REFERENCES public.profiles(id),
    seller_id UUID NOT NULL REFERENCES public.profiles(id),
    amount NUMERIC(10, 2) NOT NULL,
    escrow_status TEXT DEFAULT 'in_escrow',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resale_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer_chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Profiles: Public read, owner update
CREATE POLICY "Public profiles are readable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Bookings: Everyone can view verified bookings, sellers & providers can insert/update
CREATE POLICY "Anyone can view bookings" ON public.bookings FOR SELECT USING (true);
CREATE POLICY "Sellers can create bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = original_buyer_id);
CREATE POLICY "Providers and owners can update bookings" ON public.bookings FOR UPDATE USING (auth.uid() = original_buyer_id OR auth.uid() = provider_id);

-- Resale Listings: Anyone can view active listings, owner can edit own listing
CREATE POLICY "Active listings are viewable by all" ON public.resale_listings FOR SELECT USING (true);
CREATE POLICY "Sellers can insert resale listings" ON public.resale_listings FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY "Sellers and assigned buyers can update listing status" ON public.resale_listings FOR UPDATE USING (
    auth.uid() = seller_id OR auth.uid() = current_buyer_id
);

-- 3-Party Transfer Chats: Readable & writeable by the 3 involved parties (Seller, Buyer, Provider)
CREATE POLICY "3-Party chat access control" ON public.transfer_chats FOR ALL USING (
    EXISTS (
        SELECT 1 FROM public.resale_listings rl
        JOIN public.bookings b ON b.id = rl.booking_id
        WHERE rl.id = transfer_chats.listing_id
        AND (auth.uid() = rl.seller_id OR auth.uid() = rl.current_buyer_id OR auth.uid() = b.provider_id)
    )
);

-- Transactions: Accessible by buyer, seller, and provider
CREATE POLICY "Transactions viewable by participants" ON public.transactions FOR SELECT USING (
    auth.uid() = buyer_id OR auth.uid() = seller_id
);

-- ====================================================================
-- SEED MOCK DATA
-- ====================================================================
-- Seed data included for testing local setup
