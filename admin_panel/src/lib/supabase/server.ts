import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL =
  process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://ndjvkzrxgmxsdrbyeyim.supabase.co';
const SUPABASE_KEY =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kanZrenJ4Z214c2RyYnlleWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA1MDE2NTcsImV4cCI6MjEwNjA3NzY1N30.sokDKK8Lnh36oKHt6Yq8_6ImmUXhwJ72FyU0NHsR3w0';

export const supabaseServer = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});
