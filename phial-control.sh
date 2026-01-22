#!/bin/bash

# Configuration: Update these paths to match your system
CERT_FILE="/etc/pki/tls/certs/phial.127.0.0.1.nip.io+4.pem"
KEY_FILE="/etc/pki/tls/private/phial.127.0.0.1.nip.io+4-key.pem"
PROJECT_DIR="/home/mrzenith/Documents/Software-Engineer/Projects/The-Alchemists-Lab"

start_phial() {
    echo "--- Starting Phial Environment ---"

    # 1. Apply SELinux Contexts to certificates
    sudo chcon -t cert_t "$CERT_FILE"
    sudo chcon -t cert_t "$KEY_FILE"
    echo "[OK] Applied cert_t labels to SSL files."

    # 2. Enable SELinux Booleans (Non-Persistent)
    # We omit '-P' so these revert automatically on reboot
    sudo setsebool httpd_can_network_connect 1
    sudo setsebool httpd_enable_homedirs 1
    sudo setsebool httpd_read_user_content 1
    echo "[OK] Enabled Nginx network and home directory access."

    # 3. Start Nginx
    sudo systemctl start nginx
    echo "[OK] Nginx service started."

    echo "--- Environment Ready ---"
}

stop_phial() {
    echo "--- Stopping Phial Environment ---"

    # 1. Stop Nginx
    sudo systemctl stop nginx
    echo "[OK] Nginx service stopped."

    # 2. Revert SELinux Booleans
    sudo setsebool httpd_can_network_connect 0
    sudo setsebool httpd_enable_homedirs 0
    sudo setsebool httpd_read_user_content 0
    echo "[OK] Reverted Nginx security booleans to default."

    # 3. Restore Default File Contexts
    sudo restorecon -v "$CERT_FILE"
    sudo restorecon -v "$KEY_FILE"
    echo "[OK] Restored default SELinux labels for certificates."

    echo "--- Environment Defaulted ---"
}

case "$1" in
    start)
        start_phial
        ;;
    stop)
        stop_phial
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
esac
