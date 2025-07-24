from fastapi import APIRouter, HTTPException
from backend.app.services import station_service

router = APIRouter()

@router.get("/stations/{id}")
def get_station(id: str):
    station = station_service.get_station_by_id(id)
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
    return station
