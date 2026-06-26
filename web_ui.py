#!/usr/bin/env python3
import sys
import os
import subprocess
import threading
import http.server
import json
import traceback
import time
from urllib.parse import parse_qs, urlparse

# Global variables
bot_process = None
logs_buffer = []
logs_lock = threading.Lock()
max_logs = 1000

# Start Java bot process
def start_bot():
    global bot_process
    # Retrieve arguments passed to the script
    java_args = ['java', '--module-path', '/usr/share/openjfx/lib', '--add-modules', 'javafx.controls', '-jar', '/app/ts3-musicbot.jar'] + sys.argv[1:]
    print(f"[Web Wrapper] Launching bot: {' '.join(java_args)}", flush=True)
    
    bot_process = subprocess.Popen(
        java_args,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )
    
    # Start thread to read stdout/stderr
    def log_reader():
        global bot_process, logs_buffer
        for line in iter(bot_process.stdout.readline, ''):
            with logs_lock:
                logs_buffer.append(line)
                if len(logs_buffer) > max_logs:
                    logs_buffer.pop(0)
            # Forward logs to container stdout so they are visible via 'docker logs'
            sys.stdout.write(line)
            sys.stdout.flush()
        bot_process.wait()
        print(f"[Web Wrapper] Bot process exited with code {bot_process.returncode}", flush=True)
        
    t = threading.Thread(target=log_reader, daemon=True)
    t.start()

