#!/bin/bash

# Define variables
LOG_FILE="upgrade.log"
NODE_SERVICE="shdw-node"
UPGRADE_URL="https://shdw-drive.genesysgo.net/4xdLyZZJzL883AbiZvgyWKf2q55gcZiMgMkDNQMnyFJC/shdw-node"
NODE_INSTALL_PATH="$HOME/shdw-node"
MAX_RETRIES=10000
RETRY_COUNT=0
RETRY_INTERVAL=5 # Wait duration in seconds

# Initialize log file
echo -n "" > "$LOG_FILE"


echo "### - Stopping Shdw-Node Service - ###" | tee -a "$LOG_FILE"
sudo systemctl stop "$NODE_SERVICE"

echo -e "\n### - Downloading Latest Shdw-Node Version - ###" | tee -a "$LOG_FILE"
# Function to download file with wget and check for errors
download_file() {
    wget -O "$NODE_INSTALL_PATH" "$UPGRADE_URL" 2>&1 | tee -a "$LOG_FILE"
    return ${PIPESTATUS[0]}
}

# Retry logic
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "Attempting to download Shdw-Node upgrade... Attempt #$((RETRY_COUNT + 1))" | tee -a "$LOG_FILE"
    download_file
    WGET_EXIT_CODE=$?
    
    if [ $WGET_EXIT_CODE -eq 0 ]; then
        echo "Download succeeded." | tee -a "$LOG_FILE"
        break
    else
        echo "Download failed with status $WGET_EXIT_CODE, retrying in $RETRY_INTERVAL seconds..." | tee -a "$LOG_FILE"
        sleep $RETRY_INTERVAL
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Failed to download Shdw-Node upgrade after $MAX_RETRIES attempts." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Download completed successfully." | tee -a "$LOG_FILE"

echo "### - Starting Shdw-Node Service - ###" | tee -a "$LOG_FILE"
sudo systemctl start "$NODE_SERVICE"

echo -e "\n### - Shdw-Node Service Status - ###" | tee -a "$LOG_FILE"
sudo systemctl status "$NODE_SERVICE" | tee -a "$LOG_FILE"
echo -e "\n" | tee -a "$LOG_FILE"

echo "### - Current Shdw-Node Version - ###" | tee -a "$LOG_FILE"
/home/dagger/wield --version | tee -a "$LOG_FILE"
echo -e "\n" | tee -a "$LOG_FILE"
