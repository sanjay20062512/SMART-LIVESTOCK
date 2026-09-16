from typing import Optional
from fastapi import APIRouter, Depends
from app.core.dependencies import CurrentUser, get_current_user
from app.db.supabase import get_supabase_client

router = APIRouter(prefix="/alerts", tags=["Alerts & Notifications"])


@router.get("")
def list_alerts(
    role: Optional[str] = None,
    current_user: CurrentUser = Depends(get_current_user),
):
    """
    List alerts for the current user.
    - Pass ?role=veterinarian to get vet-targeted alerts.
    - Pass ?role=farmer to get farmer-targeted alerts.
    - Without role param, returns alerts for the current user's role.
    """
    supabase = get_supabase_client()
    if not supabase:
        return []

    target_role = (role or current_user.role).upper()

    try:
        res = (
            supabase.table("alerts")
            .select("*")
            .or_(f"target_role.eq.{target_role},target_role.is.null")
            .order("created_at", desc=True)
            .limit(50)
            .execute()
        )
        return res.data or []
    except Exception as e:
        import logging
        logging.warning(f"Error fetching alerts: {e}")
        return []


@router.patch("/{alert_id}/read")
def mark_alert_read(
    alert_id: str,
    current_user: CurrentUser = Depends(get_current_user),
):
    """Mark a specific alert as read."""
    supabase = get_supabase_client()
    if not supabase:
        return {"ok": False}
    try:
        supabase.table("alerts").update({"is_read": True}).eq("id", alert_id).execute()
        return {"ok": True}
    except Exception:
        return {"ok": False}
