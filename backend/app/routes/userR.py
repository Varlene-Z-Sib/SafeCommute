from fastapi import APIRouter, HTTPException, Query
from typing import Dict, Any, List 
from backend.app.services import userR_service 

router = APIRouter()

@router.get("/userR/{area_id}", summary="Get all data sets for a specific area ID")
def get_user_report_data(area_id: str) -> List[Dict[str, Any]]:
    # Changed to call the new service function get_all_area_data_by_id
    report_data = userR_service.get_all_area_data_by_id(area_id)
    if not report_data: 
        raise HTTPException(status_code=404, detail=f"No user reports found for area ID '{area_id}'.")
    return report_data

@router.get("/userR/summary/{area_id}", summary="Get summary (ID, number of ratings, rounded average safety) for an area")
def get_user_report_area_summary(area_id: str) -> Dict[str, Any]:
    # Function name get_area_summary remains the same
    area_summary = userR_service.get_area_summary(area_id)
    if area_summary is None:
        raise HTTPException(status_code=404, detail=f"User report for area ID '{area_id}' not found or has no summary data.")
    return area_summary

@router.get("/userR/safety/{area_id}", summary="Get the rounded average safety level for a specific area ID")
def get_rounded_average_user_report_safety(area_id: str):
    area_summary = userR_service.get_area_summary(area_id)
    if area_summary is None:
        raise HTTPException(status_code=404, detail=f"User report for area ID '{area_id}' not found.")
    
    rounded_avg = area_summary.get("rounded_avg_safety_level")
    if rounded_avg is None:
        raise HTTPException(status_code=404, detail=f"No safety level data available for area ID '{area_id}'.")
    return rounded_avg

@router.get("/userR")
def get_all_user_reports_data():
    return userR_service.get_all_area_data()
