import { supabase } from './supabase';

/**
 * Generic helper to fetch all records from a table.
 */
export async function getClinicalStore(table: string) {
  const { data, error } = await supabase
    .from(table)
    .select('*');

  if (error) {
    console.error(`Error loading ${table}:`, error);
    throw error;
  }

  return data ?? [];
}

/**
 * Insert a record into a table.
 */
export async function createClinicalRecord(
  table: string,
  payload: Record<string, any>
) {
  const { data, error } = await supabase
    .from(table)
    .insert(payload)
    .select()
    .single();

  if (error) {
    console.error(`Error creating ${table}:`, error);
    throw error;
  }

  return data;
}

/**
 * Update a record by id.
 */
export async function updateClinicalRecord(
  table: string,
  id: string,
  payload: Record<string, any>
) {
  const { data, error } = await supabase
    .from(table)
    .update(payload)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    console.error(`Error updating ${table}:`, error);
    throw error;
  }

  return data;
}

/**
 * Delete a record by id.
 */
export async function deleteClinicalRecord(
  table: string,
  id: string
) {
  const { error } = await supabase
    .from(table)
    .delete()
    .eq('id', id);

  if (error) {
    console.error(`Error deleting ${table}:`, error);
    throw error;
  }

  return true;
}