import { createClient, SupabaseClient } from '@supabase/supabase-js';

let supabase: SupabaseClient | null = null;

function getSupabaseConfig() {
  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const anonKey = process.env.SUPABASE_ANON_KEY;

  return {
    supabaseUrl,
    serviceRoleKey,
    anonKey,
  };
}

export function initializeSupabase(): SupabaseClient {
  const { supabaseUrl, serviceRoleKey } = getSupabaseConfig();

  if (!supabaseUrl) {
    throw new Error('Missing SUPABASE_URL');
  }

  if (!serviceRoleKey) {
    throw new Error('Missing SUPABASE_SERVICE_ROLE_KEY');
  }

  supabase = createClient(
    supabaseUrl,
    serviceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );

  return supabase;
}

export function getSupabaseClient(): SupabaseClient {
  if (!supabase) {
    return initializeSupabase();
  }

  return supabase;
}

export function getSupabaseAuthClient(): SupabaseClient {
  const { supabaseUrl, anonKey } = getSupabaseConfig();

  if (!supabaseUrl) {
    throw new Error('Missing SUPABASE_URL');
  }

  if (!anonKey) {
    throw new Error('Missing SUPABASE_ANON_KEY');
  }

  return createClient(
    supabaseUrl,
    anonKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    }
  );
}