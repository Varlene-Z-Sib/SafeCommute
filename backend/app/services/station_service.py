import json
from pathlib import Path
from math import radians, cos, sin, sqrt, atan2
from collections import Counter

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

def get_all_stations():
    return load_stations()


def search_stations_by_name(name: str):
    stations = load_stations()
    filtered = [station for station in stations if name.lower() in station["name"].lower()]
    return filtered

# Haversine formula to calculate distance in kilometers
def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in km
    d_lat = radians(lat2 - lat1)
    d_lon = radians(lon2 - lon1)
    a = sin(d_lat / 2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(d_lon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

def get_nearby_stations(lat: float, lng: float, radius_km: float = 3.0):
    stations = load_stations()
    nearby = []
    for station in stations:
        distance = haversine(lat, lng, station["lat"], station["lng"])
        if distance <= radius_km:
            station["distance_km"] = round(distance, 2)
            nearby.append(station)
    # Optional: sort by distance
    nearby.sort(key=lambda s: s["distance_km"])
    return nearby

def get_stations_by_safety_level(level: str):
    stations = load_stations()
    return [station for station in stations if station.get("safety_level") == level.lower()]

def get_station_summary():
    stations = load_stations()
    total = len(stations)
    types = Counter(station.get("type") for station in stations)
    safety_levels = Counter(station.get("safety_level") for station in stations)

    return {
        "total_stations": total,
        "by_type": dict(types),
        "by_safety_level": dict(safety_levels)
    }

def get_safest_nearby_station(lat: float, lng: float):
    safety_order = {"green": 1, "yellow": 2, "orange": 3, "red": 4}
    stations = load_stations()

    sorted_stations = sorted(
        stations,
        key=lambda s: (
            safety_order.get(s.get("safety_level"), 5),
            haversine(lat, lng, s["lat"], s["lng"])
        )
    )

    if not sorted_stations:
        return None

    best_station = sorted_stations[0]
    best_station["distance_km"] = round(haversine(lat, lng, best_station["lat"], best_station["lng"]), 2)
    return best_station


