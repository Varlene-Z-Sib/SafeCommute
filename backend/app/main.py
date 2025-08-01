from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.app.routes import stations

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(stations.router)
