#!/bin/bash
while true; do
  clear
  echo "--------- CTTN VPS MENU ----------"
  echo "1) Tạo Website"
  echo "2) Tạo Database"
  echo "3) Quản lý Firewall"
  echo "4) Cập nhật hệ thống"
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
