#!/bin/bash

# CTTN VPS AUTO INSTALLER

if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script với quyền root!"
  exit 1
fi

# Phát hiện OS
source /etc/os-release
OS=$ID
VERSION=$VERSION_ID

echo "==> Cập nhật hệ thống cho $PRETTY_NAME..."

case "$OS" in
  ubuntu|debian)
    apt update && apt -y upgrade
    apt install -y curl wget sudo nano htop net-tools ufw unzip
    ;;
  centos)
    yum -y update
    yum install -y curl wget sudo nano htop net-tools unzip firewalld
    systemctl enable --now firewalld
    ;;
  almalinux|rocky)
    dnf -y update
    dnf install -y curl wget sudo nano htop net-tools unzip firewalld
    systemctl enable --now firewalld
    ;;
  *)
    echo "Hệ điều hành không được hỗ trợ"
    exit 1
    ;;
esac

# Tạo alias
echo -e "#!/bin/bash\ncd /opt/cttnvps && bash menu.sh" > /usr/local/bin/cttnvps
chmod +x /usr/local/bin/cttnvps

# Copy menu vào /opt
mkdir -p /opt/cttnvps
cp menu/menu.sh /opt/cttnvps/menu.sh
chmod +x /opt/cttnvps/menu.sh

echo "✅ Cài đặt hoàn tất! Gõ 'cttnvps' để mở menu."


