#!/bin/bash
# Xóa proxy cũ
./ipv6-proxy-server.sh --uninstall

# Elevate to root
sudo su

# Tải xuống script ipv6-proxy-server
wget http://69.28.88.79/tool%20ipv6/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Tạo username và password ngẫu nhiên không chứa dấu "+"
generate_random_string() {
    local length=$1
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c $length
}

USERNAME=$(generate_random_string 12)
PASSWORD=$(generate_random_string 12)

# Chạy script ipv6-proxy-server với thông tin đăng nhập đã tạo
./ipv6-proxy-server.sh -s 64 -c 100 -u $USERNAME -p $PASSWORD -t http -r 10

# Kiểm tra xem file danh sách proxy có tồn tại không
PROXY_FILE="/root/proxyserver/backconnect_proxies.list"
if [ -f "$PROXY_FILE" ]; then
    # Tạo file zip với mật khẩu ngẫu nhiên gồm 6 ký tự
    ZIP_FILE="/root/proxyserver/backconnect_proxies.zip"
    ZIP_PASSWORD=$(generate_random_string 6)
    zip -P $ZIP_PASSWORD $ZIP_FILE $PROXY_FILE

    # Upload file zip lên Bashupload
    UPLOAD_RESPONSE=$(curl -s --upload-file $ZIP_FILE https://bashupload.com/$ZIP_FILE)

    # Trích xuất link tải về từ phản hồi
    DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

    echo "Bạn có thể tải danh sách proxy đã nén từ: $DOWNLOAD_LINK"
    echo "Mật khẩu cho file zip là: $ZIP_PASSWORD"
else
    echo "Không tìm thấy file danh sách proxy!"
fi
