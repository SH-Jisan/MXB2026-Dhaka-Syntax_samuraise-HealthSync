import { supabase } from '@/shared/lib/supabaseClient';

export const api = {
    // Auth helpers
    auth: {
        getUser: async () => {
            const { data: { user }, error } = await supabase.auth.getUser();
            if (error) throw error;
            return user;
        },
        getSession: async () => {
            const { data: { session }, error } = await supabase.auth.getSession();
            if (error) throw error;
            return session;
        }
    },
    // Add other domains here (e.g. blood, doctor, etc.)
};
