import json
from pathlib import Path
from typing import List, Dict, Optional, Any

data_path = Path(__file__).parent.parent / "data" / "areas.json"

def load_areas() -> List[Dict[str, Any]]:
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        
        return []
    
def get_safety_level_by_name(area_name: str) -> Optional[str]:
    areas = load_areas()
    
    search_name = area_name.lower()
    
    for area in areas:
        if area.get("name", "").lower() == search_name:
            safety_level = area.get("safety_level")
            return f"The safety level for '{area_name}' is: {safety_level}"
            
    return f"The area '{area_name}' could not be found."