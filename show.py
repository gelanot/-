import sqlite3

db = sqlite3.connect("competitions.db")

tables = db.execute("""
SELECT name, sql
FROM sqlite_master
WHERE type = 'table'
AND name NOT LIKE 'sqlite_%'
AND sql IS NOT NULL
""").fetchall()

for name, sql in tables:
    print(f"\n--- {name} ---")
    print(sql)

db.close()