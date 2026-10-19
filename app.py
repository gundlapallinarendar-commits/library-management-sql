from datetime import datetime
import sqlite3
from pathlib import Path

import psutil
from flask import Flask, jsonify, render_template

APP_DIR = Path(__file__).resolve().parent
DB_PATH = APP_DIR / "incidents.db"
app = Flask(__name__)

CPU_WARNING = 80
MEMORY_WARNING = 85
DISK_WARNING = 90


def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS incidents (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                created_at TEXT NOT NULL,
                severity TEXT NOT NULL,
                metric TEXT NOT NULL,
                value REAL NOT NULL,
                message TEXT NOT NULL,
                recommendation TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'Open'
            )
        """)


def get_metrics():
    disk = psutil.disk_usage(str(APP_DIR.anchor or "/"))
    return {
        "timestamp": datetime.now().astimezone().isoformat(timespec="seconds"),
        "cpu_percent": psutil.cpu_percent(interval=0.25),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": disk.percent,
        "uptime_seconds": max(0, int(datetime.now().timestamp() - psutil.boot_time())),
    }


def analyze_metrics(metrics):
    findings = []
    rules = [
        ("CPU", metrics["cpu_percent"], CPU_WARNING,
         "High CPU usage detected.",
         "Inspect top CPU-consuming processes, check recent deployments, and review application logs."),
        ("Memory", metrics["memory_percent"], MEMORY_WARNING,
         "High memory usage detected.",
         "Inspect memory-heavy processes, check for memory leaks, and verify available capacity."),
        ("Disk", metrics["disk_percent"], DISK_WARNING,
         "Disk usage is approaching capacity.",
         "Find large files and logs, rotate or archive logs safely, and increase storage if needed."),
    ]
    for metric, value, threshold, message, recommendation in rules:
        if value >= threshold:
            findings.append({
                "severity": "High" if value >= threshold + 10 else "Medium",
                "metric": metric,
                "value": round(float(value), 1),
                "message": message,
                "recommendation": recommendation,
            })
    return findings


def record_incidents(findings):
    now = datetime.now().astimezone().isoformat(timespec="seconds")
    with sqlite3.connect(DB_PATH) as conn:
        for item in findings:
            # Avoid inserting the same open alert on every dashboard refresh.
            existing = conn.execute(
                "SELECT id FROM incidents WHERE metric=? AND status='Open'",
                (item["metric"],)
            ).fetchone()
            if not existing:
                conn.execute("""
                    INSERT INTO incidents
                    (created_at, severity, metric, value, message, recommendation, status)
                    VALUES (?, ?, ?, ?, ?, ?, 'Open')
                """, (now, item["severity"], item["metric"], item["value"],
                      item["message"], item["recommendation"]))


def get_incidents(limit=20):
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        rows = conn.execute("""
            SELECT id, created_at, severity, metric, value, message, recommendation, status
            FROM incidents ORDER BY id DESC LIMIT ?
        """, (limit,)).fetchall()
    return [dict(row) for row in rows]


init_db()


@app.get("/")
def dashboard():
    return render_template("index.html")


@app.get("/api/metrics")
def metrics_api():
    metrics = get_metrics()
    findings = analyze_metrics(metrics)
    record_incidents(findings)
    return jsonify({"metrics": metrics, "alerts": findings, "incidents": get_incidents()})


@app.get("/health")
def health():
    return jsonify({"status": "ok", "service": "AI Ops Monitor"})


if __name__ == "__main__":
    app.run(debug=True)
