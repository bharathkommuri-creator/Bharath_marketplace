-- ====================================================================
-- FIX: Relax RLS policies for demo/anonymous web access
-- Run this in Supabase Dashboard → SQL Editor
-- ====================================================================

-- DROP existing restrictive policies
DROP POLICY IF EXISTS "3-Party chat access control" ON public.transfer_chats;
DROP POLICY IF EXISTS "Sellers can insert resale listings" ON public.resale_listings;
DROP POLICY IF EXISTS "Sellers can create bookings" ON public.bookings;

-- transfer_chats: allow anyone to INSERT and SELECT (demo mode)
CREATE POLICY "Allow public read on chats"
  ON public.transfer_chats FOR SELECT USING (true);

CREATE POLICY "Allow public insert on chats"
  ON public.transfer_chats FOR INSERT WITH CHECK (true);

-- resale_listings: allow anyone to insert/update (demo mode)
CREATE POLICY "Allow public insert on listings"
  ON public.resale_listings FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update on listings"
  ON public.resale_listings FOR UPDATE USING (true);

-- bookings: allow anyone to insert (demo mode)
CREATE POLICY "Allow public insert on bookings"
  ON public.bookings FOR INSERT WITH CHECK (true);

-- profiles: allow anyone to insert (for anonymous profile creation)
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Allow public insert on profiles"
  ON public.profiles FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow users to update own profile"
  ON public.profiles FOR UPDATE USING (true);
