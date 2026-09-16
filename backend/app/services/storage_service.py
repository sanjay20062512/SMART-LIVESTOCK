import uuid
import mimetypes
from typing import Optional
from app.core.config import settings
from app.db.supabase import get_supabase_client

BUCKET_NAME = "livestock-media"


class StorageService:
    @staticmethod
    def ensure_bucket_exists():
        """Ensure the livestock-media bucket exists and is public."""
        supabase = get_supabase_client()
        if not supabase:
            return False
        try:
            buckets = supabase.storage.list_buckets()
            bucket_names = [b.name if hasattr(b, 'name') else b.get('name') for b in buckets]
            if BUCKET_NAME not in bucket_names:
                supabase.storage.create_bucket(BUCKET_NAME, options={"public": True})
            return True
        except Exception as e:
            print(f"[StorageService] Warning checking/creating bucket: {e}")
            return False

    @staticmethod
    def upload_file(
        file_bytes: bytes,
        file_name: str,
        folder: str = "general",
        content_type: Optional[str] = None,
    ) -> Optional[str]:
        """
        Uploads file bytes to Supabase Storage under folder/unique_filename
        and returns the permanent public URL.
        """
        supabase = get_supabase_client()
        if not supabase:
            print("[StorageService] Supabase client not available")
            return None

        StorageService.ensure_bucket_exists()

        ext = ""
        if "." in file_name:
            ext = "." + file_name.rsplit(".", 1)[1].lower()

        unique_id = uuid.uuid4().hex[:10]
        storage_path = f"{folder}/{unique_id}{ext}"

        if not content_type:
            content_type, _ = mimetypes.guess_type(file_name)
            content_type = content_type or "application/octet-stream"

        try:
            supabase.storage.from_(BUCKET_NAME).upload(
                path=storage_path,
                file=file_bytes,
                file_options={"content-type": content_type, "upsert": "true"},
            )
            # Fetch public URL
            public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(storage_path)
            # Normalize if dict or string
            if isinstance(public_url, dict) and "publicUrl" in public_url:
                return public_url["publicUrl"]
            return str(public_url)
        except Exception as e:
            print(f"[StorageService] Upload failed for {storage_path}: {e}")
            return f"{settings.SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{storage_path}"
