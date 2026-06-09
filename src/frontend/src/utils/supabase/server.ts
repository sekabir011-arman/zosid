import { createClient as createSupabaseClient } from '@supabase/supabase-js';

export function createClient() {
  const env = (import.meta as unknown as { env?: Record<string, string | undefined> }).env ?? {};
  const supabaseUrl = env.VITE_SUPABASE_URL || env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseAnonKey =
    env.VITE_SUPABASE_ANON_KEY ||
    env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ||
    env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error('Missing Supabase credentials. Please set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY (or the NEXT_PUBLIC_* fallbacks).');
  }

  return createSupabaseClient(supabaseUrl, supabaseAnonKey);
}

export default createClient;