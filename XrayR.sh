#!/bin/bash

clear

# Hỏi thông tin chung
echo ""
read -p "  Nhập domain web (Bản Quyền 4gquocte.com không cần https://): " api_host
[ -z "${api_host}" ] && { echo "  Domain không được để trống."; exit 1; }
read -p "  Nhập key của web: " api_key
[ -z "${api_key}" ] && { echo "  Key không được để trống."; exit 1; }

# Hỏi số lượng node
read -p "  Nhập số lượng node cần cài (1 hoặc 2, mặc định 1): " node_count
echo "--------------------------------"
[ -z "${node_count}" ] && node_count="1"
if [[ "$node_count" != "1" && "$node_count" != "2" ]]; then
  echo "  Số lượng node không hợp lệ, chỉ chấp nhận 1 hoặc 2."
  exit 1
fi

# Lấy địa chỉ IP của VPS
vps_ip=$(hostname -I | awk '{print $1}')

# Khai báo mảng lưu thông tin node
declare -A nodes

# Hỏi thông tin cho từng node
for i in $(seq 1 $node_count); do
  echo ""
  echo "  [1] Vmess"
  echo "  [2] Vless"
  echo "  [3] Trojan"
  read -p "  Chọn loại Node: " NodeType
  if [ "$NodeType" == "1" ]; then
      NodeType="V2ray"
      NodeName="Vmess"
      EnableVless="false"
  elif [ "$NodeType" == "2" ]; then
      NodeType="V2ray"
      NodeName="Vless"
      EnableVless="true"
  elif [ "$NodeType" == "3" ]; then
      NodeType="Trojan"
      NodeName="Trojan"
      EnableVless="false"
  else
      echo "  Loại Node không hợp lệ, mặc định là Vmess"
      NodeType="V2ray"
      NodeName="Vmess"
      EnableVless="false"
  fi

  read -p "  Nhập ID Node: " node_id
  [ -z "${node_id}" ] && { echo "  ID Node không được để trống."; exit 1; }

  nodes[$i,NodeType]=$NodeType
  nodes[$i,NodeName]=$NodeName
  nodes[$i,node_id]=$node_id
  nodes[$i,CertDomain]=$vps_ip
  nodes[$i,EnableVless]=$EnableVless
done

# Hiển thị thông tin đã nhập và yêu cầu xác nhận
clear
echo ""
echo "  Thông tin cấu hình"
echo "--------------------------------"
echo "  Domain web: https://${api_host}"
echo "  Key web: ${api_key}"
echo "  Địa chỉ Node: ${nodes[$i,CertDomain]}"
for i in $(seq 1 $node_count); do
  echo ""
  echo "  Loại Node: ${nodes[$i,NodeName]}"
  echo "  ID Node: ${nodes[$i,node_id]}"
done
echo "--------------------------------"
read -p "  Bạn có muốn tiếp tục cài đặt không? (y/n, mặc định y): " confirm
confirm=${confirm:-y}
if [ "$confirm" != "y" ]; then
  echo "  Hủy bỏ cài đặt."
  exit 0
fi

# Hàm cài đặt
install_node() {
  local i=$1
  local NodeType=${nodes[$i,NodeType]}
  local node_id=${nodes[$i,node_id]}
  local CertDomain=${nodes[$i,CertDomain]}
  local EnableVless=${nodes[$i,EnableVless]}

  cat >>/etc/XrayR/config.yml<<EOF
  -
    PanelType: "V2board" # Panel type: SSpanel, V2board, PMpanel, Proxypanel, V2RaySocks
    ApiConfig:
      ApiH
