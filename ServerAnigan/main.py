from fastapi import FastAPI
from routers import splash
from routers.v2 import user as userV2,  images, ml, quota, subscription, history

app = FastAPI()

app.include_router(splash.router)
app.include_router(userV2.router)
app.include_router(images.router)
app.include_router(ml.router)
app.include_router(quota.router)
app.include_router(subscription.router)
app.include_router(history.router)



