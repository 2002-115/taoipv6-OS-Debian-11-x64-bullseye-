#!/bin/bash

# Nhận đầu vào từ người dùng và kiểm tra đầu vào
while true; do
    read -p "Nhập số lượng proxy cần tạo (1-9999) [mặc định: 100]: " proxy_count
    proxy_count=${proxy_count:-100} # Nếu người dùng không nhập gì, mặc định là 100
    if [[ "$proxy_count" =~ ^[0-9]+$ ]] && [ "$proxy_count" -ge 1 ] && [ "$proxy_count" -le 9999 ]; then
        break
    else
        echo "Vui lòng nhập một số hợp lệ từ 1 đến 9999."
    fi
done

# Tạo ngẫu nhiên username và password
username=$(openssl rand -base64 12)
password=$(openssl rand -base64 12)

# In thông tin đã nhập và tạo ngẫu nhiên
echo "Số lượng proxy cần tạo: $proxy_count"
echo "Username: $username"
echo "Password: $password"

# Tạo file cấu hình proxy (giả định bạn có sẵn mã hoặc lệnh để tạo proxy)
# Dưới đây là ví dụ về cách tạo file cấu hình đơn giản cho mục đích minh họa
cat <<EOF > ipv6-proxy-config.txt
Proxy count: $proxy_count
Username: $username
Password: $password
EOF

# Nén các tệp tạo ra thành file zip với mật khẩu ngẫu nhiên
zip_password=$(openssl rand -base64 12)
zip -P "$zip_password" ipv6-proxy-config.zip ipv6-proxy-config.txt

# Tải tệp zip lên bashupload.com
upload_response=$(curl -s --upload-file ipv6-proxy-config.zip https://bashupload.com/ipv6-proxy-config.zip)

# Hiển thị đường link tải về và mật khẩu file zip
echo "Đường link tải về: $upload_response"
echo "Mật khẩu file zip: $zip_password"
