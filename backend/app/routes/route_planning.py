# backend/app/routes/route_planning.py

import os
import requests
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Set, Tuple
from dotenv import load_dotenv
import re
from pathlib import Path

from backend.app.services import station_service

# --- dotenv loading explicitly ---
BASE_DIR = Path(__file__).resolve().parents[1]  # backend/app/ -> backend/
dotenv_path = BASE_DIR / ".env"
load_dotenv(dotenv_path=dotenv_path)

# --- configuration ---
router = APIRouter()
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")

# --- Models ---
class Coord(BaseModel):
    lat: float
    lng: float

class SafetyReportSummary(BaseModel):
    type: str
    description: str
    time_ago: str
    severity: str

class RouteOption(BaseModel):
    id: str
    duration: str
    distance: str
    cost: str
    eta: str
    transport_types: List[str]
    safety_level: str
    safety_rating: float
    route_points: List[Coord]
    recent_reports: List[SafetyReportSummary]

class RouteRequest(BaseModel):
    origin: Coord
    destination: Coord
    preference: Optional[str] = "safest"  # "safest" or "fastest"
    transport_types: Optional[List[str]] = None  # e.g. ["taxi", "bus"]

# --- Safety scoring helpers ---
SAFETY_LEVEL_SCORE = {
    "green": 5.0,
    "yellow": 3.0,
    "orange": 2.0,
    "red": 1.0,
    "unknown": 2.5
}

def parse_duration_to_minutes(text: str) -> float:
    m_hours = re.search(r'(\d+)\s*hour', text)
    m_mins = re.search(r'(\d+)\s*min', text)
    total = 0.0
    if m_hours:
        total += float(m_hours.group(1)) * 60
    if m_mins:
        total += float(m_mins.group(1))
    if total == 0:
        digits = re.findall(r'(\d+)', text)
        if digits:
            total = float(digits[0])
    return total

def compute_combined_safety(
    base_safety_rating: float,
    route_points: List[Coord],
    preference: str
) -> Tuple[float, str]:
    station_scores = []
    for pt in route_points:
        nearby = station_service.get_nearby_stations(pt.lat, pt.lng, radius_km=0.5)
        if not nearby:
            continue
        scores = []
        for s in nearby[:3]:
            level = s.get("safety_level", "unknown").lower()
            scores.append(SAFETY_LEVEL_SCORE.get(level, SAFETY_LEVEL_SCORE["unknown"]))
        if scores:
            station_scores.append(sum(scores) / len(scores))
    station_component = sum(station_scores) / len(station_scores) if station_scores else base_safety_rating

    if preference.lower() == "safest":
        combined = (station_component * 0.7) + (base_safety_rating * 0.3)
    elif preference.lower() == "fastest":
        combined = (base_safety_rating * 0.7) + (station_component * 0.3)
    else:
        combined = (station_component + base_safety_rating) / 2

    combined = max(1.0, min(5.0, combined))

    if combined >= 4.5:
        level = "green"
    elif combined >= 3.0:
        level = "yellow"
    else:
        level = "red"
    return combined, level

# --- Endpoint ---
@router.post("/routes", response_model=List[RouteOption])
def get_routes(req: RouteRequest):
    if not GOOGLE_MAPS_API_KEY:
        raise HTTPException(status_code=500, detail="Missing Google Maps API Key")

    try:
        origin_str = f"{req.origin.lat},{req.origin.lng}"
        destination_str = f"{req.destination.lat},{req.destination.lng}"

        # Call Google Directions API
        url = "https://maps.googleapis.com/maps/api/directions/json"
        params = {
            "origin": origin_str,
            "destination": destination_str,
            "key": GOOGLE_MAPS_API_KEY,
            "alternatives": "true",
            "mode": "transit"
        }
        resp = requests.get(url, params=params, timeout=10)
        data = resp.json()

        if data.get("status") != "OK":
            detail = data.get("error_message") or data.get("status")
            raise HTTPException(status_code=400, detail=f"Google API error: {detail}")

        # Normalize transport_types filter
        allowed_transports: Optional[Set[str]] = None
        if req.transport_types:
            allowed_transports = set(t.lower() for t in req.transport_types)

        raw_routes: List[RouteOption] = []
        for i, route in enumerate(data.get("routes", [])):
            legs = route.get("legs", [])
            if not legs:
                continue
            leg = legs[0]
            duration = leg.get("duration", {}).get("text", "Unknown")
            distance = leg.get("distance", {}).get("text", "Unknown")
            eta = leg.get("arrival_time", {}).get("text", "Unknown")

            steps = leg.get("steps", [])
            points: List[Coord] = []
            step_modes = set()
            for s in steps:
                end_loc = s.get("end_location", {})
                if "lat" in end_loc and "lng" in end_loc:
                    points.append(Coord(lat=end_loc["lat"], lng=end_loc["lng"]))
                mode = s.get("travel_mode", "WALKING").lower()
                step_modes.add(mode)

            if allowed_transports is not None and step_modes.isdisjoint(allowed_transports):
                continue  # skip route that doesn't include any allowed mode

            base_safety = max(1.0, 5.0 - i * 1.0)
            combined_rating, safety_level = compute_combined_safety(
                base_safety_rating=base_safety,
                route_points=points,
                preference=req.preference or "safest",
            )

            transport_types_list = list(step_modes)
            if allowed_transports is not None:
                transport_types_list = [t for t in transport_types_list if t in allowed_transports]

            raw_routes.append(RouteOption(
                id=f"route_{i+1}",
                duration=duration,
                distance=distance,
                cost="Free",
                eta=eta,
                transport_types=transport_types_list,
                safety_level=safety_level,
                safety_rating=combined_rating,
                route_points=points,
                recent_reports=[],
            ))

        if not raw_routes:
            raise HTTPException(status_code=404, detail="No routes matched filters/preferences")

        # Sort based on preference
        pref = (req.preference or "").lower()
        if pref == "fastest":
            raw_routes.sort(key=lambda r: parse_duration_to_minutes(r.duration))
        elif pref == "safest":
            raw_routes.sort(key=lambda r: -r.safety_rating)

        return raw_routes

    except HTTPException:
        raise
    except Exception as e:
        print("Route planning failure:", e)
        raise HTTPException(status_code=500, detail=str(e))
