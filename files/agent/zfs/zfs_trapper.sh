#!/bin/bash

DEF_ZPOOLS="tank"
DEF_FILESYSTEMS="tank"

usage () {
  cat <<-EOF
usage: $(basename $0) [OPTIONS]

Get ZFS metrics and send them to Zabbix using zabbix-sender.

OPTIONS:

  -z, --zpools        zpools to monitor (default: $DEF_ZPOOLS)
  -f, --filesystems   zfs filesystems to monitor (default: $DEF_FILESYSTEMS)
  -h, --help          Show usage

EXAMPLE:

Monitor zpools tank and tank2.  Monitor filesystems tank and tank/foo.

$(basename $0) --zpools "tank tank2" --filesystems "tank tank/foo"

NOTE: Multiple values for an option must be enclosed in quotes.

EOF
}

ARGS=`getopt -o z:f:h -l zpools:,filesystems:,help -n "$0" -- "$@"`

[ $? -ne 0 ] && { usage; exit 1; }

eval set -- "${ARGS}"

while true; do
  case "$1" in
    -h|--help) usage ; exit 0 ;;
    -z|--zpools) ZPOOLS=$2 ; shift 2 ;;
    -f|--filesystems) FILESYSTEMS=$2 ; shift 2 ;;
    --) shift ; break ;;
    *) break ;;
  esac
done

HOST=$(hostname -f)
ZABBIX_SERVER=$(egrep "^Server=" /etc/zabbix_agentd.conf | awk -F'=' '{ print $2 }' | cut -d',' -f1)

ZABBIX_SEND_DATAFILE="/tmp/$(basename $0).txt"
ZFS_KEY_NAME='zfs.trapper.get'
ZPOOL_KEY_NAME='zpool.trapper.get'

ZFS_GET=(
'available'
'used'
'total'
'pavailable'
)

ZPOOL_GET=(
'health'
)

time=$(date +%s)

output=()

# Collect zpool information
for zpool in ${ZPOOLS:-$DEF_ZPOOLS}; do
  zpool_results=($(/sbin/zpool list -H -o health ${zpool}))
  for ((i=0; i < ${#zpool_results[@]}; i++)); do
    output+=("${HOST} ${ZPOOL_KEY_NAME}[${ZPOOL_GET[$i]},${zpool}] ${time} ${zpool_results[$i]}")
  done
done

# Collect filesystem information
for filesystem in ${FILESYSTEMS:-$DEF_FILESYSTEMS}; do
  zfs_results=($(/sbin/zfs get -H -p -o value available,used ${filesystem}))
  zfs_results[2]=$((zfs_results[0]+zfs_results[1]))
  zfs_results[3]=`awk -v a=${zfs_results[0]} -v t=${zfs_results[2]} 'BEGIN { print (a / t) * 100 }'`

  for ((i=0; i < ${#zfs_results[@]}; i++)); do
     output+=("${HOST} ${ZFS_KEY_NAME}[${ZFS_GET[$i]},${filesystem}] ${time} ${zfs_results[$i]}")
  done
done

echo "Writing results to ${ZABBIX_SEND_DATAFILE}"

printf -- '%s\n' "${output[@]}" > $ZABBIX_SEND_DATAFILE

sender_cmd="zabbix_sender -z ${ZABBIX_SERVER} -p 10051 -T -i ${ZABBIX_SEND_DATAFILE}"
echo "Executing: ${sender_cmd}"

eval $sender_cmd

exit 0
