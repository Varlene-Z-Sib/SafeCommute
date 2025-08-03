import json
from pathlib import Path
from threading import Lock

_store_locks: dict[str, Lock] = {}

def _get_lock(path: Path) -> Lock:
    key = str(path.resolve())
    if key not in _store_locks:
        _store_locks[key] = Lock()
    return _store_locks[key]

def read_json(path: Path, default):
    lock = _get_lock(path)
    with lock:
        if not path.exists():
            return default
        try:
            with path.open("r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return default

def write_json(path: Path, data):
    lock = _get_lock(path)
    with lock:
        with path.open("w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
