-- =============================================================================
-- RESALEHUB 3-PARTY BOOKING RESALE MARKETPLACE - IDEMPOTENT SUPABASE SCHEMA
-- =============================================================================

-- 1. Create Enums Safely (Idempotent)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('buyer', 'seller', 'service_provider');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'listing_status') THEN
        CREATE TYPE public.listing_status AS ENUM ('listed', 'buyer_paid', 'provider_verified', 'transfer_completed');
    END IF;
END $$;

-- 2. Create User Profiles Table (Linked 1-to-1 with Supabase Auth users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role public.user_role NOT NULL DEFAULT 'buyer',
    business_name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Create Resale Listings Table
CREATE TABLE IF NOT EXISTS public.resale_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    location TEXT NOT NULL,
    event_date TIMESTAMPTZ NOT NULL,
    original_price NUMERIC(10,2) NOT NULL CHECK (original_price > 0),
    deposit_paid NUMERIC(10,2) NOT NULL CHECK (deposit_paid >= 0 AND deposit_paid <= original_price),
    resale_price NUMERIC(10,2) NOT NULL CHECK (resale_price > 0 AND resale_price < original_price),
    provider_name TEXT NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    image_url TEXT NOT NULL,
    cancellation_reason TEXT,
    proof_url TEXT,
    status public.listing_status NOT NULL DEFAULT 'listed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Keep existing deployments aligned with the table definition above.
ALTER TABLE public.resale_listings
    ADD COLUMN IF NOT EXISTS deposit_paid NUMERIC(10,2);
UPDATE public.resale_listings
    SET deposit_paid = original_price * 0.5
    WHERE deposit_paid IS NULL;
ALTER TABLE public.resale_listings
    ALTER COLUMN deposit_paid SET NOT NULL;
ALTER TABLE public.resale_listings
    DROP CONSTRAINT IF EXISTS resale_listings_deposit_paid_check;
ALTER TABLE public.resale_listings
    ADD CONSTRAINT resale_listings_deposit_paid_check
    CHECK (deposit_paid >= 0 AND deposit_paid <= original_price);
ALTER TABLE public.resale_listings
    DROP CONSTRAINT IF EXISTS resale_listings_resale_price_check;
ALTER TABLE public.resale_listings
    ADD CONSTRAINT resale_listings_resale_price_check
    CHECK (resale_price > 0 AND resale_price < original_price);

-- 4. Create 3-Party Transfer Chats Table
CREATE TABLE IF NOT EXISTS public.transfer_chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ad_id TEXT NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    sender_name TEXT NOT NULL,
    sender_role public.user_role NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Auto Profile Creation Trigger (Runs when a new user signs up via Supabase Auth)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role, business_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
        NEW.email,
        -- Public sign-up metadata is client-controlled, so it must never
        -- assign a privileged role. Role promotion happens through a trusted
        -- server-side workflow.
        'buyer'::public.user_role,
        NEW.raw_user_meta_data->>'business_name'
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email,
        role = EXCLUDED.role;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind Trigger to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. Enable Row Level Security (RLS) & Define Public Access Policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resale_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer_chats ENABLE ROW LEVEL SECURITY;

-- Clean Up Old Policies (Prevents Duplicate Policy Errors)
DROP POLICY IF EXISTS "Allow public read of profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow individual user update" ON public.profiles;
DROP POLICY IF EXISTS "Allow public read of active listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Allow authenticated insert of listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Allow authenticated update of listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Allow public read of transfer chats" ON public.transfer_chats;
DROP POLICY IF EXISTS "Allow authenticated insert of transfer chats" ON public.transfer_chats;
DROP POLICY IF EXISTS "Users can read their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Public can read listed listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Sellers can create their own listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Sellers can update their own listed listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Authenticated users can read transfer chats" ON public.transfer_chats;
DROP POLICY IF EXISTS "Users can send their own transfer chats" ON public.transfer_chats;

-- Profiles Policies
CREATE POLICY "Users can read their own profile" ON public.profiles
    FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.profiles
    FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- RLS limits which profile row a user may edit. Column grants also prevent a
-- user from promoting their own role through the REST API.
REVOKE UPDATE ON public.profiles FROM anon, authenticated;
GRANT UPDATE (full_name, business_name) ON public.profiles TO authenticated;

-- Listings Policies
CREATE POLICY "Public can read listed listings" ON public.resale_listings
    FOR SELECT TO anon, authenticated
    USING (status = 'listed' OR seller_id = auth.uid());
CREATE POLICY "Sellers can create their own listings" ON public.resale_listings
    FOR INSERT TO authenticated
    WITH CHECK (seller_id = auth.uid() AND status = 'listed' AND is_verified = FALSE);
CREATE POLICY "Sellers can update their own listed listings" ON public.resale_listings
    FOR UPDATE TO authenticated
    USING (seller_id = auth.uid() AND status = 'listed')
    WITH CHECK (seller_id = auth.uid() AND status = 'listed');

-- Only a trusted server-side workflow may change ownership, verification, or
-- transfer state. Sellers may edit the listing details while it is listed.
REVOKE UPDATE ON public.resale_listings FROM anon, authenticated;
GRANT UPDATE (
    title, category, location, event_date, original_price, deposit_paid,
    resale_price, provider_name, image_url, cancellation_reason
) ON public.resale_listings TO authenticated;

-- Chats Policies
CREATE POLICY "Authenticated users can read transfer chats" ON public.transfer_chats
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can send their own transfer chats" ON public.transfer_chats
    FOR INSERT TO authenticated WITH CHECK (sender_id = auth.uid());

-- Enable Realtime Safely
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'transfer_chats'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.transfer_chats;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'resale_listings'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.resale_listings;
    END IF;
END $$;
