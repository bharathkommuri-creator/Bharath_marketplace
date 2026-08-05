-- ============================================================
-- STEP 1 OF 2: Run this first, then run step 2 separately.
-- Creates enums and adds any missing enum values.
-- MUST be committed (run separately) before step 2.
-- ============================================================

-- Create enums if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
        CREATE TYPE public.user_role AS ENUM ('buyer', 'seller', 'service_provider');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'listing_status') THEN
        CREATE TYPE public.listing_status AS ENUM ('listed', 'buyer_paid', 'provider_verified', 'transfer_completed');
    END IF;
END $$;

-- Add any missing values to existing enums
-- (PostgreSQL requires these to be committed before use — hence this is Step 1)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'user_role' AND e.enumlabel = 'buyer') THEN
        ALTER TYPE public.user_role ADD VALUE 'buyer';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'user_role' AND e.enumlabel = 'seller') THEN
        ALTER TYPE public.user_role ADD VALUE 'seller';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'user_role' AND e.enumlabel = 'service_provider') THEN
        ALTER TYPE public.user_role ADD VALUE 'service_provider';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'listing_status' AND e.enumlabel = 'listed') THEN
        ALTER TYPE public.listing_status ADD VALUE 'listed';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'listing_status' AND e.enumlabel = 'buyer_paid') THEN
        ALTER TYPE public.listing_status ADD VALUE 'buyer_paid';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'listing_status' AND e.enumlabel = 'provider_verified') THEN
        ALTER TYPE public.listing_status ADD VALUE 'provider_verified';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid WHERE t.typname = 'listing_status' AND e.enumlabel = 'transfer_completed') THEN
        ALTER TYPE public.listing_status ADD VALUE 'transfer_completed';
    END IF;
END $$;
