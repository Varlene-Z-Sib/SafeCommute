import json
from pathlib import Path

data_path = Path(__file__).parent.parent / "data" / "stations.json"

def load_stations():
    with open(data_path, "r", encoding="utf-8") as f:
        return json.load(f)

def get_station_by_id(station_id: str):
    stations = load_stations()
    for station in stations:
        if station.get("id") == station_id:
            return station
    return None
