"""Создаёт базу данных SQLite из schema.sql и выводит содержимое таблиц."""
import sqlite3
from pathlib import Path

BASE = Path(__file__).parent
DB_PATH = BASE / "competitions.db"
SCHEMA_PATH = BASE / "schema.sql"


def init_db() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
    conn.commit()
    return conn


if __name__ == "__main__":
    conn = init_db()
    tables = [r[0] for r in conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")]
    for t in tables:
        count = conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        print(f"{t}: {count} записей")
    conn.close()
