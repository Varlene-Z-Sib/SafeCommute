from fastapi import APIRouter, HTTPException, Query
from backend.app.services import safetyReport_service

router = APIRouter()

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