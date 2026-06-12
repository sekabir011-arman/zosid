import { supabase } from './lib/supabase';

export async function testSupabaseConnection() {
  const { data, error } = await supabase
    .from('todos')
    .select('*')
    .limit(1);

  if (error) {
    console.error('Supabase connection failed:', error);
    return false;
  }

  console.log('Supabase connected successfully');
  console.log(data);

  return true;
}