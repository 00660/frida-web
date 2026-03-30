const elements = {
  flash: document.querySelector("#flash"),
  refreshStatus: document.querySelector("#refreshStatus"),
  fridaState: document.querySelector("#fridaState"),
  panelState: document.querySelector("#panelState"),
  autostartState: document.querySelector("#autostartState"),
  lastSync: document.querySelector("#lastSync"),
  fridaListen: document.querySelector("#fridaListen"),
  panelListen: document.querySelector("#panelListen"),
  connectHint: document.querySelector("#connectHint"),
  fridaPort: document.querySelector("#fridaPort"),
  autoStart: document.querySelector("#autoStart"),
  configForm: document.querySelector("#configForm"),
  startFrida: document.querySelector("#startFrida"),
  stopFrida: document.querySelector("#stopFrida"),
  restartFrida: document.querySelector("#restartFrida"),
  logName: document.querySelector("#logName"),
  logLines: document.querySelector("#logLines"),
  refreshLogs: document.querySelector("#refreshLogs"),
  logOutput: document.querySelector("#logOutput"),
};

function flash(message, tone = "") {
  elements.flash.textContent = message;
  elements.flash.dataset.tone = tone;
}

async function apiJson(path, options = {}) {
  const response = await fetch(path, {
    cache: "no-store",
    ...options,
  });

  if (!response.ok) {
    let detail = response.statusText;
    try {
      const payload = await response.json();
      detail = payload.error || detail;
    } catch (_error) {
      // Fall back to status text.
    }
    throw new Error(detail);
  }

  return response.json();
}

async function apiText(path) {
  const response = await fetch(path, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(response.statusText);
  }
  return response.text();
}

function nowLabel() {
  return new Date().toLocaleTimeString();
}

function renderConnectHint(status) {
  elements.connectHint.innerHTML =
    `Frida stays local at <code>127.0.0.1:${status.frida.port}</code>.<br>` +
    `Use <code>adb forward tcp:${status.frida.port} tcp:${status.frida.port}</code> and then <code>frida-ps -H 127.0.0.1:${status.frida.port}</code>.`;
}

function renderStatus(status) {
  elements.fridaState.textContent = status.frida.running ? "Running" : "Stopped";
  elements.panelState.textContent = status.panel.running ? "Running" : "Stopped";
  elements.autostartState.textContent = status.frida.autostart ? "Enabled" : "Disabled";
  elements.lastSync.textContent = nowLabel();
  elements.fridaListen.textContent = `127.0.0.1:${status.frida.port}`;
  elements.panelListen.textContent = `${status.panel.bind}:${status.panel.port}`;
  renderConnectHint(status);
}

function renderConfig(config) {
  elements.fridaPort.value = config.frida_port;
  elements.autoStart.checked = config.auto_start_frida;
}

async function refreshStatus() {
  const status = await apiJson("/cgi-bin/status.sh");
  renderStatus(status);
}

async function refreshConfig() {
  const config = await apiJson("/cgi-bin/config.sh");
  renderConfig(config);
}

async function refreshLogs() {
  const logName = elements.logName.value;
  const lines = elements.logLines.value || "160";
  elements.logOutput.textContent = "Loading logs...";
  const text = await apiText(`/cgi-bin/logs.sh?name=${encodeURIComponent(logName)}&lines=${encodeURIComponent(lines)}`);
  elements.logOutput.textContent = text || "Log is empty.";
}

async function refreshAll() {
  await Promise.all([refreshStatus(), refreshConfig(), refreshLogs()]);
  flash("Panel synced.", "success");
}

async function runControl(action) {
  const body = new URLSearchParams({ action });
  await apiJson("/cgi-bin/control.sh", {
    method: "POST",
    body,
  });
  await refreshAll();
}

elements.refreshStatus.addEventListener("click", async () => {
  await refreshAll();
});

elements.configForm.addEventListener("submit", async (event) => {
  event.preventDefault();

  const body = new URLSearchParams({
    frida_port: elements.fridaPort.value.trim(),
    auto_start_frida: elements.autoStart.checked ? "true" : "false",
    restart: "true",
  });

  await apiJson("/cgi-bin/config.sh", {
    method: "POST",
    body,
  });

  await refreshAll();
  flash("Frida settings saved and service restarted.", "success");
});

elements.startFrida.addEventListener("click", async () => {
  await runControl("start_frida");
});

elements.stopFrida.addEventListener("click", async () => {
  await runControl("stop_frida");
});

elements.restartFrida.addEventListener("click", async () => {
  await runControl("restart_frida");
});

elements.refreshLogs.addEventListener("click", async () => {
  await refreshLogs();
});

setInterval(() => {
  refreshStatus().catch(() => {
    // Avoid spamming the UI with timer failures.
  });
}, 5000);

refreshAll().catch((error) => {
  flash(error.message, "error");
});
