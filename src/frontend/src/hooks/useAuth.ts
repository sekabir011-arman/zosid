import { useCallback, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { StaffRole } from '../types';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface SignUpCredentials extends LoginCredentials {
  name: string;
  role: StaffRole;
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: StaffRole;
}

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const login = useCallback(async (credentials: LoginCredentials) => {
    setLoading(true);
    setError(null);
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: credentials.email,
        password: credentials.password,
      });

      if (error || !data.session || !data.user) {
        throw new Error(error?.message || 'Login failed');
      }

      const nextUser = {
        id: data.user.id,
        email: data.user.email ?? credentials.email,
        name: data.user.user_metadata?.name ?? data.user.email ?? credentials.email,
        role: (data.user.user_metadata?.role ?? 'staff') as StaffRole,
      };

      setUser(nextUser);
      setToken(data.session.access_token);
      localStorage.setItem('auth_token', data.session.access_token);
      localStorage.setItem('user', JSON.stringify(nextUser));
      return { user: nextUser, token: data.session.access_token };
    } catch (err: any) {
      const message = err.message || 'Login error';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const signup = useCallback(async (credentials: SignUpCredentials) => {
    setLoading(true);
    setError(null);
    try {
      const { data, error } = await supabase.auth.signUp({
        email: credentials.email,
        password: credentials.password,
        options: {
          data: {
            name: credentials.name,
            role: credentials.role,
          },
        },
      });

      if (error || !data.session || !data.user) {
        throw new Error(error?.message || 'Signup failed');
      }

      const nextUser = {
        id: data.user.id,
        email: data.user.email ?? credentials.email,
        name: data.user.user_metadata?.name ?? credentials.name,
        role: (data.user.user_metadata?.role ?? credentials.role) as StaffRole,
      };

      setUser(nextUser);
      setToken(data.session.access_token);
      localStorage.setItem('auth_token', data.session.access_token);
      localStorage.setItem('user', JSON.stringify(nextUser));
      return { user: nextUser, token: data.session.access_token };
    } catch (err: any) {
      const message = err.message || 'Signup error';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    setLoading(true);
    try {
      await supabase.auth.signOut();
      setUser(null);
      setToken(null);
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  const restoreSession = useCallback(async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (session?.access_token) {
      setToken(session.access_token);
      setUser({
        id: session.user.id,
        email: session.user.email ?? '',
        name: session.user.user_metadata?.name ?? session.user.email ?? '',
        role: (session.user.user_metadata?.role ?? 'staff') as StaffRole,
      });
      localStorage.setItem('auth_token', session.access_token);
      localStorage.setItem('user', JSON.stringify({
        id: session.user.id,
        email: session.user.email ?? '',
        name: session.user.user_metadata?.name ?? session.user.email ?? '',
        role: (session.user.user_metadata?.role ?? 'staff') as StaffRole,
      }));
    }
  }, []);

  return {
    user,
    token,
    loading,
    error,
    login,
    signup,
    logout,
    restoreSession,
  };
};
