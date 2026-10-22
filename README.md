# ekeyAudit

Lauffaehige Flask-Webanwendung fuer QM-Audits nach ISO 9001.

## Installation

```
pip install -r requirements.txt
```

(Falls auf dem System noetig, kann alternativ `pip install -r requirements.txt --break-system-packages` verwendet werden.)

## Start

```
python main.py
```

Danach im Browser oeffnen: http://localhost:8080

## Docker

```
docker build -t ekey-audit .
docker run -p 8080:8080 --env-file .env.docker -v ekey-audit-uploads:/app/uploads -v ekey-audit-reports:/app/reports_out ekey-audit
```

`.env.example` nach `.env.docker` kopieren und ausfuellen. Im Container ist keine
Windows-Authentifizierung moeglich - SQL-Login verwenden (`EKEY_MSSQL_TRUSTED_CONNECTION=no`)
und `EKEY_AUDIT_SECRET_KEY` setzen. Im Container laeuft gunicorn (`wsgi.py`), lokal weiterhin `python main.py`.

## Login

- Benutzername: `admin`
- Passwort: `ekey2026`

Die SQLite-Datenbank `ekeyQMAudits.db` wird beim ersten Start automatisch im Projektordner angelegt und
mit den Lookup-Tabellen (Audit-Typ, Audit-Status, Audit-Bewertung, Beispiel-Prozesse) sowie dem Admin-User befuellt.
Ein erneuter Start seedet die Daten nicht doppelt.

## Hinweise

- "AuditCheck" (automatisierte Pruefungen) und der teilautomatisierte "AuditInfo"-Bereich sind laut
  Spezifikation noch offen (TBD) und wurden bewusst nicht implementiert (Platzhalter-Hinweis in der GUI:
  "in Entwicklung").
- E-Mail-Erinnerungen (`com.py`) sind aktuell nur als Logging-Dummy umgesetzt (kein echter SMTP-Versand).
- Nicht im Repository (nur lokal, siehe `.gitignore`): `Dokumentation/`, die SQLite-Datei
  `ekeyQMAudits.db`, hochgeladene Anhaenge (`uploads/`) und erzeugte Berichte (`reports_out/`).
  Die Ordner `uploads/` und `reports_out/` werden beim Start automatisch angelegt.
