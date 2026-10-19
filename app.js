const $ = (id) => document.getElementById(id);

function setMetric(name, value) {
  const rounded = Math.round(value * 10) / 10;
  $(name).textContent = `${rounded}%`;
  const bar = $(`${name}-bar`);
  bar.style.width = `${Math.min(100, Math.max(0, value))}%`;
  bar.className = `bar${value >= 90 ? " critical" : value >= 80 ? " warning" : ""}`;
}

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>"']/g, c => ({
    "&":"&amp;", "<":"&lt;", ">":"&gt;", '"':"&quot;", "'":"&#39;"
  }[c]));
}

function renderAlerts(alerts) {
  const target = $("alerts");
  if (!alerts.length) {
    target.innerHTML = '<div class="healthy">✓ No threshold breaches detected. System metrics are within configured limits.</div>';
    $("alert-state").textContent = "All clear";
    return;
  }
  $("alert-state").textContent = `${alerts.length} alert(s)`;
  target.innerHTML = alerts.map(a => `
    <article class="alert-card">
      <div class="alert-title">${escapeHtml(a.message)}</div>
      <div class="alert-meta">${escapeHtml(a.severity)} severity · ${escapeHtml(a.metric)}: ${escapeHtml(a.value)}%</div>
      <div class="alert-action"><strong>Suggested triage:</strong> ${escapeHtml(a.recommendation)}</div>
    </article>`).join("");
}

function renderIncidents(incidents) {
  const target = $("incidents");
  const openCount = incidents.filter(i => i.status === "Open").length;
  $("open-count").textContent = openCount;
  if (!incidents.length) {
    target.innerHTML = '<tr><td colspan="7" class="empty">No incidents recorded yet.</td></tr>';
    return;
  }
  target.innerHTML = incidents.map(i => `<tr>
    <td>#${escapeHtml(i.id)}</td><td>${escapeHtml(i.created_at.replace("T", " "))}</td>
    <td class="severity ${escapeHtml(i.severity)}">${escapeHtml(i.severity)}</td>
    <td>${escapeHtml(i.metric)}</td><td>${escapeHtml(i.value)}%</td>
    <td>${escapeHtml(i.recommendation)}</td><td>${escapeHtml(i.status)}</td>
  </tr>`).join("");
}

async function refresh() {
  try {
    const response = await fetch("/api/metrics", {cache: "no-store"});
    if (!response.ok) throw new Error("Metrics endpoint returned an error");
    const data = await response.json();
    setMetric("cpu", data.metrics.cpu_percent);
    setMetric("memory", data.metrics.memory_percent);
    setMetric("disk", data.metrics.disk_percent);
    renderAlerts(data.alerts);
    renderIncidents(data.incidents);
    $("updated").textContent = `Updated ${new Date().toLocaleTimeString()}`;
    $("timestamp").textContent = `Last sample: ${data.metrics.timestamp} · Refreshes every 5 seconds`;
  } catch (error) {
    $("alert-state").textContent = "Connection issue";
    $("alerts").innerHTML = '<div class="alert-card">Unable to load metrics. Check that the Flask server is running.</div>';
  }
}
refresh();
setInterval(refresh, 5000);
