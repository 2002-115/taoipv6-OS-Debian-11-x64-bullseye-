#!/bin/bash
# xoa proxy cu
./ipv6-proxy-server.sh --uninstall
# Elevate to root
sudo su

# Download the ipv6-proxy-server script
wget https://raw.githubusercontent.com/2002-115/ipv6-debian11/main/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Generate random username and password
USERNAME=$(openssl rand -base64 12)
PASSWORD=$(openssl rand -base64 12)

# Run the ipv6-proxy-server script with generated credentials
./ipv6-proxy-server.sh -s 64 -c 100 -u $USERNAME -p $PASSWORD -t http -r 10

# Check if the proxy list file exists
PROXY_FILE="/root/proxyserver/backconnect_proxies.list"
if [ -f "$PROXY_FILE" ]; then
    # Create a zip file with a random 6-character password
    ZIP_FILE="/root/proxyserver/backconnect_proxies.zip"
    ZIP_PASSWORD=$(openssl rand -base64 6 | cut -c1-6)
    zip -P $ZIP_PASSWORD $ZIP_FILE $PROXY_FILE

    # Upload the zip file to Bashupload
    UPLOAD_RESPONSE=$(curl -s --upload-file $ZIP_FILE https://bashupload.com/$ZIP_FILE)

    # Extract the download link from the response
    DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

    echo "You can download the zipped proxy list from: $DOWNLOAD_LINK"
    echo "The password for the zip file is: $ZIP_PASSWORD"
else
    echo "Proxy list file not found!"
fi
