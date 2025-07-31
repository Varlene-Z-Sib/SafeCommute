from fastapi import APIRouter, HTTPException
from backend.app.services import area_service
from fastapi import Query

router = APIRouter()

@router.get("/areas/safety")
def get_area_safety(area_name: str = Query(..., description="The name of the area to get safety level for.")
) -> str:
    safety_info = area_service.get_safety_level_by_name(area_name)

    if "could not be found" in safety_info:
        raise HTTPException(status_code=404, detail=safety_info)
    return safety_info