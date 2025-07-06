from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json
from pathlib import Path

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/stations")
def get_stations():
    data_path = Path(__file__).parent / "data" / "stations.json"
    with open(data_path, "r") as f:
        stations = json.load(f)
    return stations
