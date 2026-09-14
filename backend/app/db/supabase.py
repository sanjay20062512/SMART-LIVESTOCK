from typing import Optional
from app.core.config import settings

_supabase_client = None


def get_supabase_client():
    global _supabase_client
    if _supabase_client is not None:
        return _supabase_client

    if settings.SUPABASE_URL and (settings.SUPABASE_SERVICE_ROLE_KEY or settings.SUPABASE_KEY):
        try:
            from supabase import create_client
            # Use Service Role Key to bypass RLS from backend, fallback to anon key
            key = settings.SUPABASE_SERVICE_ROLE_KEY or settings.SUPABASE_KEY
            _supabase_client = create_client(settings.SUPABASE_URL, key)
            return _supabase_client
        except Exception as e:
            print(f"[Supabase] Client init warning: {e}. Running in local mock DB mode.")
            return None
    return None
