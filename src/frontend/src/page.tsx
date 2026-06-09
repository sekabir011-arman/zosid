import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/server';

export default function Page() {
  const [todos, setTodos] = useState<Array<{ id: string; name: string }>>([]);

  useEffect(() => {
    void (async () => {
      const supabase = createClient();
      const { data } = await supabase.from('todos').select('id, name');
      setTodos((data ?? []) as Array<{ id: string; name: string }>);
    })();
  }, []);

  return (
    <ul>
      {todos.map((todo) => (
        <li key={todo.id}>{todo.name}</li>
      ))}
    </ul>
  );
}