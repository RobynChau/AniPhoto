from pydantic import BaseModel

class GenerateAnimeBody(BaseModel):
    source_img_path: str