import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

type Todo = {
  id: string;
  name: string;
};

export default function Page() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchTodos = async () => {
      try {
        const { data, error } = await supabase
          .from('todos')
          .select('id, name');

        if (error) {
          console.error('Supabase error:', error);
          setError(error.message);
          return;
        }

        setTodos(data || []);
      } catch (err) {
        console.error('Unexpected error:', err);
        setError('Failed to connect to Supabase');
      } finally {
        setLoading(false);
      }
    };

    void fetchTodos();
  }, []);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return (
      <div>
        <h2>Error</h2>
        <pre>{error}</pre>
      </div>
    );
  }

  return (
    <div>
      <h1>Todos</h1>

      {todos.length === 0 ? (
        <p>No todos found.</p>
      ) : (
        <ul>
          {todos.map((todo) => (
            <li key={todo.id}>{todo.name}</li>
          ))}
        </ul>
      )}
    </div>
  );
}