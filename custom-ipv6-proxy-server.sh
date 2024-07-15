#!/bin/bash

# Elevate to root
sudo su

# Download the ipv6-proxy-server script
wget -qO- https://raw.githubusercontent.com/Temporalitas/ipv6-proxy-server/master/ipv6-proxy-server.sh -O ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Create the directory for proxy files if it doesn't exist
mkdir -p /root/proxyserver

# Create a new file for proxies with unique credentials
UNIQUE_PROXY_FILE="/root/proxyserver/unique_backconnect_proxies.list"
> $UNIQUE_PROXY_FILE

# Open necessary ports in UFW
ufw allow 10000:10100/tcp
ufw allow 10000:10100/udp
ufw reload

# Loop to create 100 proxies with unique credentials
for i in $(seq 1 100); do
    # Uninstall any existing proxy server
    ./ipv6-proxy-server.sh --uninstall

    # Generate random username and password
    USERNAME=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c12)
    PASSWORD=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c12)

    # Run the ipv6-proxy-server script with generated credentials for each proxy
    ./ipv6-proxy-server.sh -s 64 -c 1 -u $USERNAME -p $PASSWORD -t http -r 10

    # Check if the proxy list file exists and append to unique proxy file
    PROXY_FILE="/root/proxyserver/backconnect_proxies.list"
    if [ -f "$PROXY_FILE" ]; then
        IP_PORT=$(cat $PROXY_FILE | cut -d':' -f1-2)
        echo "$IP_PORT:$USERNAME:$PASSWORD" >> $UNIQUE_PROXY_FILE
    else
        echo "Proxy list file not found!"
        exit 1
    fi

    # Clean up the temporary proxy list file
    rm -f $PROXY_FILE
done

# Create a tar.gz file with a random 6-character password
TAR_FILE="/root/proxyserver/backconnect_proxies.tar.gz"
tar czf $TAR_FILE $UNIQUE_PROXY_FILE

# Upload the tar.gz file to Bashupload
UPLOAD_RESPONSE=$(curl -s --upload-file $TAR_FILE https://bashupload.com/$TAR_FILE)

# Extract the download link from the response
DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

echo "You can download the tar.gz proxy list from: $DOWNLOAD_LINK"