# Embedded HTML UI with premium dark glassmorphism design
HTML_CONTENT = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TS3 Music Bot Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #070a13;
            --card-bg: rgba(16, 22, 42, 0.7);
            --border-glow: rgba(139, 92, 246, 0.2);
            --accent-violet: #8b5cf6;
            --accent-cyan: #06b6d4;
            --accent-green: #10b981;
            --accent-red: #ef4444;
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-dark);
            background-image: 
                radial-gradient(at 0% 0%, rgba(139, 92, 246, 0.15) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(6, 182, 212, 0.12) 0px, transparent 50%);
            background-attachment: fixed;
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem 1rem;
        }

        .container {
            width: 100%;
            max-width: 1100px;
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            padding: 1.25rem 2rem;
            border-radius: 16px;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.3);
        }

        .brand-section h1 {
            font-size: 1.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--accent-violet), var(--accent-cyan));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
        }

        .brand-section p {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-top: 2px;
        }

        .status-badge {
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(0, 0, 0, 0.25);
            padding: 6px 14px;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            font-size: 0.85rem;
            font-weight: 600;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--accent-red);
            box-shadow: 0 0 10px var(--accent-red);
        }

        .status-dot.online {
            background-color: var(--accent-green);
            box-shadow: 0 0 12px var(--accent-green);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 1.5rem;
        }

        @media (max-width: 850px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }

        .panel {
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.25);
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
        }

        .panel-title {
            font-size: 1.1rem;
            font-weight: 600;
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
            padding-bottom: 0.75rem;
            color: var(--text-main);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .control-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }

        .btn {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            padding: 12px;
            color: var(--text-main);
            font-family: inherit;
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }

        .btn:hover {
            background: rgba(139, 92, 246, 0.15);
            border-color: rgba(139, 92, 246, 0.35);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(139, 92, 246, 0.15);
        }

        .btn:active {
            transform: translateY(0);
        }

        .btn-icon {
            font-size: 1.2rem;
        }

        .btn-danger:hover {
            background: rgba(239, 68, 68, 0.15);
            border-color: rgba(239, 68, 68, 0.35);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.15);
        }

        .btn-full {
            grid-column: span 2;
        }

        /* Console styling */
        .console-container {
            display: flex;
            flex-direction: column;
            height: 480px;
            background: rgba(5, 7, 14, 0.85);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            overflow: hidden;
        }

        .console-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 16px;
            background: rgba(255, 255, 255, 0.02);
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        .console-log-area {
            flex: 1;
            padding: 16px;
            font-family: 'Fira Code', monospace;
            font-size: 0.85rem;
            line-height: 1.5;
            overflow-y: auto;
            white-space: pre-wrap;
            color: #38bdf8;
            scroll-behavior: smooth;
        }

        /* Monospace custom scrollbar */
        .console-log-area::-webkit-scrollbar {
            width: 8px;
        }
        .console-log-area::-webkit-scrollbar-track {
            background: rgba(0,0,0,0.1);
        }
        .console-log-area::-webkit-scrollbar-thumb {
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
        }
        .console-log-area::-webkit-scrollbar-thumb:hover {
            background: rgba(255,255,255,0.2);
        }

        /* Console input section */
        .command-form {
            display: flex;
            gap: 10px;
            margin-top: 5px;
        }

        .command-input {
            flex: 1;
            background: rgba(0, 0, 0, 0.4);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            padding: 14px 16px;
            color: var(--text-main);
            font-family: 'Outfit', sans-serif;
            font-size: 0.95rem;
            transition: all 0.2s;
        }

        .command-input:focus {
            outline: none;
            border-color: var(--accent-violet);
            box-shadow: 0 0 10px rgba(139, 92, 246, 0.2);
        }

        .btn-send {
            background: linear-gradient(135deg, var(--accent-violet), #6d28d9);
            border: none;
            padding: 0 24px;
            border-radius: 10px;
            color: white;
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-send:hover {
            box-shadow: 0 4px 15px rgba(139, 92, 246, 0.4);
            transform: translateY(-1px);
        }

        .btn-send:active {
            transform: translateY(0);
        }

        .help-tip {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-align: center;
        }

        .autoscroll-toggle {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.8rem;
            user-select: none;
        }

        .autoscroll-toggle input {
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="brand-section">
                <h1>TS3 Music Bot</h1>
                <p>Interactive Web Dashboard</p>
            </div>
            <div class="status-badge">
                <div id="statusDot" class="status-dot"></div>
                <span id="statusText">Checking...</span>
            </div>
        </header>

        <div class="dashboard-grid">
            <!-- Sidebar: Controls -->
            <div class="panel">
                <h2 class="panel-title">Controls</h2>
                <div class="control-grid">
                    <button class="btn" onclick="sendQuickCommand('%queue-play')">
                        <span class="btn-icon">▶</span>
                        <span>Play</span>
                    </button>
                    <button class="btn" onclick="sendQuickCommand('%queue-pause')">
                        <span class="btn-icon">⏸</span>
                        <span>Pause</span>
                    </button>
                    <button class="btn" onclick="sendQuickCommand('%queue-resume')">
                        <span class="btn-icon">🔄</span>
                        <span>Resume</span>
                    </button>
                    <button class="btn btn-danger" onclick="sendQuickCommand('%queue-stop')">
                        <span class="btn-icon">⏹</span>
                        <span>Stop</span>
                    </button>
                    <button class="btn" onclick="sendQuickCommand('%queue-skip')">
                        <span class="btn-icon">⏭</span>
                        <span>Skip</span>
                    </button>
                    <button class="btn" onclick="sendQuickCommand('%queue-shuffle')">
                        <span class="btn-icon">🔀</span>
                        <span>Shuffle</span>
                    </button>
                    <button class="btn btn-full" onclick="sendQuickCommand('%queue-list')">
                        <span class="btn-icon">📋</span>
                        <span>List Queue</span>
                    </button>
                    <button class="btn btn-danger btn-full" onclick="sendQuickCommand('%queue-clear')">
                        <span class="btn-icon">🗑</span>
                        <span>Clear Queue</span>
                    </button>
                </div>
            </div>

            <!-- Main Panel: Terminal Logs & Stdin Command Box -->
            <div class="panel">
                <div class="panel-title">
                    <span>Live Console Output</span>
                    <label class="autoscroll-toggle">
                        <input type="checkbox" id="autoScroll" checked>
                        <span>Auto-scroll</span>
                    </label>
                </div>
                <div class="console-container">
                    <div class="console-header">
                        <span>stdout/stderr feed</span>
                        <span id="logCounter">0 lines</span>
                    </div>
                    <div id="logs" class="console-log-area">Loading logs...</div>
                </div>
                
                <form id="cmdForm" class="command-form" onsubmit="submitCommand(event)">
                    <input type="text" id="cmdInput" class="command-input" placeholder="Type a command (e.g. %queue-add https://youtu.be/...)" autocomplete="off">
                    <button type="submit" class="btn-send">Send</button>
                </form>
                <div class="help-tip">
                    Tip: Command prefix is <code>%</code> (or whatever is configured). Type <code>%help</code> to list commands.
                </div>
            </div>
        </div>
    </div>

    <script>
        const logsEl = document.getElementById('logs');
        const autoScrollCheck = document.getElementById('autoScroll');
        const statusDot = document.getElementById('statusDot');
        const statusText = document.getElementById('statusText');
        const logCounter = document.getElementById('logCounter');
        
        let lastLogLength = 0;

        function updateLogs() {
            fetch('/api/logs')
                .then(res => res.json())
                .then(data => {
                    if (data && Array.isArray(data)) {
                        logCounter.innerText = `${data.length} lines`;
                        
                        const logText = data.join('');
                        logsEl.textContent = logText || "No logs available yet.";
                        
                        if (autoScrollCheck.checked) {
                            logsEl.scrollTop = logsEl.scrollHeight;
                        }
                    }
                })
                .catch(err => {
                    console.error('Error fetching logs:', err);
                    logsEl.textContent = "Error loading console logs.";
                });
        }

        function updateStatus() {
            fetch('/api/status')
                .then(res => res.json())
                .then(data => {
                    if (data && data.running) {
                        statusDot.className = 'status-dot online';
                        statusText.innerText = 'ONLINE';
                    } else {
                        statusDot.className = 'status-dot';
                        statusText.innerText = 'OFFLINE';
                    }
                })
                .catch(err => {
                    statusDot.className = 'status-dot';
                    statusText.innerText = 'DISCONNECTED';
                });
        }

        function sendQuickCommand(cmd) {
            fetch('/api/command', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({ command: cmd })
            }).then(res => {
                if (res.ok) {
                    // Small visual indicator
                    updateLogs();
                }
            });
        }

        function submitCommand(e) {
            e.preventDefault();
            const input = document.getElementById('cmdInput');
            const cmd = input.value.trim();
            if (!cmd) return;

            input.value = '';
            fetch('/api/command', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({ command: cmd })
            }).then(res => {
                if (res.ok) {
                    setTimeout(updateLogs, 100);
                }
            });
        }

        // Poll endpoints
        setInterval(updateLogs, 1000);
        setInterval(updateStatus, 3000);

        // Initial load
        updateLogs();
        updateStatus();
    </script>
</body>
</html>
"""

# HTTP Request Handler Class
class BotHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    # Disable log output to console to avoid spamming container logs
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        url_path = urlparse(self.path).path
        if url_path in ('/', '/index.html'):
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(HTML_CONTENT.encode('utf-8'))
        elif url_path == '/api/logs':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            with logs_lock:
                logs_copy = list(logs_buffer)
            self.wfile.write(json.dumps(logs_copy).encode('utf-8'))
        elif url_path == '/api/status':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            is_running = bot_process is not None and bot_process.poll() is None
            self.wfile.write(json.dumps({"running": is_running}).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        url_path = urlparse(self.path).path
        if url_path == '/api/command':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length).decode('utf-8')
            params = parse_qs(post_data)
            command_list = params.get('command', [])
            
            if command_list and bot_process and bot_process.poll() is None:
                command = command_list[0]
                print(f"[Web Wrapper] Issuing command: {command}", flush=True)
                try:
                    bot_process.stdin.write(command + "\n")
                    bot_process.stdin.flush()
                    self.send_response(200)
                    self.end_headers()
                    self.wfile.write(b"OK")
                    return
                except Exception as e:
                    traceback.print_exc()
            
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b"Error executing command")
        else:
            self.send_response(404)
            self.end_headers()

def run_server():
    port = int(os.environ.get("TS3_WEB_PORT", 8080))
    server_address = ('', port)
    # Using ThreadingHTTPServer to handle concurrent connections gracefully
    httpd = http.server.ThreadingHTTPServer(server_address, BotHTTPRequestHandler)
    print(f"[Web Wrapper] Serving HTTP dashboard on port {port}...", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()

if __name__ == '__main__':
    # Start bot subprocess
    start_bot()
    
    # Start HTTP server in a separate thread
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()
    
    # Monitor bot process and keep main thread alive
    try:
        while True:
            if bot_process:
                status = bot_process.poll()
                if status is not None:
                    # Bot exited, let's terminate wrapper too
                    sys.exit(status)
            time.sleep(1)
    except (KeyboardInterrupt, SystemExit):
        print("[Web Wrapper] Shutting down...", flush=True)
        if bot_process and bot_process.poll() is None:
            bot_process.terminate()
            try:
                bot_process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                bot_process.kill()
        sys.exit(0)
