from fastapi import APIRouter
from backend.app.services.station_service import get_all_stations

router = APIRouter()

@router.get("/stations")
def fetch_stations():
    return get_all_stations()
