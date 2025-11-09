# Monetization Architecture

**Date:** October 12, 2025  
**Status:** ARCHITECTURE REVISION - Entitlement-Based Model  
**Author:** Gemini

---

## 1. Executive Summary

This document outlines the technical architecture for the monetization system in Scrap Survivor. The system has been redesigned as a scalable, **entitlement-based model** to support future growth, including DLC packs and other one-time purchases. It replaces the previous, more rigid tier-based implementation.

The model is designed around a **Community Growth Model** that prioritizes user acquisition and player-friendly mechanics. It consists of:

1.  A **Free Experience** offering the complete gameplay loop.
2.  A permanent **Premium Entitlement** (one-time purchase or referral reward).
3.  A temporary **Subscription Entitlement** (recurring purchase, requires Premium).
4.  A framework for future permanent **DLC Entitlements** (e.g., character packs).

This strategy fosters a sustainable revenue model by building a large, dedicated community first and providing a flexible platform for future content.

---

## 2. Monetization Strategy: Community Growth Model

(This section remains unchanged from the previous version.)

### 2.1. The Free-to-Play Experience

The base game is free and fully playable. Instead of watching ads for rewards, players earn permanent rewards by successfully referring new players to the game. Each player receives a unique referral code to share.

### 2.2. The Referral Reward Ladder

- **1st Referral:** Scrap Bonus.
- **2nd Referral:** Permanent Revive Unlocked.
- **3rd Referral:** 25% discount code for the Premium Pack IAP.
- **5th Referral:** Free Premium Pack (grants the 'premium' entitlement).

### 2.3. The Paid Tiers

- **Premium Pack (IAP):** A **$4.99** one-time purchase that grants the permanent 'premium' entitlement.
- **Subscription (IAP):** A **$2.99/month** recurring purchase that grants the temporary 'subscription_monthly' entitlement.

---

## 3. Tier & Entitlement Definitions

(This section is updated to clarify the relationship between entitlements and effective tiers.)

### Free Experience

- **Effective Tier:** Free
- **Required Entitlements:** None
- **Character Slots:** 3
- **Slot Management:** Players must delete characters to make room for new runs

### Premium Experience

- **Effective Tier:** Premium
- **Required Entitlements:** `premium`
- **Character Slots:** 15 (base)
- **Slot Expansions:** Available via micro-IAP (+5 slots for $0.99, +25 slots for $3.99)
- **Slot Management:** Occasional deletion needed, but with comfortable breathing room

### Subscription Experience

- **Effective Tier:** Subscription
- **Required Entitlements:** `premium` AND an active `subscription_monthly`
- **Character Slots:** 50 (active) + 200 (archive)
- **Archive System:** Exclusive "Hall of Fame" for preserving legacy runs without cluttering roster
- **Curation Tools:** Favorite/pin runs, add personal notes

---

## 4. Technical Architecture: Entitlement-Based System

To support a scalable monetization model that includes permanent tiers, temporary subscriptions, and future one-time DLC purchases, the architecture is built around a log of user entitlements rather than a single stateful tier.

### 4.1. Database Schema (Revised)

The previous `user_tiers` table is deprecated in favor of a more flexible `user_entitlements` table. Additionally, the `character_instances` table is updated to support the graceful downgrade strategy.

```sql
-- New table: user_entitlements
-- This table acts as a log of every entitlement a user acquires.
CREATE TABLE user_entitlements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES user_accounts(id) NOT NULL,
  entitlement_id VARCHAR(255) NOT NULL, -- e.g., 'premium', 'subscription_monthly', 'pack_cyborg'
  expires_at TIMESTAMPTZ, -- NULL for permanent entitlements, a future date for temporary ones
  source VARCHAR(255), -- e.g., 'stripe_purchase', 'referral_reward', 'admin_grant'
  transaction_id VARCHAR(255) UNIQUE, -- The unique ID from the payment provider
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for fast lookups
CREATE INDEX idx_user_entitlements_user_id ON user_entitlements(user_id);

-- Add is_active column to character_instances for downgrade logic
ALTER TABLE character_instances ADD COLUMN is_active BOOLEAN DEFAULT true;

-- The old user_tiers table is to be dropped.
-- The current_tier column on user_accounts remains for quick, non-critical checks.
```

### 4.2. Tier & Entitlement Service Logic

A centralized `TierService` manages all logic. Its primary responsibilities are now:

1.  **Granting Entitlements:** The service will have a `grantEntitlement(userId, entitlementId, expiresAt)` method that **INSERTS** a new row into the `user_entitlements` table. This is a simple, append-only operation.

2.  **Calculating Effective Tier:** The `getUserTier(userId)` method is now a calculation, not a simple lookup. It queries all of a user's entitlements and determines their highest active tier based on a defined hierarchy:
    - Does the user have a `subscription_monthly` entitlement where `expires_at` is in the future? **Return `Subscription`**.
    - If not, do they have a permanent `premium` entitlement? **Return `Premium`**.
    - Otherwise, **Return `Free`**.

3.  **Checking Feature Access:** A `hasFeatureAccess(userId, featureId)` method will check for the presence of a specific, required `entitlement_id` (e.g., `'pack_cyborg'`) for DLC-specific features.

### 4.3. Subscription Lapse & Downgrade Strategy

To create a fair and compelling user experience, a graceful downgrade process is critical. This logic will be handled by a new `reconcileAccountStatus(userId)` function, executed upon user login.

1.  **Detect Downgrade:** The function compares the user's last known tier (from `user_accounts.current_tier`) with their newly calculated effective tier.
2.  **Deactivate Characters:** If a downgrade occurs (e.g., Subscription -> Premium), the function will query for any `character_instances` of a type that is no longer accessible (e.g., a subscription-only character type) and set their `is_active` flag to `false`.
3.  **Graceful Disablement:** Inactive characters will be visible but not selectable in the UI, with a prompt to re-subscribe.
4.  **Cash Out Idle Systems:** Any in-progress rewards from subscription-only idle systems will be collected and awarded to the user before the system is disabled.

### 4.4. Prerequisite Enforcement

To maintain a clear progression path, the Subscription tier requires the Premium tier.

- **UI Enforcement:** The `UpgradeModal` will check if the user has the `premium` entitlement. If not, the "Subscribe" button will be disabled, with a tooltip explaining the requirement.
- **Backend Enforcement:** The Supabase Edge Function responsible for creating Stripe checkout sessions will reject any request to create a subscription session for a user who does not have the `premium` entitlement.

---

(Sections 5-9 related to Stripe, Mobile, Cost Analysis, etc., remain conceptually the same but will be implemented against this new, more robust architecture.)
