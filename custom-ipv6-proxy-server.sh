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

# Chạy script gốc với các tham số đã được chỉnh sửa
wget https://raw.githubusercontent.com/Temporalitas/ipv6-proxy-server/master/ipv6-proxy-server.sh && chmod +x ipv6-proxy-server.sh
./ipv6-proxy-server.sh -s 64 -c $proxy_count -u $username -p $password -t http -r 10

# Nén các tệp tạo ra thành file zip với mật khẩu ngẫu nhiên
zip_password=$(openssl rand -base64 12)
zip -P "$zip_password" ipv6-proxy-config.zip ipv6-proxy-server.sh

# Tải tệp zip lên bashupload.com
upload_response=$(curl -s --upload-file ipv6-proxy-config.zip https://bashupload.com/ipv6-proxy-config.zip)

# Hiển thị đường link tải về và mật khẩu file zip
echo "Đường link tải về: $upload_response"
echo "Mật khẩu file zip: $zip_password"
