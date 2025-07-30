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
      echo "Tạo website... (đang cập nhật)"
      sleep 2
      ;;
    2)
      echo "Tạo database... (đang cập nhật)"
      sleep 2
      ;;
    3)
      echo "Quản lý firewall..."
      sudo ufw status || firewall-cmd --state
      read -p "(Enter để tiếp tục)"
      ;;
    4)
      echo "Đang cập nhật hệ thống..."
      if [ -f /etc/debian_version ]; then
        apt update && apt -y upgrade
      else
        dnf -y update || yum -y update
      fi
      read -p "(Enter để quay lại menu)"
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
