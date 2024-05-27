from typing import Annotated

from fastapi.security import OAuth2AuthorizationCodeBearer
from fastapi import Security, Header, HTTPException, status, Depends
from services.user_service import UserService
from services.user_session_service import UserSessionService
from services.device_service import DeviceService

import jwt
from config import get_db
from sqlalchemy.orm import Session
from helpers.register_device import register_device

oauth2_scheme = OAuth2AuthorizationCodeBearer(
    authorizationUrl= "https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/auth",
    tokenUrl="https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/token",
    auto_error=True
)

oauth2_scheme_not_auto = OAuth2AuthorizationCodeBearer(
    authorizationUrl= "https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/auth",
    tokenUrl="https://keycloak.vohuynh19.info/realms/ios-entertainment-photography/protocol/openid-connect/token",
    auto_error=False
)

public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn4mjiau2Ko9KCLPH6BdVUw8RMf8yjQTqh8p7ZledBByvJKDDoEx7KR/Al/FYlOxg6C0hS4DyD3TtGankE03YKTeSqClSbBU7YRNMpyDT7JcUi7wyqOdgsNfEc7/N5e8rNMAavPw3kj8I7RkXKNo3iCrTrwIE20nANwoHTLva3sxfBnqQqZV4XWgcxwmDTidl0LOvwjFYuRMXT2vIndjkNND5l4luhV55QwF+FGjmH+vOgtxxm4qB50gxarlNTpUTvt9Q9i3lU9iuqVMbXkksSqzK8OfatmcB8K9UPVEvR8Hx8o3Igs4UuwOsdP4m6qlbXqGoLHT0kgiGgfnXm/u8LwIDAQAB"

async def get_device_id(device_id: str = Header("device-id")):
    """
    Dependency that requires a device_id.

    Args:
        device_id (str): The device_id obtained from the "device-id" header.

    Returns:
        dict: A dictionary containing the device_id.
    """
    return {"device_id": device_id}

async def get_payload_optional_token(
    token: str = Security(oauth2_scheme_not_auto), 
    device_id_dependency: dict = Depends(get_device_id),
    db: Session = Depends(get_db)
) -> dict:
    """
    Dependency that requires a device_id and optionally a token.

    Args:
        token (str): The token obtained from the oauth2_scheme.
        device_id_dependency (dict): The device_id obtained from the "device-id" header.

    Returns:
        dict: A dictionary containing the decoded payload (if token is provided) and the device_id.
    """
    user_service = UserService(db)
    user_session_service = UserSessionService(db)
    device_service = DeviceService(db)
    public_key = get_idp_public_key()
    device_id = device_id_dependency["device_id"]

    # Match device
    device = device_service.get_device_by_id(device_id)
    if device == None:
        device = register_device(device_id, db)

    if token:
        decoded = jwt.decode(
            token, 
            public_key, 
            algorithms=['RS256'],
            options={"verify_aud": False, "verify_signature": True}
        )
        decoded_user_id = decoded.get("sub")
        
        # Match the user_id
        match_user = user_service.get_user_by_id(decoded_user_id)
        if match_user == None:
            match_user = user_service.create_user( 
                decoded.get("preferred_username"),
                decoded.get("email"),
                decoded.get("given_name"),
                decoded.get("family_name"),
                'NORMAL',
                decoded_user_id
            )
        
        # Match session by device id 
        session = user_session_service.get_active_user_session_by_device_id(device.id)

        if session == None:
            session = user_session_service.create_user_session(device.id, 'ACTIVE', decoded_user_id)
        else:
            if(session.user_id != match_user.id):
                user_session_service.deactive_session(session.id)
                session = user_session_service.create_user_session(device.id, 'ACTIVE', decoded_user_id)

        try:
            decoded = jwt.decode(
                token, 
                public_key, 
                algorithms=['RS256'],
                options={"verify_aud": False, "verify_signature": True}
            )
            return {
                "session": session,
                "user": match_user,
                "device_id": device.id
            }
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=str(e), # "Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
    else: 
        # Match session by device id 
        session = user_session_service.get_active_user_session_by_device_id(device.id)
        if session == None:
            session = user_session_service.create_user_session(device.id, 'ACTIVE', None)
        else:
            if(session.user_id != None):
                user_session_service.deactive_session(session.id)
                session = user_session_service.create_user_session(device.id, 'ACTIVE', None)
        return {
            'session': session, 
            "user": None,
            "device_id": device.id
        }
    

async def get_payload(
    token: str = Security(oauth2_scheme),
    device_id: str = Header("device-id"),
    db: Session = Depends(get_db)
) -> dict:
    """
    Dependency that requires a valid token and a device_id.

    Args:
        token (str): The token obtained from the oauth2_scheme.
        device_id (str): The device_id obtained from the "device-id" header.

    Returns:
        dict: A dictionary containing the decoded payload and the device_id.
    """
    public_key = get_idp_public_key()
    user_service = UserService(db)
    user_session_service = UserSessionService(db)
    device_service = DeviceService(db)

    # Match device
    device = device_service.get_device_by_id(device_id)
    if device == None:
        register_device(device_id, db)

    try:
        decoded = jwt.decode(
            token, 
            public_key, 
            algorithms=['RS256'],
            options={"verify_aud": False, "verify_signature": True}
        )
        decoded_user_id = decoded.get("sub")
        
        # Match the user_id
        match_user = user_service.get_user_by_id(decoded_user_id)
        if match_user == None:
            match_user = user_service.create_user( 
                decoded.get("preferred_username"),
                decoded.get("email"),
                decoded.get("given_name"),
                decoded.get("family_name"),
                'NORMAL',
                decoded_user_id
            )

        # Match session by device id 
        session = user_session_service.get_active_user_session_by_device_id(device.id)

        if session == None:
            session = user_session_service.create_user_session(device.id, 'ACTIVE', decoded_user_id)
        else:
            if(session.user_id != match_user.id):
                user_session_service.deactive_session(session.id)
                session = user_session_service.create_user_session(device.id, 'ACTIVE', decoded_user_id)

        return {
            "session": session,
            "user": match_user,
            "device_id": device.id
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e), # "Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
async def get_token_header(x_token: Annotated[str, Header()]):
    if x_token != "fake-super-secret-token":
        raise HTTPException(status_code=400, detail="X-Token header invalid")

def get_idp_public_key():
    return f"-----BEGIN PUBLIC KEY-----\n{public_key}\n-----END PUBLIC KEY-----"