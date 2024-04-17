from fastapi import APIRouter

router = APIRouter()

@router.get("/", tags=["splash"])
def read_root():
    return {"Name": "I am Anigan server"}