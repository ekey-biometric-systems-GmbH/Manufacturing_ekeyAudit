"""
wsgi.py - Einstiegspunkt fuer den Produktionsbetrieb (Docker / gunicorn).

Start im Container: gunicorn wsgi:app
Lokal weiterhin: python main.py
"""

import database as db
from main import app  # noqa: F401 - wird von gunicorn verwendet

try:
    db.init_db()
except db.DatabaseConnectionError as exc:
    # Wie in main.py: Anwendung startet trotzdem und zeigt die Fehlerseite an.
    print(f"WARNUNG - Datenbank nicht erreichbar: {exc}")
