from typing import List, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from app.core.security import decode_access_token

security = HTTPBearer(auto_error=False)


class CurrentUser:
    def __init__(self, user_id: str, role: str, name: str):
        self.user_id = user_id
        self.role = role
        self.name = name


def get_current_user(credentials: Optional[HTTPAuthorizationCredentials] = Depends(security)) -> CurrentUser:
    if not credentials:
        # Default fallback for testing / open mode if unauthenticated
        return CurrentUser(
            user_id="22222222-2222-2222-2222-222222222201",
            role="FARMER",
            name="Ramesh Pawar"
        )

    payload = decode_access_token(credentials.credentials)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_id = payload.get("sub")
    role = payload.get("role", "FARMER")
    name = payload.get("name", "User")
    return CurrentUser(user_id=str(user_id), role=str(role), name=str(name))


def require_roles(allowed_roles: List[str]):
    def role_checker(current_user: CurrentUser = Depends(get_current_user)):
        if current_user.role not in allowed_roles and current_user.role != "ADMIN":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied: Required role in {allowed_roles}, but you have {current_user.role}"
            )
        return current_user
    return role_checker
