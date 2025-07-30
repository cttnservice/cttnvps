#!/bin/bash

#==============================
# CTTN VPS AUTO INSTALL SCRIPT
# Compatible: Ubuntu, Debian, CentOS, Rocky, AlmaLinux
# Usage: bash <(curl -s https://raw.githubusercontent.com/cttnservice/cttnvps/main/install.sh)
#==============================

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Vui lòng chạy script với quyền root"
  exit 1
fi

# Detect OS
source /etc/os-release
OS=$ID
VERSION=$VERSION_ID

clear
echo "-----------------------------------"
echo "      CTTN VPS Installer v1.0       "
echo "-----------------------------------"
echo "Detected OS: $PRETTY_NAME"
echo "-----------------------------------"

# Update hệ thống
case $OS in
  ubuntu|debian)
    apt update && apt -y upgrade
    ;;
  centos)
    yum -y update
    ;;
  almalinux|rocky)
    dnf -y update
    ;;
  *)
    echo "❌ Không hỗ trợ hệ điều hành này. Thoát."
    exit 1
    ;;
esac

# Cài các gói cơ bản
case $OS in
  ubuntu|debian)
    apt install -y curl wget unzip sudo nano htop net-tools nginx mariadb-server php php-mysql php-cli php-curl php-zip php-gd php-mbstring php-xml php-bcmath php-fpm phpmyadmin
    ;;
  centos|almalinux|rocky)
    dnf install -y epel-release
    dnf install -y curl wget unzip sudo nano htop net-tools nginx mariadb-server php php-mysqlnd php-cli php-curl php-zip php-gd php-mbstring php-xml php-bcmath php-fpm
    ;;
esac

# Khởi động dịch vụ
systemctl enable --now nginx
systemctl enable --now mariadb
systemctl enable --now php-fpm

# Tạo alias để chạy menu dễ dàng
echo -e "#!/bin/bash\ncd /opt/cttnvps && bash menu/menu.sh" > /usr/local/bin/cttnvps
chmod +x /usr/local/bin/cttnvps

# Tạo thư mục và script menu
mkdir -p /opt/cttnvps/menu

cat > /opt/cttnvps/menu/menu.sh <<'EOF'
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
      chown -R $USER:$USER /var/www/$domain/public_html
      chmod -R 755 /var/www

      echo "<h1>Website $domain đã được tạo!</h1>" > /var/www/$domain/public_html/index.html

      if [ -d /etc/nginx/sites-available ]; then
        cat > /etc/nginx/sites-available/$domain <<EOL
server {
    listen 80;
    server_name $domain;
    root /var/www/$domain/public_html;
    index index.html index.php;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL
        ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
        echo "✅ Website $domain đã được cấu hình (NGINX)"
      else
        echo "❌ Không tìm thấy cấu hình NGINX."
      fi
      read -p "Nhấn Enter để quay lại menu..."
      ;;
    2)
      read -p "Tên database: " dbname
      read -p "Tên user: " dbuser
      read -s -p "Mật khẩu cho user: " dbpass
      echo ""
      if command -v mysql >/dev/null 2>&1; then
        mysql -e "CREATE DATABASE $dbname;"
        mysql -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
        mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
        echo "✅ Tạo thành công database và user!"
      else
        echo "❌ MySQL/MariaDB không khả dụng!"
      fi
      read -p "Nhấn Enter để quay lại menu..."
      ;;
    3)
      echo "Firewall hiện tại:"
      sudo ufw status || firewall-cmd --state
      read -p "(Nhấn Enter để quay lại)"
      ;;
    4)
      echo "Đang cập nhật hệ thống..."
      if command -v apt >/dev/null 2>&1; then
        apt update && apt -y upgrade
      else
        dnf -y update || yum -y update
      fi
      read -p "Nhấn Enter để quay lại menu..."
      ;;
    5)
      read -p "Bạn có chắc chắn muốn gỡ CTTN VPS Script? (y/N): " confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf /opt/cttnvps
        rm -f /usr/local/bin/cttnvps
        echo "✅ Gỡ xong script."
        read -p "Gỡ thêm PHP, MariaDB, NGINX...? (y/N): " more
        if [[ "$more" =~ ^[Yy]$ ]]; then
          apt remove --purge -y nginx php mariadb-server phpmyadmin || dnf remove -y nginx php mariadb-server || yum remove -y nginx php mariadb-server
          echo "✅ Gỡ các gói xong!"
        fi
        exit 0
      fi
      ;;
    0)
      echo "Tạm biệt!"
      exit 0
      ;;
    *)
      echo "❌ Lựa chọn không hợp lệ!"
      sleep 1
      ;;
  esac
done
EOF

chmod +x /opt/cttnvps/menu/menu.sh

# Tạo menu trang web
mkdir -p /var/www/html/menu
cat > /var/www/html/menu/index.html <<EOM
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>CTTN VPS Menu</title></head>
<body>
<h1>CTTN VPS - Quản lý VPS của bạn</h1>
<ul>
  <li><a href="/phpmyadmin" target="_blank">phpMyAdmin - Quản lý DB</a></li>
  <li><a href="/menu">Menu quản lý CTTN VPS</a></li>
</ul>
</body>
</html>
EOM

# Link đến phpmyadmin nếu cần
[ ! -d /var/www/html/phpmyadmin ] && ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

echo "✅ Cài đặt hoàn tất! Gõ 'cttnvps' để mở menu quản lý VPS."
