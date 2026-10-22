# ekeyAudit - Container-Image
#
# Build:  docker build -t ekey-audit .
# Start:  docker run -p 8080:8080 --env-file .env.docker \
#             -v ekey-audit-uploads:/app/uploads \
#             -v ekey-audit-reports:/app/reports_out \
#             ekey-audit
#
# WICHTIG - Datenbank-Authentifizierung:
# Windows-Authentifizierung (Trusted Connection) funktioniert aus einem
# Linux-Container NICHT. In der .env.docker daher SQL-Login verwenden:
#   EKEY_MSSQL_TRUSTED_CONNECTION=no
#   EKEY_MSSQL_USER=...
#   EKEY_MSSQL_PASSWORD=...

# Gepinnt auf Debian 12 (bookworm), passend zum Microsoft-ODBC-Repo debian/12.
FROM python:3.11-slim-bookworm

# --- Microsoft ODBC Driver 17 for SQL Server (fuer pyodbc) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl gnupg unixodbc unixodbc-dev \
    && curl -sSL -O https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm -f packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql17 \
    && apt-get purge -y --auto-remove curl gnupg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Im Container von aussen erreichbar, kein Debug-Modus
ENV EKEY_HOST=0.0.0.0 \
    EKEY_PORT=8080 \
    EKEY_DEBUG=false \
    PYTHONUNBUFFERED=1

# Anhaenge und Berichte als Volumes, damit sie Container-Neustarts ueberleben
VOLUME ["/app/uploads", "/app/reports_out"]

EXPOSE 8080

# 1 Worker (init_db/Seeding laeuft pro Worker), dafuer mehrere Threads
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--threads", "8", "--timeout", "120", "wsgi:app"]
