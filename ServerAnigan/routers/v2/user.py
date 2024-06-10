from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ...services.user_service import UserService
from ...schemas.user import User
from ...schemas.user_session import UserSession
from ...config import get_db
from ...dependencies import get_payload

router = APIRouter(
    prefix="/user",
    tags=["user"]
)   

@router.get("/")
def get_user(data = Depends(get_payload)):
    user: User = data.get('user')
    return user

@router.get("/session")
def get_user(data = Depends(get_payload)):
    session: UserSession = data.get('session')
    return session

@router.put("/")
def update_user(username: str, email: str, first_name: str, last_name: str, user_type: str, data = Depends(get_payload), db: Session = Depends(get_db)):
    user: User = data.get('user')
    user_service = UserService(db)
    user = user_service.update_user(user.id, username, email, first_name, last_name, user_type)
    return user