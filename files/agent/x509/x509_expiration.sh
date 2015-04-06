#!/bin/bash

error() {
    echo "ERROR: $*"
}

die() {
    error "$*"
    exit 1
}

CERT="$1"

if [ -z "$CERT" ]; then
    die "Must provide X509 certificate as argument"
fi

END_DATE="$(openssl x509 -enddate -noout -in ${CERT} | sed -n 's/notAfter=//p')"
NOW="$(date '+%s')"
if [[ $END_DATE ]]; then
    SEC_LEFT="$(date '+%s' --date "${END_DATE}")"
    echo $((($SEC_LEFT-$NOW)/24/3600))
else
    die "Unable to determine certificate end date."
fi

exit 0
