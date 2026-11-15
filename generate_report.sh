#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Define paths
OUTPUT_DIR="/var/www/html/week3"
OUTPUT_FILE="$OUTPUT_DIR/index.html"
TEMP_FILE=$(mktemp)

# Ensure the web directory exists
mkdir -p "$OUTPUT_DIR"

# Function to determine disk space status (< 80% is OK, >= 80% is WARNING)
check_disk_status() {
    local usage_pct
    # Extract the numeric percentage from df output (e.g. "15%" -> "15")
    usage_pct=$(df -P / | awk 'NR == 2 {print $5}' | tr -d '%')
    
    if [ "$usage_pct" -ge 80 ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

# Collect system data into variables
GENERATED_AT=$(date)
UPTIME_TEXT=$(uptime -p)
DISK_USAGE=$(df -P / | awk 'NR == 2 {print $5}')
DISK_STATUS=$(check_disk_status)

# Extract total and available memory in MiB
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/Mem:/ {print $7}')

# Generate the HTML template
cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3: Server status report</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
            line-height: 1.6;
            background: #f4f4f6;
            color: #203040;
        }

        h1, h2 {
            color: #2c3e50;
	    line-height: 1.2;
        }

        section {
            margin: 12px 0;
            padding: 24px;
	    background: white;
            border-radius: 12px;
        }

        .table-container {
            overflow-x: auto;
        }

        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #cbd5e1;
            padding: 12px;
            text-align: left;
        }

        th {
            background: #dbeafe;
        }

        code {
            background: #e2e8f0;
            padding: 2px 5px;
            border-radius: 4px;
            overflow-wrap: anywhere;
        }

        a {
            color: #1746a2;
        }

        .note {
            color: #475569;
        }
    </style>
</head>
<body>
    <header>
        <h1>Week 3: Server status report</h1>
        <p>Automated system metrics report using Linux command line and Bash scripting.</p>
    </header>

    <section>
        <h2>Current server status</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Information</th>
                        <th scope="col">Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th scope="row">Report generated</th>
                        <td>$GENERATED_AT</td>
                    </tr>
                    <tr>
                        <th scope="row">Server uptime</th>
                        <td>$UPTIME_TEXT</td>
                    </tr>
                    <tr>
                        <th scope="row">Root filesystem disk usage</th>
                        <td>$DISK_USAGE</td>
                    </tr>
                    <tr>
                        <th scope="row">Disk space status</th>
                        <td>$DISK_STATUS</td>
                    </tr>
                    <tr>
                        <th scope="row">Total RAM</th>
                        <td>$MEM_TOTAL MiB</td>
                    </tr>
                    <tr>
                        <th scope="row">Available RAM</th>
                        <td>$MEM_AVAILABLE MiB</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <p>
            Disk space status is <strong>OK</strong> at <80% and <strong> WARNING</strong> at ≥80% usage.
        </p>

        <p>
            Report updates every minute. Refresh in 1–2 minutes to view the latest timestamp.
        </p>
    </section>

    <footer>
	<p><a href="/">Week 1: Nginx setup</a></p>
	<p><a href="/week2/">Week 2: Python web app</a></p>
        <p><a href="https://github.com/tviitala25/week3">GitHub repository</a></p>
    </footer>
</body>
</html>
EOF

# Ensure the generated temp file is world-readable before moving it
chmod 644 "$TEMP_FILE"

# Atomically move the temp file into place
mv "$TEMP_FILE" "$OUTPUT_FILE"
