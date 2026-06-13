import { useCallback, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { StaffRole } from '../types';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface SignUpCredentials {
  email: string;
  password: string;
  name: string;
  role: StaffRole;
  department?: string;
  unit?: string;
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: StaffRole;
  department?: string | null;
  unit?: string | null;
}

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
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

      if (error) throw error;

      if (!data.user) {
        throw new Error('User not found');
      }

      const { data: profile, error: profileError } = await supabase
        .from('users')
        .select('*')
        .eq('id', data.user.id)
        .single();

      if (profileError) throw profileError;

      const userData: User = {
        id: data.user.id,
        email: data.user.email ?? '',
        name: profile.name,
        role: profile.role,
        department: profile.department,
        unit: profile.unit,
      };

      setUser(userData);

      return {
        user: userData,
        session: data.session,
      };
    } catch (err: any) {
      const message = err?.message ?? 'Login failed';
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
            department: credentials.department,
            unit: credentials.unit,
          },
        },
      });

      if (error) throw error;

      if (!data.user) {
        throw new Error('Signup failed');
      }

      const { error: insertError } = await supabase
        .from('users')
        .insert({
          id: data.user.id,
          email: credentials.email,
          name: credentials.name,
          role: credentials.role,
          department: credentials.department ?? null,
          unit: credentials.unit ?? null,
        });

      if (insertError) throw insertError;

      const userData: User = {
        id: data.user.id,
        email: credentials.email,
        name: credentials.name,
        role: credentials.role,
        department: credentials.department ?? null,
        unit: credentials.unit ?? null,
      };

      setUser(userData);

      return {
        user: userData,
        session: data.session,
      };
    } catch (err: any) {
      const message = err?.message ?? 'Signup failed';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    await supabase.auth.signOut();
    setUser(null);
  }, []);

  const restoreSession = useCallback(async () => {
    try {
      const {
        data: { session },
      } = await supabase.auth.getSession();

      if (!session?.user) {
        setUser(null);
        return;
      }

      const { data: profile, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', session.user.id)
        .single();

      if (error) throw error;

      setUser({
        id: session.user.id,
        email: session.user.email ?? '',
        name: profile.name,
        role: profile.role,
        department: profile.department,
        unit: profile.unit,
      });
    } catch (err) {
      console.error(err);
      setUser(null);
    }
  }, []);

  return {
    user,
    loading,
    error,
    login,
    signup,
    logout,
    restoreSession,
  };
};