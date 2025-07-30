#!/bin/bash

#==============================
# CTTN VPS AUTO INSTALL SCRIPT
# Compatible: Ubuntu, Debian, CentOS, Rocky, AlmaLinux
# Usage: bash <(curl -s https://raw.githubusercontent.com/cttn/cttnvps/main/install.sh)
#==============================

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
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

# Update system
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
    echo "Unsupported OS. Exiting."
    exit 1
    ;;
esac

# Install basic packages
case $OS in
  ubuntu|debian)
    apt install -y curl wget unzip sudo nano htop net-tools ufw
    ;;
  centos|almalinux|rocky)
    dnf install -y curl wget unzip sudo nano htop net-tools firewalld
    systemctl enable --now firewalld
    ;;
esac

# Add alias to run menu
echo -e "#!/bin/bash\ncd /opt/cttnvps && bash menu.sh" > /usr/local/bin/cttnvps
chmod +x /usr/local/bin/cttnvps

# Create basic menu
mkdir -p /opt/cttnvps
cat > /opt/cttnvps/menu.sh <<'EOF'
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
EOF
chmod +x /opt/cttnvps/menu.sh

echo "-----------------------------------"
echo " Cài đặt hoàn tất. Gõ lệnh: cttnvps "
echo " để mở menu quản trị VPS đơn giản.  "
echo "-----------------------------------"
