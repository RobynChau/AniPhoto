from sqlalchemy import create_engine, Column, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

FREE_QUOTA = 5
EXPIRED_FREE_QUOTA_DAYS = 10000
REMOTE_DB = 'postgresql://keycloak-vhuynh_owner:1hqSFDyBLgj3@ep-late-tree-a1oy2h84.ap-southeast-1.aws.neon.tech/keycloak-vhuynh?sslmode=require&options=endpoint%3Dep-late-tree-a1oy2h84'

DATABASE_URL = os.getenv("DATABASE_URL", REMOTE_DB)
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush = False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()