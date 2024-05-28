from sqlalchemy.orm import Session
from schemas.user import User
from datetime import datetime

class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_all_users(self):
        """
        Retrieve all users from the database.
        """
        return self.db.query(User).all()

    def get_user_by_id(self, user_id: str):
        """
        Retrieve a user by their ID.
        """
        return self.db.query(User).filter(User.id == user_id).first()

    def get_user_by_email(self, email: str):
        """
        Retrieve a user by their email.
        """
        return self.db.query(User).filter(User.email == email).first()

    def create_user(self, username: str, email: str, first_name: str, last_name: str, user_type: str, id: str):
        """
        Create a new user in the database.
        """
        user = User(
            username=username,
            email=email,
            first_name=first_name,
            last_name=last_name,
            user_type=user_type,
            id=id,
            created_at=datetime.now().isoformat(),
            updated_at=datetime.now().isoformat()
        )
        self.db.add(user)
        self.db.commit()
        return user

    def update_user(self, user_id: str, username: str, email: str, first_name: str, last_name: str, user_type: str):
        """
        Update an existing user in the database.
        """
        user = self.get_user_by_id(user_id)
        if user:
            user.username = username
            user.email = email
            user.first_name = first_name
            user.last_name = last_name
            user.user_type = user_type
            self.db.commit()
        return user

    def delete_user(self, user_id: str):
        """
        Delete a user from the database.
        """
        user = self.get_user_by_id(user_id)
        if user:
            self.db.delete(user)
            self.db.commit()