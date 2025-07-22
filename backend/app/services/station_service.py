import json
from pathlib import Path

def get_all_stations():
    data_path = Path(__file__).parent.parent / "data" / "stations.json"
    with open(data_path, "r", encoding="utf-8") as f:
        stations = json.load(f)
    return stations
print(get_all_stations())