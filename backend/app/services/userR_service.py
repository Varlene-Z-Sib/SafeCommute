import json
from pathlib import Path
from typing import List, Dict, Optional, Any

data_path = Path(__file__).parent.parent / "data" / "userR.json"

def load_areas():
    with open(data_path, "r", encoding="utf-8") as f:
        return json.load(f)

def get_all_area_data_by_id(area_id: str) -> list[Dict[str, Any]]:
    areas = load_areas()
    matching_reports = []
    for report in areas:
        if report.get("id") == area_id:
            matching_reports.append(report)
    return matching_reports

def get_all_area_data():
    return load_areas()

def get_area_summary(area_id: str):
    areas = load_areas()
    
    safety_levels = []
    num_ratings = 0
    area_found = False

    for area in areas:
        if area.get("id") == area_id:
            num_ratings += 1
            area_found = True
            if isinstance(area.get("safety_level"), (int, float)):
                safety_levels.append(area["safety_level"])

    if not area_found:
        return None
    
    rounded_average = None
    if safety_levels:
        average = sum(safety_levels) / len(safety_levels)
        rounded_average = round(average)
    
    return {
        "id": area_id,
        "num_ratings": num_ratings,
        "rounded_avg_safety_level": rounded_average
    }