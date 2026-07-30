-- ====================================================================
-- Add ad_id column to transfer_chats for web app (no FK required)
-- Make listing_id nullable so web can insert without a UUID FK
-- Run this in Supabase Dashboard → SQL Editor
-- ====================================================================

-- Make listing_id nullable
ALTER TABLE public.transfer_chats
  ALTER COLUMN listing_id DROP NOT NULL;

-- Add ad_id text column for web app mock IDs (e.g. 'in-001')
ALTER TABLE public.transfer_chats
  ADD COLUMN IF NOT EXISTS ad_id TEXT;

-- Make sender_id nullable for anonymous web users
ALTER TABLE public.transfer_chats
  ALTER COLUMN sender_id DROP NOT NULL;

-- Index for fast lookup by ad_id
CREATE INDEX IF NOT EXISTS idx_transfer_chats_ad_id ON public.transfer_chats(ad_id);
