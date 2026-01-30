#!/bin/bash
# Network Optimius
# Created By KarmsDev V1.0
# Latest update: 30/1/2026
# Open Source, privacy-focused, secure

LOGFILE="/var/log/noptimius.log"

# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo ./noptimius.sh)"
  exit 1
fi

echo "Welcome to Network Optimius Project!"
echo "-------------------DNS Optimization ----------------------------"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}
Dnss() {
  local Dns=("1.1.1.1" "8.8.8.8" "9.9.9.9") # Add more if desired
  local best_score=999999
  local fastest_dns=""

  log "Starting DNS performance test..."

  for dn in "${Dns[@]}"; do
    log "Pinging $dn ..."
    local result
    result=$(ping -c 10 "$dn" 2>/dev/null)

    avg_ping=$(echo "$result" | awk -F'=' '/time=/{sum+=$4} END{if(NR>0) print sum/NR; else print 999999}')
    loss=$(echo "$result" | awk -F',' '/packet loss/ {gsub(/[^0-9.]/,"",$3); print $3}')
    [[ -z "$loss" ]] && loss=100 # if ping failed
    jitter=$(echo "$result" | awk -F'=' '/time=/{a[NR]=$4} END{sum=0; for(i=1;i<=NR;i++){sum+=(a[i]-('"$avg_ping"'))^2} if(NR>0) print sqrt(sum/NR); else print 0}')

    score=$(awk -v avg="$avg_ping" -v loss="$loss" -v jitter="$jitter" 'BEGIN{print avg + loss*10 + jitter*2}')

    echo "$dn -> avg:${avg_ping}ms, loss:${loss}%, jitter:${jitter}, score:${score}"

    # Selection of best DNS to use
    local is_better
    is_better=$(awk -v s="$score" -v best="$best_score" 'BEGIN{print (s<best)?1:0}')
    if [[ $is_better -eq 1 ]]; then
      best_score=$score
      fastest_dns=$dn
    fi
  done

  echo "--------------------------------------------------"
  echo "Best DNS selected: $fastest_dns (score $best_score)"

  # Apply DNS to active connection
  local conn
  conn=$(nmcli -t -f NAME,DEVICE connection show --active | cut -d: -f1 | head -n1)
  nmcli connection modify "$conn" ipv4.dns "$fastest_dns" ipv4.ignore-auto-dns yes
  nmcli connection up "$conn" >/dev/null
  log "DNS updated for connection: $conn"
}

SetupCron() {
  local dest_dir="/etc/noptimius"
  mkdir -p "$dest_dir"

  cp "$0" "$dest_dir/noptimius.sh"
  chmod +x "$dest_dir/noptimius.sh"

  echo "Enter custom interval for DNS optimizer (e.g., 30m, 1h, 1d, 1w):"
  read -rp "Interval: " interval

  local cron_expr=""

  case "$interval" in
  *m) # minutes
    local min=${interval%m}
    cron_expr="*/$min * * * * $dest_dir/noptimius.sh"
    ;;
  *h) # hours
    local hr=${interval%h}
    cron_expr="0 */$hr * * * $dest_dir/noptimius.sh"
    ;;
  *d) # days
    local day=${interval%d}
    cron_expr="0 0 */$day * * $dest_dir/noptimius.sh"
    ;;
  *w) # weeks
    local wk=${interval%w}
    cron_expr="0 0 * * $(awk -v w="$wk" 'BEGIN{print w%7}') $dest_dir/noptimius.sh"
    ;;
  *)
    echo "Invalid interval. Use 30m, 1h, 1d, or 1w."
    return
    ;;
  esac

  # Remove existing cron for this script first
  crontab -l 2>/dev/null | grep -Fv "$dest_dir/noptimius.sh" | crontab -

  # Add new cron job
  (
    crontab -l 2>/dev/null
    echo "$cron_expr"
  ) | crontab -
  echo "Cron job added: $cron_expr"
}

RestoreDNS() {
  local conn
  conn=$(nmcli -t -f NAME,DEVICE connection show --active | cut -d: -f1 | head -n1)

  log "Restoring DNS settings to DHCP for connection: $conn..."
  nmcli connection modify "$conn" ipv4.ignore-auto-dns no
  nmcli connection modify "$conn" ipv4.dns ""
  nmcli connection up "$conn" >/dev/null
  log "DNS restored to automatic DHCP."

  # Remove cron
  local dest_dir="/etc/noptimius"
  crontab -l 2>/dev/null | grep -Fv "$dest_dir/noptimius.sh" | crontab -
  log "Cron job removed if existed."

  # Delete folder
  if [[ -d "$dest_dir" ]]; then
    rm -rf "$dest_dir"
    log "Deleted folder $dest_dir and all its contents."
  else
    log "Folder $dest_dir does not exist."
  fi

  echo "Restore completed."
}

echo "Select an option:"
echo "1) Run DNS optimizer and setup cron"
echo "2) Setup automatic DNS optimizer with custom interval  "
echo "3) Restore DNS to DHCP and remove cron"
read -rp "Enter choice [1-3]: " choice

case $choice in
1)
  Dnss

  ;;
2)
  SetupCron

  ;;
3)
  RestoreDNS
  ;;
*)
  echo "Invalid choice."
  exit 1
  ;;
esac
