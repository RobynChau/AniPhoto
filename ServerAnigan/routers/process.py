from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

def postprocess_image(image):
    image = image.squeeze(0)
    image = image.detach().cpu()
    image = (image + 1) / 2  # Denormalize the image
    image = transforms.ToPILImage()(image)
    return image

class ProcessImageDataV2(BaseModel):
    source_img_path: str

@router.post("/v2/process-images", tags=["process"])
def process_images(data: ProcessImageDataV2):
    