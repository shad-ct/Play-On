-- Create admins table for Super Admin
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN AS $$
BEGIN
  IF auth.jwt() ->> 'email' = 'admin@turfon.com' THEN
    RETURN true;
  END IF;
  RETURN EXISTS (SELECT 1 FROM admins WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function for admins to get all users from auth.users
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (id UUID, email VARCHAR, raw_user_meta_data JSONB, created_at TIMESTAMPTZ)
SECURITY DEFINER
AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Access denied';
  END IF;
  RETURN QUERY SELECT u.id, u.email, u.raw_user_meta_data, u.created_at FROM auth.users u;
END;
$$ LANGUAGE plpgsql;

-- Create turfs table (linked to auth.users if we want turf owners to have their own accounts)
CREATE TABLE IF NOT EXISTS turfs (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    phone_number TEXT,
    location_map_link TEXT,
    price_per_hour NUMERIC,
    open_time TIME,
    close_time TIME,
    sports_supported TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add sports_supported to existing table if it was already created
ALTER TABLE turfs ADD COLUMN IF NOT EXISTS sports_supported TEXT[] DEFAULT '{}';

-- Enable RLS for turfs
ALTER TABLE turfs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Turfs are viewable by everyone" ON turfs;
CREATE POLICY "Turfs are viewable by everyone" ON turfs
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Turfs can be updated by the turf owner" ON turfs;
CREATE POLICY "Turfs can be updated by the turf owner" ON turfs
    FOR UPDATE USING (auth.uid() = id);

-- Allow inserting without being logged in (required if email confirmations are enabled)
DROP POLICY IF EXISTS "Anyone can insert a turf" ON turfs;
CREATE POLICY "Anyone can insert a turf" ON turfs
    FOR INSERT WITH CHECK (true);

-- Admins can do everything on turfs
DROP POLICY IF EXISTS "Admins can do everything on turfs" ON turfs;
CREATE POLICY "Admins can do everything on turfs" ON turfs
    FOR ALL USING (is_admin());


-- Create bookings/requests table
CREATE TABLE IF NOT EXISTS bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    turf_id UUID REFERENCES turfs(id) ON DELETE CASCADE,
    player_name TEXT NOT NULL,
    player_phone TEXT NOT NULL,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for bookings
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- Turf owners can manage their own bookings
DROP POLICY IF EXISTS "Turf owners can view their bookings" ON bookings;
CREATE POLICY "Turf owners can view their bookings" ON bookings
    FOR SELECT USING (auth.uid() = turf_id);

DROP POLICY IF EXISTS "Turf owners can update their bookings" ON bookings;
CREATE POLICY "Turf owners can update their bookings" ON bookings
    FOR UPDATE USING (auth.uid() = turf_id);

-- Anyone (from the PlayON app) can insert a booking
DROP POLICY IF EXISTS "Anyone can insert bookings" ON bookings;
CREATE POLICY "Anyone can insert bookings" ON bookings
    FOR INSERT WITH CHECK (true);

-- Create games table
CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    host_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    sport TEXT NOT NULL,
    max_players INTEGER NOT NULL,
    turf_id UUID REFERENCES turfs(id) ON DELETE CASCADE,
    is_public BOOLEAN DEFAULT true,
    game_date DATE,
    start_time TIME,
    end_time TIME,
    approval_status TEXT DEFAULT 'pending', -- pending, approved, rejected
    status TEXT DEFAULT 'open', -- open, full, playing, finished
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add is_public to existing table if it was already created
ALTER TABLE games ADD COLUMN IF NOT EXISTS is_public BOOLEAN DEFAULT true;
ALTER TABLE games ADD COLUMN IF NOT EXISTS game_date DATE;
ALTER TABLE games ADD COLUMN IF NOT EXISTS start_time TIME;
ALTER TABLE games ADD COLUMN IF NOT EXISTS end_time TIME;
ALTER TABLE games ADD COLUMN IF NOT EXISTS approval_status TEXT DEFAULT 'pending';

-- Enable RLS for games
ALTER TABLE games ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Games are viewable by everyone" ON games;
CREATE POLICY "Games are viewable by everyone" ON games
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can create games" ON games;
CREATE POLICY "Users can create games" ON games
    FOR INSERT WITH CHECK (auth.uid() = host_id);

DROP POLICY IF EXISTS "Host can update their games" ON games;
CREATE POLICY "Host can update their games" ON games
    FOR UPDATE USING (auth.uid() = host_id);

-- Create game_players table
CREATE TABLE IF NOT EXISTS game_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID REFERENCES games(id) ON DELETE CASCADE,
    player_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- pending, accepted, rejected, removed
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(game_id, player_id)
);

-- Enable RLS for game_players
ALTER TABLE game_players ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Game players viewable by everyone" ON game_players;
CREATE POLICY "Game players viewable by everyone" ON game_players
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can request to join" ON game_players;
CREATE POLICY "Users can request to join" ON game_players
    FOR INSERT WITH CHECK (auth.uid() = player_id);

DROP POLICY IF EXISTS "Players can leave game" ON game_players;
CREATE POLICY "Players can leave game" ON game_players
    FOR DELETE USING (auth.uid() = player_id);

DROP POLICY IF EXISTS "Host can update game players" ON game_players;
CREATE POLICY "Host can update game players" ON game_players
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM games
            WHERE games.id = game_players.game_id
            AND games.host_id = auth.uid()
        )
    );

-- Auto delete game code and qr after 7 days
-- Requires pg_cron extension to be enabled in Supabase Database settings
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'delete-old-games',
  '0 0 * * *', -- Run every day at midnight
  $$ DELETE FROM games WHERE created_at < NOW() - INTERVAL '7 days'; $$
);
