#!/bin/bash

# Elevate to root
sudo su

# Download the ipv6-proxy-server script
wget https://raw.githubusercontent.com/Temporalitas/ipv6-proxy-server/master/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Run the ipv6-proxy-server script with placeholder credentials
./ipv6-proxy-server.sh -s 64 -c 100 -u placeholder -p placeholder -t http -r 10

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

    # Create a zip file with a random 6-character password
    ZIP_FILE="/root/proxyserver/backconnect_proxies.zip"
    ZIP_PASSWORD=$(openssl rand -base64 6 | cut -c1-6)
    zip -P $ZIP_PASSWORD $ZIP_FILE $UNIQUE_PROXY_FILE

    # Upload the zip file to Bashupload
    UPLOAD_RESPONSE=$(curl -s --upload-file $ZIP_FILE https://bashupload.com/$ZIP_FILE)

    # Extract the download link from the response
    DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

    echo "You can download the zipped proxy list from: $DOWNLOAD_LINK"
    echo "The password for the zip file is: $ZIP_PASSWORD"
else
    echo "Proxy list file not found!"
fi
