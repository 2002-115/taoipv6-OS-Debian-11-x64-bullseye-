#!/bin/bash

# Xóa proxy cũ nếu có
./ipv6-proxy-server.sh --uninstall

# Cài đặt các gói cần thiết
sudo apt update && sudo apt upgrade -y && sudo apt install wget -y
sudo apt-get install wget zip curl openssl gcc make git -y
sudo apt-get install zip -y

# Elevate to root (nếu chưa)
sudo su

# Download the ipv6-proxy-server script
# Tải xuống script ipv6-proxy-server
wget http://69.28.88.79/tool%20ipv6/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Generate random username and password
USERNAME=$(openssl rand -base64 12)
PASSWORD=$(openssl rand -base64 12)
# Tạo username và password ngẫu nhiên không chứa dấu "+"
generate_random_string() {
    local length=$1
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c $length
}

USERNAME=$(generate_random_string 12)
PASSWORD=$(generate_random_string 12)

# Run the ipv6-proxy-server script with generated credentials
# Chạy script ipv6-proxy-server với thông tin đăng nhập đã tạo
./ipv6-proxy-server.sh -s 64 -c 100 -u $USERNAME -p $PASSWORD -t http -r 10

# Check if the proxy list file exists
# Kiểm tra xem file danh sách proxy có tồn tại không
PROXY_FILE="/root/proxyserver/backconnect_proxies.list"
if [ -f "$PROXY_FILE" ]; then
    # Create a zip file with a random 6-character password
    # Tạo file zip với mật khẩu ngẫu nhiên gồm 6 ký tự
    ZIP_FILE="/root/proxyserver/backconnect_proxies.zip"
    ZIP_PASSWORD=$(openssl rand -base64 6 | cut -c1-6)
    ZIP_PASSWORD=$(generate_random_string 6)
    zip -P $ZIP_PASSWORD $ZIP_FILE $PROXY_FILE

    # Upload the zip file to Bashupload
    # Upload file zip lên Bashupload
    UPLOAD_RESPONSE=$(curl -s --upload-file $ZIP_FILE https://bashupload.com/$ZIP_FILE)

    # Extract the download link from the response
    # Trích xuất link tải về từ phản hồi
    DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

    echo "You can download the zipped proxy list from: $DOWNLOAD_LINK"
    echo "The password for the zip file is: $ZIP_PASSWORD"
    echo "Bạn có thể tải danh sách proxy đã nén
    từ: $DOWNLOAD_LINK"
    echo "Mật khẩu cho file zip là: $ZIP_PASSWORD"
else
    echo "Proxy list file not found!"
    echo "Không tìm thấy file danh sách proxy!"
fi
