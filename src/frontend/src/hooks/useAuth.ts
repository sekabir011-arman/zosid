import { useCallback, useState } from 'react';
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
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const API_URL = import.meta.env.VITE_API_URL;

  const login = useCallback(async (credentials: LoginCredentials) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(credentials),
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Login failed');
      }

      setUser(result.user);
      setToken(result.token);

      localStorage.setItem('auth_token', result.token);
      localStorage.setItem('user', JSON.stringify(result.user));

      return result;
    } catch (err: any) {
      const message = err.message || 'Login error';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [API_URL]);

  const signup = useCallback(async (credentials: SignUpCredentials) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`${API_URL}/auth/signup`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(credentials),
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Signup failed');
      }

      setUser(result.user);
      setToken(result.token);

      localStorage.setItem('auth_token', result.token);
      localStorage.setItem('user', JSON.stringify(result.user));

      return result;
    } catch (err: any) {
      const message = err.message || 'Signup error';
      setError(message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [API_URL]);

  const logout = useCallback(async () => {
    setUser(null);
    setToken(null);

    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
  }, []);

  const restoreSession = useCallback(() => {
    try {
      const storedToken = localStorage.getItem('auth_token');
      const storedUser = localStorage.getItem('user');

      if (!storedToken || !storedUser) {
        return;
      }

      setToken(storedToken);
      setUser(JSON.parse(storedUser));
    } catch {
      localStorage.removeItem('auth_token');
      localStorage.removeItem('user');
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