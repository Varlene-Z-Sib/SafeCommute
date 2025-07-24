import json
from pathlib import Path
from math import radians, cos, sin, sqrt, atan2

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