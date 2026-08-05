-- ============================================================
-- STEP 2 OF 2: Run AFTER step 1 has been run and committed.
-- Creates tables, policies, indexes, triggers, realtime.
-- ============================================================

-- 2. User Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role public.user_role NOT NULL DEFAULT 'buyer',
    business_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Resale Listings Table
CREATE TABLE IF NOT EXISTS public.resale_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    buyer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    location TEXT NOT NULL,
    event_date TIMESTAMPTZ NOT NULL,
    original_price NUMERIC(10,2) NOT NULL CHECK (original_price > 0),
    deposit_paid NUMERIC(10,2) NOT NULL CHECK (deposit_paid >= 0 AND deposit_paid <= original_price),
    resale_price NUMERIC(10,2) NOT NULL CHECK (resale_price > 0 AND resale_price < original_price),
    provider_name TEXT NOT NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    image_url TEXT NOT NULL DEFAULT '',
    cancellation_reason TEXT,
    proof_url TEXT,
    status public.listing_status NOT NULL DEFAULT 'listed',
    view_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Idempotent column additions for existing deployments
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS seller_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS buyer_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS title TEXT NOT NULL DEFAULT '';
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT '';
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS location TEXT NOT NULL DEFAULT '';
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS event_date TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS original_price NUMERIC(10,2);
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS deposit_paid NUMERIC(10,2);
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS resale_price NUMERIC(10,2);
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS provider_name TEXT NOT NULL DEFAULT '';
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS is_verified BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS image_url TEXT NOT NULL DEFAULT '';
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS proof_url TEXT;
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS status public.listing_status NOT NULL DEFAULT 'listed';
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS view_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.resale_listings ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS business_name TEXT;

-- Safe NULL fills before NOT NULL enforcement
UPDATE public.resale_listings SET original_price = 0 WHERE original_price IS NULL;
UPDATE public.resale_listings SET resale_price = 0 WHERE resale_price IS NULL;
UPDATE public.resale_listings SET deposit_paid = 0 WHERE deposit_paid IS NULL;
ALTER TABLE public.resale_listings ALTER COLUMN original_price SET NOT NULL;
ALTER TABLE public.resale_listings ALTER COLUMN resale_price SET NOT NULL;
ALTER TABLE public.resale_listings ALTER COLUMN deposit_paid SET NOT NULL;

-- Idempotent constraint management
ALTER TABLE public.resale_listings DROP CONSTRAINT IF EXISTS resale_listings_deposit_paid_check;
ALTER TABLE public.resale_listings DROP CONSTRAINT IF EXISTS resale_listings_resale_price_check;
ALTER TABLE public.resale_listings DROP CONSTRAINT IF EXISTS resale_listings_original_price_check;

-- 4. Transfer Chats Table
CREATE TABLE IF NOT EXISTS public.transfer_chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ad_id TEXT NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    sender_name TEXT NOT NULL,
    sender_role public.user_role NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    listing_id UUID REFERENCES public.resale_listings(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Auto Profile Creation Trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role, business_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
        NEW.email,
        'buyer'::public.user_role,
        NEW.raw_user_meta_data->>'business_name'
    )
    ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        email = EXCLUDED.email;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
DROP TRIGGER IF EXISTS set_listings_updated_at ON public.resale_listings;
CREATE TRIGGER set_listings_updated_at BEFORE UPDATE ON public.resale_listings FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- 7. Performance Indexes
CREATE INDEX IF NOT EXISTS idx_listings_category   ON public.resale_listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_status     ON public.resale_listings(status);
CREATE INDEX IF NOT EXISTS idx_listings_seller     ON public.resale_listings(seller_id);
CREATE INDEX IF NOT EXISTS idx_listings_buyer      ON public.resale_listings(buyer_id);
CREATE INDEX IF NOT EXISTS idx_listings_event_date ON public.resale_listings(event_date);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON public.resale_listings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chats_ad_id         ON public.transfer_chats(ad_id);
CREATE INDEX IF NOT EXISTS idx_chats_created       ON public.transfer_chats(created_at);
CREATE INDEX IF NOT EXISTS idx_notif_user          ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_unread        ON public.notifications(user_id, is_read) WHERE is_read = FALSE;

-- 8. Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resale_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer_chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Drop old policies
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
DROP POLICY IF EXISTS "Users can read their own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark their own notifications read" ON public.notifications;

-- Profiles policies
CREATE POLICY "Users can read their own profile" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
REVOKE UPDATE ON public.profiles FROM anon, authenticated;
GRANT UPDATE (full_name, business_name, phone, avatar_url) ON public.profiles TO authenticated;

-- Listings policies
CREATE POLICY "Public can read listed listings" ON public.resale_listings FOR SELECT TO anon, authenticated USING (status = 'listed' OR seller_id = auth.uid());
CREATE POLICY "Sellers can create their own listings" ON public.resale_listings FOR INSERT TO authenticated WITH CHECK (seller_id = auth.uid() AND is_verified = FALSE);
CREATE POLICY "Sellers can update their own listed listings" ON public.resale_listings FOR UPDATE TO authenticated USING (seller_id = auth.uid() AND status = 'listed') WITH CHECK (seller_id = auth.uid() AND status = 'listed');
REVOKE UPDATE ON public.resale_listings FROM anon, authenticated;
GRANT UPDATE (title, category, location, event_date, original_price, deposit_paid, resale_price, provider_name, image_url, cancellation_reason) ON public.resale_listings TO authenticated;

-- Chats policies
CREATE POLICY "Authenticated users can read transfer chats" ON public.transfer_chats FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can send their own transfer chats" ON public.transfer_chats FOR INSERT TO authenticated WITH CHECK (sender_id = auth.uid());

-- Notifications policies
CREATE POLICY "Users can read their own notifications" ON public.notifications FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "Users can mark their own notifications read" ON public.notifications FOR UPDATE TO authenticated USING (user_id = auth.uid());

-- 9. Enable Realtime
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'transfer_chats') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.transfer_chats;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'resale_listings') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.resale_listings;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'notifications') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
END $$;
