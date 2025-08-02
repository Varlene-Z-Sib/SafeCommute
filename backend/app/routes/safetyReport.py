import os
import json
from fastapi import APIRouter, HTTPException, Form, File, UploadFile
from pydantic import BaseModel
from typing import Optional
from pathlib import Path
from datetime import datetime
from backend.app.services import safetyReport_service

router = APIRouter()

# ensure upload directory exists
UPLOAD_DIR = Path(__file__).parent.parent / "uploads"
UPLOAD_DIR.mkdir(exist_ok=True)


class SafetyReportPayload(BaseModel):
    station_id: str
    type: str
    description: str
    severity: str = "medium"
    anonymous: bool = False
    user_id: Optional[str] = None
    location_id: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None


@router.post("/safety-reports/with-image")
async def create_report_with_image(
    station_id: str = Form(...),
    type: str = Form(...),
    description: str = Form(...),
    severity: str = Form("medium"),
    anonymous: bool = Form(False),
    user_id: Optional[str] = Form(None),
    location_id: Optional[str] = Form(None),
    lat: Optional[float] = Form(None),
    lng: Optional[float] = Form(None),
    image: UploadFile = File(...)
):
    # save image with a unique name (timestamp + original)
    timestamp = int(datetime.utcnow().timestamp() * 1000)
    safe_name = image.filename.replace(" ", "_")
    filename = f"{timestamp}_{safe_name}"
    dest = UPLOAD_DIR / filename

    content = await image.read()
    with open(dest, "wb") as f:
        f.write(content)

    incident = safetyReport_service.add_incident(
        station_id=station_id,
        incident_type=type,
        description=description,
        severity=severity,
        anonymous=anonymous,
        user_id=user_id,
        location_id=location_id,
        lat=lat,
        lng=lng,
    )

    # attach image reference and persist update
    incident["image_filename"] = filename

    # reload all, replace the incident, and save back
    data_file = Path(__file__).parent.parent / "data" / "safetyReport.json"
    all_reports = safetyReport_service.get_all_incidents()
    for i, r in enumerate(all_reports):
        if r.get("id") == incident.get("id"):
            all_reports[i] = incident
            break

    with open(data_file, "w", encoding="utf-8") as f:
        json.dump(all_reports, f, indent=2)

    return {"message": "Report recorded with image", "incident": incident}


@router.post("/safety-reports")
def create_report(payload: SafetyReportPayload):
    incident = safetyReport_service.add_incident(
        station_id=payload.station_id,
        incident_type=payload.type,
        description=payload.description,
        severity=payload.severity,
        anonymous=payload.anonymous,
        user_id=payload.user_id,
        location_id=payload.location_id,
        lat=payload.lat,
        lng=payload.lng,
    )
    return {"message": "Report recorded", "incident": incident}


@router.get("/safety-reports/user/{user_id}")
def get_reports_by_user(user_id: str):
    reports = safetyReport_service.get_incidents_by_user(user_id)
    if not reports:
        raise HTTPException(status_code=404, detail="No reports found for this user")
    return reports


@router.get("/safety-reports/location/{location_id}")
def get_reports_by_location(location_id: str):
    reports = safetyReport_service.get_incidents_by_location(location_id)
    if not reports:
        raise HTTPException(status_code=404, detail="No reports found at this location")
    return reports


@router.get("/safety-reports/unresolved")
def get_unresolved_reports():
    reports = safetyReport_service.get_unresolved_incidents()
    if not reports:
        raise HTTPException(status_code=404, detail="No unresolved reports found")
    return reports


@router.get("/safety-reports/unresolved/location/{location_id}")
def get_unresolved_reports_by_location(location_id: str):
    reports = safetyReport_service.get_unresolved_incidents_by_location(location_id)
    if not reports:
        raise HTTPException(status_code=404, detail="No unresolved reports found at this location")
    return reports


@router.get("/safety-reports")
def get_all_incidents():
    return safetyReport_service.get_all_incidents()
