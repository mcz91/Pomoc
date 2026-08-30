import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';

const url = process.env.EXPO_PUBLIC_SUPABASE_URL;
const anonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  throw new Error(
    'Brak EXPO_PUBLIC_SUPABASE_URL lub EXPO_PUBLIC_SUPABASE_ANON_KEY — uzupełnij .env.local',
  );
}

export const supabase = createClient(url, anonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    // React Native nie ma adresu, z którego Supabase odczytałby token po powrocie.
    detectSessionInUrl: false,
  },
});
