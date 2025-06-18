#!/bin/bash

start_xrdp_services() {
    # Ensure dbus is running as it is often required for Xrdp
    if ! pgrep -x "dbus-daemon" > /dev/null
    then
        service dbus start
    fi
    
    rm -rf /var/run/xrdp-sesman.pid
    rm -rf /var/run/xrdp.pid
    rm -rf /var/run/xrdp/xrdp-sesman.pid
    rm -rf /var/run/xrdp/xrdp.pid

    xrdp-sesman &
    xrdp -n &

    echo "Waiting for X server to be ready..."
    for i in {1..20}; do
        if pgrep Xorg >/dev/null; then
            echo "Xorg is running."
            return
        fi
        sleep 1
    done

    echo "Xorg not detected after timeout."
}

stop_xrdp_services() {
    xrdp --kill
    xrdp-sesman --kill
    exit 0
}

# The user 'root' with password 'root' is created for RDP access.
if id "root" &>/dev/null; then
    echo "root:root" | chpasswd || {
        echo "Failed to update password."
        exit 1
    }
else
    if ! getent group root >/dev/null; then
        addgroup root
    fi

    useradd -m -s /bin/bash -g root root || {
        echo "Failed to create user."
        exit 1
    }
    echo "root:root" | chpasswd || {
        echo "Failed to set password."
        exit 1
    }
    usermod -aG sudo root || {
        echo "Failed to add user to sudo."
        exit 1
    }
fi

if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ >/etc/timezone
fi

mkdir -p /root/Desktop

cd /root/Desktop || {
    echo "Failed to change directory to /root/Desktop"
    exit 1
}

trap "stop_xrdp_services" SIGKILL SIGTERM SIGHUP SIGINT EXIT
start_xrdp_services

if [ "$RUN_API_SOLVER" = "true" ]; then
    echo "Starting API solver in headful mode on 0.0.0.0:5000..."
    # The solver code is already in /app, copied by the Dockerfile
    xvfb-run -a python3 /app/Turnstile-Solver/api_solver.py --browser_type chrome --host 0.0.0.0 --port 5000
fi

# Keep the container running if API solver is not started, allowing for RDP access.
echo "Container is running. Connect via RDP to interact with the desktop."
echo "If RUN_API_SOLVER was not set to true, the API solver is not running."
while true; do sleep 3600; done
