import json
from pathlib import Path
from datetime import datetime
from typing import Optional

# Path to locations.json in /data
data_path = Path(__file__).parent.parent / "data" / "locations.json"

# Ensure file exists
if not data_path.exists():
    with open(data_path, "w", encoding="utf-8") as f:
        json.dump([], f)


def load_locations():
    with open(data_path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_locations(locations):
    with open(data_path, "w", encoding="utf-8") as f:
        json.dump(locations, f, indent=2)


def add_location(lat: float, lng: float, user_id: Optional[str] = None, share: bool = True):
    locations = load_locations()
    entry = {
        "id": f"loc_{int(datetime.utcnow().timestamp() * 1000)}",
        "lat": lat,
        "lng": lng,
        "user_id": user_id,
        "share": share,
        "timestamp": datetime.utcnow().isoformat()
    }
    locations.append(entry)
    save_locations(locations)
    return entry


def get_all_locations():
    return load_locations()


def get_locations_by_user(user_id: str):
    return [loc for loc in load_locations() if loc.get("user_id") == user_id]
