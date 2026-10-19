# AI-Powered IT Operations Monitoring & Incident Management

A portfolio project inspired by Technology Operations, Cloud Operations, DevOps, and Site Reliability Engineering responsibilities.

## Features

- Live local CPU, memory, and disk monitoring using `psutil`
- Configurable threshold-based alert detection
- Incident history stored in SQLite
- First-response troubleshooting recommendations
- JSON metrics API and health-check endpoint
- Responsive dashboard
- Dockerfile for containerized execution
- Automated tests with GitHub Actions CI

> **Transparency note:** The current version uses explainable threshold rules and predefined troubleshooting recommendations. It does not call an external AI model or monitor a cloud account. Those are possible future extensions.

## Architecture

```text
Browser dashboard
       |
       v
Flask web app ---- /api/metrics
       |                  |
       v                  v
SQLite incident log   psutil system metrics
       |
       v
Threshold rules + troubleshooting suggestions
```

## Requirements

- Python 3.10 or newer
- pip

## Run locally

### 1. Create and activate a virtual environment

**Windows (PowerShell):**
```powershell
py -m venv .venv
.venv\\Scripts\\Activate.ps1
```

**macOS/Linux:**
```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 2. Install dependencies and start

```bash
python -m pip install -r requirements.txt
python app.py
```

Open `http://127.0.0.1:5000` in your browser.

The dashboard refreshes every five seconds. Alerts are generated when CPU reaches 80%, memory reaches 85%, or disk reaches 90%. These thresholds are demo defaults and can be adjusted in `app.py`.

## API endpoints

| Endpoint | Purpose |
|---|---|
| `/` | Monitoring dashboard |
| `/api/metrics` | Current metrics, active threshold alerts, and recent incidents |
| `/health` | Basic service health check |

## Run tests

```bash
pytest
```

## Run with Docker

```bash
docker build -t ai-ops-monitor .
docker run --rm -p 5000:5000 ai-ops-monitor
```

Then open `http://127.0.0.1:5000`.

## Suggested GitHub description

**A Python/Flask IT operations monitoring dashboard with live system metrics, threshold-based anomaly alerts, SQLite incident logging, troubleshooting recommendations, Docker support, and GitHub Actions CI.**

## Future improvements

1. Add configurable alert thresholds through the UI.
2. Add alert acknowledgement and incident resolution workflows.
3. Store metric history and graph trends.
4. Integrate a real LLM behind an optional, securely configured API key for incident summaries.
5. Add Prometheus metrics and Grafana dashboards.
6. Deploy to a cloud VM or container platform.
7. Add role-based access control before exposing it beyond localhost.

## Security and limitations

This is a learning/demo project. Run locally while developing. Do not expose the debug server to the public internet. Production use would require authentication, secure configuration, stronger error handling, and deployment behind a production WSGI server.
