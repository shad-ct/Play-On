import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://wwuguqavinfyozpspbog.supabase.co';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'sb_publishable_jUJi4AQq29iSCbL9BVjtrg_Lx3j7lS6';

export const supabase = createClient(supabaseUrl, supabaseKey);
