#!/bin/bash
while true; do
  clear
  echo "--------- CTTN VPS MENU ----------"
  echo "1) Tạo Website"
  echo "2) Tạo Database"
  echo "3) Quản lý Firewall"
  echo "4) Cập nhật hệ thống"
  echo "5) Gỡ Cài Đặt CTTN VPS Script"
  echo "0) Thoát"
  echo "----------------------------------"
  read -p "Chọn một tùy chọn: " choice
  case $choice in
    1)
      read -p "Nhập domain (ví dụ: mysite.local): " domain
      mkdir -p /var/www/$domain/public_html
      chown -R www-data:www-data /var/www/$domain
      chmod -R 755 /var/www

      echo "<h1>Website $domain đã được tạo!</h1>" > /var/www/$domain/public_html/index.html

      if [ -d /etc/nginx/sites-available ]; then
        cat > /etc/nginx/sites-available/$domain <<EOF
server {
    listen 80;
    server_name $domain;
    root /var/www/$domain/public_html;
    index index.html index.php;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
        echo "✅ Website $domain đã tạo xong (NGINX)."
      else
        echo "❌ Không tìm thấy cấu hình NGINX."
      fi

      read -p "Nhấn Enter để quay lại menu"
      ;;
    2)
      read -p "Tên database: " dbname
      read -p "Tên user: " dbuser
      read -s -p "Mật khẩu cho user: " dbpass
      echo ""

      if command -v mysql >/dev/null 2>&1 || command -v mariadb >/dev/null 2>&1; then
        mysql -u root <<MYSQL
CREATE DATABASE $dbname;
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL
        echo "✅ Đã tạo database và user thành công!"
      else
        echo "❌ MySQL/MariaDB chưa được cài hoặc không khả dụng."
      fi

      read -p "Nhấn Enter để quay lại menu"
      ;;
    3)
      echo "Quản lý firewall..."
      if command -v ufw >/dev/null 2>&1; then
        sudo ufw status verbose
      elif command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --list-all
      else
        echo "❌ Không tìm thấy UFW hoặc Firewalld."
      fi
      read -p "Nhấn Enter để quay lại menu"
      ;;
    4)
      echo "Đang cập nhật hệ thống..."
      if [ -f /etc/debian_version ]; then
        apt update && apt -y upgrade
      else
        dnf -y update || yum -y update
      fi
      read -p "Nhấn Enter để quay lại menu"
      ;;
    5)
      read -p "Bạn có chắc chắn muốn GỠ CÀI ĐẶT CTTN VPS? (y/N): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "🔁��� Đang gỡ cài đặt..."
        rm -rf /opt/cttnvps
        rm -f /usr/local/bin/cttnvps
        echo "✅ Đã gỡ thành công CTTN VPS Script."

        read -p "Bạn có muốn gỡ các gói liên quan (nguy hiểm)? (y/N): " remove_pkgs
        if [[ "$remove_pkgs" =~ ^[Yy]$ ]]; then
          if command -v apt >/dev/null 2>&1; then
            apt remove --purge -y nginx php mysql-server mariadb-server ufw
          elif command -v dnf >/dev/null 2>&1; then
            dnf remove -y nginx php mariadb-server firewalld
          elif command -v yum >/dev/null 2>&1; then
            yum remove -y nginx php mariadb-server firewalld
          fi
          echo "✅ Đã gỡ các gói cài đặt cơ bản."
        fi

        echo "Hệ thống đã được làm sạch."
        read -p "Nhấn Enter để thoát..."
        exit 0
      else
        echo "❎ Hủy gỡ cài đặt."
        sleep 2
      fi
      ;;
    0)
      echo "Tạm biệt!"
      exit 0
      ;;
    *)
      echo "Lựa chọn không hợp lệ."
      sleep 1
      ;;
  esac
done
