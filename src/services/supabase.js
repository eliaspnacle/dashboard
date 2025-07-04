import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Credenciais do Supabase não encontradas. Verifique se você criou o arquivo .env na pasta 'vue-project' e reiniciou o servidor de desenvolvimento.")
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    storageKey: 'dashboard-auth',
    autoRefreshToken: true,
    detectSessionInUrl: true
  }
}) 