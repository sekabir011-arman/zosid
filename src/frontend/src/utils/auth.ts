/**
 * Get the current authentication token from Supabase session state,
 * with a localStorage fallback for existing sessions.
 */
export const getToken = async (): Promise<string | null> => {
  const { data: { session } } = await import('../lib/supabase').then(({ supabase }) => supabase.auth.getSession());
  return session?.access_token ?? localStorage.getItem('auth_token');
};

/**
 * Check if user is authenticated
 */
export const isAuthenticated = async (): Promise<boolean> => {
  return Boolean(await getToken());
};

/**
 * Store the authentication token
 */
export const setToken = (token: string): void => {
  localStorage.setItem('auth_token', token);
};

/**
 * Clear the authentication token
 */
export const clearToken = async (): Promise<void> => {
  try {
    const { supabase } = await import('../lib/supabase');
    await supabase.auth.signOut();
  } catch {
    // Ignore sign-out failures and fall back to local cleanup.
  }
  localStorage.removeItem('auth_token');
};

/**
 * Decode JWT token to get payload (basic implementation)
 */
export const decodeToken = (token: string): any => {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) throw new Error('Invalid token');
    const decoded = JSON.parse(atob(parts[1]));
    return decoded;
  } catch (error) {
    console.error('Failed to decode token:', error);
    return null;
  }
};

/**
 * Check if token is expired
 */
export const isTokenExpired = (token: string): boolean => {
  const decoded = decodeToken(token);
  if (!decoded || !decoded.exp) return true;
  return decoded.exp * 1000 < Date.now();
};
