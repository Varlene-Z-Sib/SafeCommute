import json
from pathlib import Path


data_path = Path(__file__).parent.parent / "data" / "safetyReport.json"

def load_reports():
    with open(data_path, "r", encoding="utf-8") as f:
        return json.load(f)

def get_incidents_by_user(user_id: str):
    reports = load_reports()
    return [report for report in reports if report.get("userId") == user_id]

def get_incidents_by_location(location_id: str):
    reports = load_reports()
    return [report for report in reports if report.get("location") == location_id]

def get_unresolved_incidents():
    reports = load_reports()
    return [report for report in reports if report.get("status") == "Pending"]

def get_unresolved_incidents_by_location(location_id: str):
    reports = load_reports()
    return [
        report for report in reports 
        if report.get("status") == "Pending" and report.get("location") == location_id
    ]

def get_all_incidents():
    return load_reports()