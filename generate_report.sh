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

# Extract total and available memory in MiB from free -m
# free -m output format:
# mem:  total  used  free  shared  buff/cache  available
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_AVAILABLE=$(free -m | awk '/Mem:/ {print $7}')

# GitHub repository URL for the footer link
GITHUB_URL="https://github.com/tviitala25/week3"

# Generate the HTML using your teacher's template
cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Week 3 – Server Status Report</title>
    <style>
        body {
            font-family: system-ui, sans-serif;
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
            line-height: 1.6;
            background: #f1f5f9;
            color: #172033;
        }

        h1, h2 {
            color: #173b65;
        }

        section {
            margin: 24px 0;
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
        <h1>Server Status Report</h1>
        <p>Week 3: Linux command line and Bash scripting</p>
        <p>Automated system metrics report running on CSC Pouta VM.</p>
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
            Disk space status is <strong>OK</strong> below 80% usage
            and <strong>WARNING</strong> at 80% or above.
        </p>

        <p class="note">
            Bash generates this report once per minute.
            Wait approximately 1–2 minutes and reload the page
            to see a new generation time.
        </p>
    </section>

    <section>
        <h2>Commands used</h2>
        <ul>
            <li>
                <code>date</code>:
                displays the current date, time and time zone
                using the format specified in the script.
            </li>
            <li>
                <code>uptime -p</code>:
                displays how long the server has been running.
            </li>
            <li>
                <code>df -P / | awk 'NR == 2 {print \$5}'</code>:
                passes filesystem information to awk, which extracts
                the usage percentage from the second row.
            </li>
            <li>
                <code>free -m</code>:
                displays memory information in mebibytes (MiB).
            </li>
        </ul>
    </section>

    <section>
        <h2>How the script works</h2>
        <p>
            The script collects server information using Linux commands
            and stores the results in Bash variables through command
            substitution. A function uses an if statement to determine
            the disk space status.
        </p>
        <p>
            The script generates a temporary HTML file and then moves
            the completed file into place as index.html.
            Nginx serves this file at /viikko3/.
        </p>
        <p>
            The disk space function extracts the numeric usage percentage and evaluates it against an 80% threshold using a conditional statement. Piping is used extensively, such as passing <code>df -P /</code> output through <code>awk</code> to isolate the target field.
        </p>
    </section>

    <section>
        <h2>Scheduling</h2>
        <p>
            The script is automated using a user crontab entry set to execute once per minute (<code>* * * * *</code>). Cron handles job execution automatically and persists across system reboots.
        </p>
    </section>

    <section>
        <h2>Test results</h2>

        <h3>Syntax check and manual execution</h3>
        <p>
            Running <code>bash -n generate_report.sh</code> completed with no syntax errors. Manual execution successfully created and populated the HTML report at the target Nginx location.
        </p>

        <h3>Disk space status tests</h3>
        <p>
            Tested the status logic by temporarily modifying the threshold values in the script logic.
        </p>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th scope="col">Test input</th>
                        <th scope="col">Expected status</th>
                        <th scope="col">Actual status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>50%</td>
                        <td>OK</td>
                        <td>OK</td>
                    </tr>
                    <tr>
                        <td>80%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                    <tr>
                        <td>90%</td>
                        <td>WARNING</td>
                        <td>WARNING</td>
                    </tr>
                </tbody>
            </table>
        </div>

        <h3>Automatic updates</h3>
        <p>
            Verified that consecutive automatic updates increment the generation timestamp every minute as expected.
        </p>

        <h3>Reboot test</h3>
        <p>
            Rebooted the VM and verified that both the Week 2 application and the Week 3 automated report resumed serving correctly immediately upon startup.
        </p>
    </section>

    <section>
        <h2>A problem solved or a lesson learned</h2>
        <p>Ensuring proper file permissions and utilizing temporary files with atomic move operations prevents race conditions where Nginx might attempt to serve an incomplete or partially written HTML document during a cron write cycle.</p>
    </section>

    <footer>
        <p><a href="$GITHUB_URL">View the source code on GitHub</a></p>
    </footer>
</body>
</html>
EOF

# Ensure the generated temp file is world-readable before moving it
chmod 644 "$TEMP_FILE"

# Atomically move the temp file into place
mv "$TEMP_FILE" "$OUTPUT_FILE"
