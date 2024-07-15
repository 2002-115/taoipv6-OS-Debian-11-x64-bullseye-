#!/bin/bash

# Function to display the main menu
show_menu() {
    echo "1. Số lượng proxy cần tạo"
    echo "2. Chọn mặc định HTTP"
    echo "3. Chọn SOCKS5"
    echo "4. Gỡ cài đặt"
    echo "5. Thoát"
}

# Function to display the proxy type menu
show_proxy_type_menu() {
    echo "Chọn loại proxy:"
    echo "2. HTTP"
    echo "3. SOCKS5"
    echo "5. Thoát"
}

# Function to generate random username and password
generate_random_credentials() {
    username=$(openssl rand -hex 4)
    password=$(openssl rand -hex 8)
}

# Function to create proxies
create_proxies() {
    read -p "Nhập số lượng proxy cần tạo: " count
    generate_random_credentials
    read -p "Nhập số lượng IP mỗi proxy (default 64): " subnet
    subnet=${subnet:-64}
    read -p "Nhập số lượng lần lặp lại (default 10): " repeat
    repeat=${repeat:-10}

    while true; do
        show_proxy_type_menu
        read -p "Chọn một tùy chọn: " proxy_choice

        case $proxy_choice in
            2)
                proxy_type="http"
                ./ipv6-proxy-server.sh -s $subnet -c $count -u $username -p $password -t $proxy_type -r $repeat
                break
                ;;
            3)
                proxy_type="socks5"
                ./ipv6-proxy-server.sh -s $subnet -c $count -u $username -p $password -t $proxy_type -r $repeat
                break
                ;;
            5)
                echo "Thoát."
                exit 0
                ;;
            *)
                echo "Lựa chọn không hợp lệ, vui lòng thử lại."
                ;;
        esac
    done

    # Upload the proxies list to bashupload.com with a password
    upload_proxies_list "$count" "$username" "$password" "$proxy_type"
}

# Function to upload proxies list to bashupload.com with a password
upload_proxies_list() {
    local count=$1
    local username=$2
    local password=$3
    local proxy_type=$4

    local file_path="/root/proxyserver/backconnect_proxies.list"

    if [ ! -f "$file_path" ]; then
        echo "File không tồn tại: $file_path"
        return 1
    fi

    # Generate formatted proxy list file
    local formatted_file_path="/root/proxyserver/formatted_backconnect_proxies.list"
    
    rm -f "$formatted_file_path" # Remove existing file if any
    
    for ((i=0; i<$count; i++)); do 
        echo "207.148.82.145:$((30000 + i)):$username:$password" >> "$formatted_file_path"
    done

    read -sp "Nhập mật khẩu để bảo vệ file tải lên: " upload_password

    upload_url=$(curl --upload-file "$formatted_file_path" https://bashupload.com/ --user "$username:$upload_password")
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "File đã được tải lên thành công!"
        echo "Bạn có thể tải file tại: $upload_url"
        echo ""
    else
        echo ""
        echo "Lỗi khi tải file lên."
        echo ""
    fi

}

# Main loop for the menu
while true; do
    show_menu
    read -p "Chọn một tùy chọn: " choice

    case $choice in
        1)
            create_proxies
            ;;
        2)
            proxy_type="http"
            echo "Đã chọn HTTP làm mặc định."
            ;;
        3)
            proxy_type="socks5"
            echo "Đã chọn SOCKS5 làm mặc định."
            ;;
        4)
            ./ipv6-proxy-server.sh --uninstall
            echo "Đã gỡ cài đặt."
            ;;
        5)
            echo "Thoát."
            exit 0
            ;;
        *)
            echo "Lựa chọn không hợp lệ, vui lòng thử lại."
            ;;
    esac
done
