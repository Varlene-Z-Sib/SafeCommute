import json
from pathlib import Path
from datetime import datetime
from typing import Optional
import os
from fastapi import UploadFile, File, Form
from pathlib import Path
from backend.app.services import safetyReport_service

data_file = Path(__file__).parent.parent / "data" / "safetyReport.json"
UPLOAD_DIR = Path(__file__).parent.parent / "uploads"
UPLOAD_DIR.mkdir(exist_ok=True)

def _load_all():
    if data_file.exists():
        with open(data_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return []

def _save_all(reports):
    with open(data_file, "w", encoding="utf-8") as f:
        json.dump(reports, f, indent=2)

def get_all_incidents():
    return _load_all()

def add_incident(
    station_id: str,
    incident_type: str,
    description: str,
    severity: str = "medium",
    anonymous: bool = False,
    user_id: Optional[str] = None,
    location_id: Optional[str] = None,
    lat: Optional[float] = None,
    lng: Optional[float] = None,
    image: UploadFile = File(...)
):
    reports = _load_all()
    incident = {
        "id": f"inc_{int(datetime.utcnow().timestamp() * 1000)}",
        "station_id": station_id,
        "user_id": user_id,
        "location_id": location_id or station_id,
        "type": incident_type,
        "description": description,
        "severity": severity,
        "anonymous": anonymous,
        "lat": lat,
        "lng": lng,
        "resolved": False,
        "status": "Pending",  # for backwards compatibility with existing filters
        "timestamp": datetime.utcnow().isoformat(),
    }
    reports.append(incident)
    _save_all(reports)
    return incident

def get_incidents_by_user(user_id: str):
    return [r for r in _load_all() if r.get("user_id") == user_id]

def get_incidents_by_location(location_id: str):
    return [
        r for r in _load_all()
        if r.get("location_id") == location_id or r.get("station_id") == location_id
    ]

def get_unresolved_incidents():
    return [r for r in _load_all() if not r.get("resolved", False)]

def get_unresolved_incidents_by_location(location_id: str):
    return [
        r for r in get_unresolved_incidents()
        if r.get("location_id") == location_id or r.get("station_id") == location_id
    ]
