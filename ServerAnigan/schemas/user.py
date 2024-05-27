from sqlalchemy import  Column, String, TIMESTAMP
from config import Base

class User(Base):
    __tablename__ ="app_user"

    id = Column(String, primary_key=True, index=True)
    username = Column(String)
    email = Column(String)
    first_name = Column(String)
    last_name = Column(String)
    user_type = Column(String)
    created_at = Column(TIMESTAMP, index=True)
    updated_at = Column(TIMESTAMP, index=True)