from fastapi import APIRouter, HTTPException
from backend.app.services import station_service
from fastapi import Query

router = APIRouter()

@router.get("/stations/search")
def search_stations(name: str):
    return station_service.search_stations_by_name(name)

@router.get("/stations/safety")
def get_stations_by_safety(level: str = Query(..., description="Safety level (e.g. red, green, yellow, orange)")):
    stations = station_service.get_stations_by_safety_level(level)
    if not stations:
        raise HTTPException(status_code=404, detail="No stations found with that safety level")
    return stations

@router.get("/stations/summary")
def get_summary():
    return station_service.get_station_summary()

@router.get("/stations/smart", response_model=dict)
def smart_station_suggestion(
    lat: float = Query(..., description="User's current latitude"),
    lng: float = Query(..., description="User's current longitude")
):
    station = station_service.get_safest_nearby_station(lat, lng)
    if not station:
        raise HTTPException(status_code=404, detail="No station found")

    return station

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



