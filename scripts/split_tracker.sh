#!/bin/bash
INPUT_FILE="trackers.txt"
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
  tracker=$(echo "$line" | sed 's|^\(http\|udp\|wss\)://||')
  host=$(echo "$tracker" | cut -d'/' -f1 | cut -d':' -f1)
  if echo "$host" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "$host" >> "$IP_FILE"
  elif echo "$host" | grep -qE '^\[?[0-9a-fA-F:]+]?$'; then
    echo "$host" | sed 's/^\[\(.*\)\]$/\1/' >> "$IP_FILE"
  else
    echo "$host" >> "$DOMAIN_FILE"
  fi
done < "$INPUT_FILE"
sort -u "$DOMAIN_FILE" -o "$DOMAIN_FILE"
sort -u "$IP_FILE" -o "$IP_FILE"
echo "域名已保存到 $DOMAIN_FILE"
echo "IP地址已保存到 $IP_FILE"
EOF
