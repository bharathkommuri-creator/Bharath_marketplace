-- ====================================================================
-- ADD sender_name TO transfer_chats
-- The Flutter app stores sender display names alongside sender_role
-- so we can reconstruct full chat messages without a profiles JOIN.
-- Run this in Supabase Dashboard → SQL Editor
-- ====================================================================

ALTER TABLE public.transfer_chats
  ADD COLUMN IF NOT EXISTS sender_name TEXT;
