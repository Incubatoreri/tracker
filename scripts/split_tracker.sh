#!/bin/bash
INPUT_FILE="trackers_all.txt"  # 修改为新文件名
DOMAIN_FILE="output/pt_tracker_domain.txt"
IP_FILE="output/pt_tracker_ip.txt"
mkdir -p output
> "$DOMAIN_FILE"
> "$IP_FILE"
if [ ! -f "$INPUT_FILE" ]; then
  echo "错误：$INPUT_FILE 不存在"
  exit 1
fi
while IFS= read -r line; do
  [ -z "$line" ] && continue
  if ! echo "$line" | grep -q "://"; then
    echo "跳过无效行: $line"
    continue
  fi
  tracker=$(echo "$line" | sed 's|^\(http\|udp\|wss\)://||')
  host=$(echo "$tracker" | cut -d'/' -f1 | cut -d':' -f1)
  if [ -z "$host" ]; then
    echo "主机提取失败: $line"
    continue
  fi
  if echo "$host" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "IPv4: $host"
    echo "$host" >> "$IP_FILE"
  elif echo "$host" | grep -qE '^[0-9a-fA-F:]+(:[0-9a-fA-F:]+)*$'; then
    clean_host=$(echo "$host" | sed 's/^\[\(.*\)\]$/\1/')
    if echo "$clean_host" | grep -qE '^[0-9a-fA-F:]+(:[0-9a-fA-F:]+)*$'; then
      echo "IPv6: $clean_host"
      echo "$clean_host" >> "$IP_FILE"
    else
      echo "域名（非 IPv6）: $host"
      echo "$host" >> "$DOMAIN_FILE"
    fi
  else
    echo "域名: $host"
    echo "$host" >> "$DOMAIN_FILE"
  fi
done < "$INPUT_FILE"
sort -u "$DOMAIN_FILE" -o "$DOMAIN_FILE"
sort -u "$IP_FILE" -o "$IP_FILE"
echo "域名已保存到 $DOMAIN_FILE"
echo "IP地址已保存到 $IP_FILE"
