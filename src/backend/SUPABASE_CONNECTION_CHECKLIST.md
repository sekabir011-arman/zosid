# Supabase connection checklist

Use this order to make the backend connect to Supabase reliably.

1. Create or open your Supabase project.
   - Copy the Project URL.
   - Copy the Service Role key (for backend writes).
   - Copy the anon key (for frontend login/session use).

2. Update the backend environment file.
   - Open `src/backend/.env`.
   - Set:
     - `SUPABASE_URL=<your-project-url>`
     - `SUPABASE_SERVICE_KEY=<your-service-role-key>`
   - Optional compatibility aliases:
     - `VITE_SUPABASE_URL=<same-url>`
     - `VITE_SUPABASE_SERVICE_KEY=<same-service-role-key>`

3. Update the frontend environment file.
   - Open `src/frontend/.env.local`.
   - Set:
     - `VITE_SUPABASE_URL=<your-project-url>`
     - `VITE_SUPABASE_ANON_KEY=<your-anon-key>`
   - Keep the `NEXT_PUBLIC_*` values too if you use any SSR helper files.

4. Verify the backend can initialize Supabase.
   - Run:
     - `cd src/backend && pnpm install`
     - `cd src/backend && pnpm dev`
   - The server should start without the "Missing Supabase configuration" error.

5. Verify the public health endpoint.
   - Open: `http://localhost:3000/health`
   - Expected response:
     - `{ "status": "ok" }`

6. Verify the frontend can load Supabase auth.
   - Run:
     - `cd src/frontend && pnpm install`
     - `cd src/frontend && pnpm dev`
   - Confirm the app loads without the "Missing Supabase credentials" error.

7. Test a real write path.
   - Try login or one protected API call.
   - If writes fail, confirm the Supabase RLS policies allow the role used by the request.

8. If the backend still fails, check these exact variables.
   - Backend uses: `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`
   - Frontend uses: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`
   - Compatibility fallbacks now support `NEXT_PUBLIC_*` too.
