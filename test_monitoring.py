import app as monitor


def test_health_endpoint():
    client = monitor.app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"


def test_threshold_alerts():
    sample = {
        "cpu_percent": 95,
        "memory_percent": 40,
        "disk_percent": 91,
        "timestamp": "2026-01-01T00:00:00+00:00",
        "uptime_seconds": 100,
    }
    alerts = monitor.analyze_metrics(sample)
    assert {a["metric"] for a in alerts} == {"CPU", "Disk"}
    assert all(a["severity"] == "High" for a in alerts)
