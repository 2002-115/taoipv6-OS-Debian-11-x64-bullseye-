#!/bin/bash

# Xóa proxy cũ
./ipv6-proxy-server.sh --uninstall

# Elevate to root
sudo su

# Kiểm tra và thêm cấu hình IPv6 vào /etc/network/interfaces nếu cần
INTERFACES_FILE="/etc/network/interfaces"
BACKUP_FILE="/etc/network/interfaces.bak"

# Sao lưu tệp cấu hình hiện tại
cp $INTERFACES_FILE $BACKUP_FILE

if ! grep -q "iface eth0 inet6" $INTERFACES_FILE; then
    echo "Adding IPv6 configuration to $INTERFACES_FILE"
    cat <<EOT >> $INTERFACES_FILE

auto eth0
iface eth0 inet dhcp

iface eth0 inet6 auto
EOT

    # Khởi động lại dịch vụ mạng để áp dụng thay đổi
    if systemctl restart networking; then
        echo "Network restarted successfully."
    else
        echo "Failed to restart network. Restoring previous configuration."
        cp $BACKUP_FILE $INTERFACES_FILE
        systemctl restart networking
        exit 1
    fi
else
    echo "IPv6 configuration already exists in $INTERFACES_FILE"
fi

# Tải xuống script ipv6-proxy-server từ GitHub và cấp quyền thực thi
wget https://raw.githubusercontent.com/Temporalitas/ipv6-proxy-server/master/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh

# Tạo tên người dùng và mật khẩu ngẫu nhiên
USERNAME=$(openssl rand -base64 12)
PASSWORD=$(openssl rand -base64 12)

# Chạy script ipv6-proxy-server với thông tin đăng nhập đã tạo
./ipv6-proxy-server.sh -s 64 -c 100 -u $USERNAME -p $PASSWORD -t http -r 10

# Kiểm tra xem tệp danh sách proxy có tồn tại không
PROXY_FILE="/root/proxyserver/backconnect_proxies.list"
if [ -f "$PROXY_FILE" ]; then
    # Tạo tệp zip với mật khẩu ngẫu nhiên 6 ký tự
    ZIP_FILE="/root/proxyserver/backconnect_proxies.zip"
    ZIP_PASSWORD=$(openssl rand -base64 6 | cut -c1-6)
    zip -P $ZIP_PASSWORD $ZIP_FILE $PROXY_FILE

    # Tải tệp zip lên Bashupload
    UPLOAD_RESPONSE=$(curl -s --upload-file $ZIP_FILE https://bashupload.com/$ZIP_FILE)

    # Trích xuất liên kết tải xuống từ phản hồi
    DOWNLOAD_LINK=$(echo $UPLOAD_RESPONSE | grep -o 'https://bashupload.com/[^ ]*')

    echo "You can download the zipped proxy list from: $DOWNLOAD_LINK"
    echo "The password for the zip file is: $ZIP_PASSWORD"
else
    echo "Proxy list file not found!"
fi
