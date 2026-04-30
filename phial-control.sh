#!/bin/bash

# Configuration
CERT_FILE="/etc/pki/tls/certs/phial.127.0.0.1.nip.io+4.pem"
KEY_FILE="/etc/pki/tls/private/phial.127.0.0.1.nip.io+4-key.pem"
PROJECT_DIR="/home/mrzenith/Documents/Software-Engineer/Projects/The-Alchemists-Lab"
STATIC_DIR="$PROJECT_DIR/chem-backend/static"

start_phial() {
    echo "--- Starting Phial Environment ---"

    # 1. Apply SELinux Contexts to certificates
    sudo chcon -t cert_t "$CERT_FILE"
    sudo chcon -t cert_t "$KEY_FILE"
    echo "[OK] Applied cert_t labels to SSL files."

    # 2. Apply SELinux Context to static assets
    # This allows Nginx to read your project files
    sudo chcon -Rt httpd_sys_content_t "$STATIC_DIR"
    echo "[OK] Applied httpd_sys_content_t labels to static assets."

    # 3. Enable SELinux Booleans (Non-Persistent)
    sudo setsebool httpd_can_network_connect 1
    sudo setsebool httpd_enable_homedirs 1
    sudo setsebool httpd_read_user_content 1
    echo "[OK] Enabled Nginx network and home directory access."

    # 4. Start Nginx
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
    # This wipes the 'httpd_sys_content_t' and 'cert_t' labels
    sudo restorecon -v "$CERT_FILE"
    sudo restorecon -v "$KEY_FILE"
    sudo restorecon -Rv "$STATIC_DIR"
    echo "[OK] Restored default SELinux labels for all files."

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
