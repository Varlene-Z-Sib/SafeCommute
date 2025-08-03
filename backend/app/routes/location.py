from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from typing import Optional
from backend.app.services import location_service

router = APIRouter()


class LocationPayload(BaseModel):
    lat: float
    lng: float
    user_id: Optional[str] = None
    share: Optional[bool] = True


@router.post("/location/update")
def update_location(payload: LocationPayload):
    entry = location_service.add_location(
        lat=payload.lat,
        lng=payload.lng,
        user_id=payload.user_id,
        share=payload.share if payload.share is not None else True
    )
    return {"message": "Location updated", "location": entry}


@router.get("/location")
def get_all_locations():
    return location_service.get_all_locations()


@router.get("/location/user")
def get_locations_for_user(user_id: str = Query(..., description="User ID to filter by")):
    locations = location_service.get_locations_by_user(user_id)
    if not locations:
        raise HTTPException(status_code=404, detail="No locations found for that user")
    return locations
