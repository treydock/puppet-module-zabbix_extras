#!/bin/bash

DEBUG=0

usage () {
cat << EOF
usage: $(basename $0) [OPTIONS] MOUNTPOINT

Print 1 if MOUNTPOINT is read-only, and 0 if MOUNTPOINT is read-write.

OPTIONS:

  -h, --help    Show this message
  --debug       Show debug output

EXAMPLE:

$(basename $0) /

EOF
}

ARGS=`getopt -o h -l help,debug -n "$0" -- "$@"`

[ $? -ne 0 ] && { usage; exit 1; }

eval set -- "${ARGS}"

while true; do
  case "$1" in
    -h|--help) usage ; exit 0 ;;
    --debug) DEBUG=1 ; shift ;;
    --) shift ; break ;;
  esac
done

[ -z $1 ] && { echo "Missing argument: MOUNTPOINT"; usage; exit 1; }

if [ $DEBUG -eq 1 ]; then
  set -x
fi

MNT=$1
IGNORE_FS="^(rootfs|/dev|/sys|devpts|tmpfs|none)\s|(/proc.*)"

LINE=`egrep -v $IGNORE_FS /proc/mounts | grep " $MNT "`

OPTS=`echo $LINE | cut -d ' ' -f4`

READ_WRITE_OPT=`echo $OPTS | cut -d, -f1`

case "$READ_WRITE_OPT" in
  rw) echo "0" ;;
  ro) echo "1" ;;
  *) exit 1
esac

exit 0
