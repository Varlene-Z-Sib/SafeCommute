from fastapi import APIRouter, HTTPException
from backend.app.services import station_service

router = APIRouter()

@router.get("/stations/search")
def search_stations(name: str):
    return station_service.search_stations_by_name(name)

@router.get("/stations/nearby")
def get_nearby_stations(lat: float, lng: float, radius_km: float = 3.0):
    return station_service.get_nearby_stations(lat, lng, radius_km)

@router.get("/stations/{id}")
def get_station(id: str):
    station = station_service.get_station_by_id(id)
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
    return station

@router.get("/stations")
def get_all_stations():
    return station_service.get_all_stations()


