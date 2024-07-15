#!/bin/bash

# Elevate to root
sudo su

# Download the ipv6-proxy-server script
wget https://raw.githubusercontent.com/Temporalitas/ipv6-proxy-server/master/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Generate random username and password
USERNAME=$(openssl rand -base64 12)
PASSWORD=$(openssl rand -base64 12)

# Run the ipv6-proxy-server script with generated credentials
./ipv6-proxy-server.sh -s 64 -c 100 -u $USERNAME -p $PASSWORD -t http -r 10

# Check if the proxy list file exists
PROXY_FILE="/root/proxyserver/backconnect_proxies.list"
if [ -f "$PROXY_FILE" ]; then
    # Create a new file for proxies with unique credentials
    UNIQUE_PROXY_FILE="/root/proxyserver/unique_backconnect_proxies.list"
    > $UNIQUE_PROXY_FILE

    # Read each line from the original proxy file and generate unique credentials
    while IFS= read -r line; do
        IP_PORT=$(echo $line | cut -d':' -f1-2)
        USERNAME=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c12)
        PASSWORD=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c12)
        echo "$IP_PORT:$USERNAME:$PASSWORD" >> $UNIQUE_PROXY_FILE
    done < $PROXY_FILE

    # Create a tar.gz file with a random 6-character password
    TAR_FILE="/root/proxyserver/backconnect_proxies.tar.gz"
    tar czf $TAR_FILE $UNIQUE_PROXY_FILE

    # Upload the tar.gz file to Bashupload
    UPLOAD_RESPONSE=$(curl -s --upload-file $TAR_FILE https://bashupload.com/$TAR_FILE)

    # Extract the download link from the response
    DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

    echo "You can download the tar.gz proxy list from: $DOWNLOAD_LINK"
else
    echo "Proxy list file not found!"
fi
