from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import os

from backend.app.routes import stations
from backend.app.routes import areas
from backend.app.routes import userR
from backend.app.routes import safetyReport
from backend.app.routes import route_planning  # <— ensure this is here

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure upload directory exists
UPLOADS_DIR = Path(__file__).parent.parent / "uploads"
UPLOADS_DIR.mkdir(exist_ok=True)

# Ensure data directory exists
DATA_DIR = Path(__file__).parent.parent / "data"
DATA_DIR.mkdir(exist_ok=True)

# Routers
app.include_router(stations.router)
app.include_router(areas.router)
app.include_router(userR.router)
app.include_router(safetyReport.router)
app.include_router(route_planning.router)  # <— route planning mounted

app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")


@app.get("/hello")
async def hello():
    return {"message": "Hello from FastAPI!"}
