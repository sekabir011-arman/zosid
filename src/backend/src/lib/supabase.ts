import { createClient } from '@supabase/supabase-js';

let supabase: any = null;

function getSupabaseConfig() {
  const supabaseUrl =
    process.env.SUPABASE_URL ||
    process.env.VITE_SUPABASE_URL ||
    process.env.NEXT_PUBLIC_SUPABASE_URL;

  const serviceRoleKey =
    process.env.SUPABASE_SERVICE_KEY ||
    process.env.SUPABASE_SERVICE_ROLE_KEY ||
    process.env.VITE_SUPABASE_SERVICE_KEY ||
    process.env.NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY;

  const anonKey =
    process.env.SUPABASE_ANON_KEY ||
    process.env.VITE_SUPABASE_ANON_KEY ||
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

  return { supabaseUrl, serviceRoleKey, anonKey };
}

export function initializeSupabase() {
  const { supabaseUrl, serviceRoleKey } = getSupabaseConfig();

  if (!supabaseUrl || !serviceRoleKey) {
    throw new Error('Missing Supabase configuration (URL or Service Role Key)');
  }

  supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }) as any;

  return supabase;
}

export function getSupabaseClient(): any {
  if (!supabase) {
    throw new Error('Supabase not initialized. Call initializeSupabase() first.');
  }
  return supabase;
}

export function getSupabaseAuthClient(): any {
  const { supabaseUrl, anonKey } = getSupabaseConfig();

  if (!supabaseUrl || !anonKey) {
    throw new Error('Missing Supabase configuration (URL or Anonymous Key)');
  }

  return createClient(supabaseUrl, anonKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }) as any;
}
