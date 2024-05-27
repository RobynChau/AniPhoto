from sqlalchemy.orm import Session
from sqlalchemy import and_
from schemas.user_session import UserSession
from datetime import datetime

class UserSessionService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_user_sessions(self):
        """
        Retrieve all user sessions.
        """
        return self.db.query(UserSession).all()

    def get_user_session_by_id(self, session_id: str):
        """
        Retrieve a user session by its ID.
        """
        return self.db.query(UserSession).filter(UserSession.id == session_id).first()

    def get_user_sessions_by_user_id(self, user_id: str):
        """
        Retrieve all user sessions for a given user.
        """
        return self.db.query(UserSession).filter(UserSession.user_id == user_id).all()

    def get_user_sessions_by_device_id(self, device_id: str):
        return self.db.query(UserSession).filter(UserSession.device_id == device_id).all()
    
    def get_active_user_sessions_by_device_id(self, device_id: str):
        return self.db.query(UserSession).filter(and_(
            UserSession.device_id == device_id,
            UserSession.status == 'ACTIVE'
        )).all()
    
    def get_user_session_by_device_id(self, device_id: str):
        return self.db.query(UserSession).filter(UserSession.device_id == device_id).first()

    def get_active_user_session_by_device_id(self, device_id: str):
        return self.db.query(UserSession).filter(and_(
            UserSession.device_id == device_id,
            UserSession.status == 'ACTIVE'
        )).first()

    def create_user_session(self, device_id: str, status: str, user_id: str | None):
        """
        Create a new user session.
        """
        now = datetime.now().isoformat()
        user_session = UserSession(
            id=f"{user_id}_{now}",
            device_id=device_id,
            status=status,
            user_id=user_id,
            created_at=now,
            updated_at=now
        )
        self.db.add(user_session)
        self.db.commit()
        self.db.refresh(user_session)
        return user_session

    def deactive_session(self, session_id: str):
        """
        Update an existing user session.
        """
        user_session = self.get_user_session_by_id(session_id)
        if user_session:
            user_session.status = 'DEACTIVED'
            user_session.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(user_session)
        return user_session
    
    def update_user_session(self, session_id: str, device_id: str, status: str):
        """
        Update an existing user session.
        """
        user_session = self.get_user_session_by_id(session_id)
        if user_session:
            user_session.device_id = device_id
            user_session.status = status
            user_session.updated_at = datetime.now().isoformat()
            self.db.commit()
            self.db.refresh(user_session)
        return user_session

    def delete_user_session(self, session_id: str):
        """
        Delete a user session.
        """
        user_session = self.get_user_session_by_id(session_id)
        if user_session:
            self.db.delete(user_session)
            self.db.commit()