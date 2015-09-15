#!/usr/bin/env python

import htcondor
import sys, socket
from optparse import OptionParser

def main():
    parser = OptionParser()
    parser.add_option("-c", "--ce", dest="ce", help="HTCondor-CE host name", default=socket.getfqdn())
    parser.add_option("-p", "--port", dest="port", help="HTCondor-CE port", default='9619')
    parser.add_option("-a", "--ad", dest="ad", help="ClassAd to query")

    (options, args) = parser.parse_args()

    if not options.ad:
        parser.error("-a/--ad not given")
        return 1

    coll = htcondor.Collector("%s:%s" % (options.ce, options.port))
    schedd_ads = coll.query(htcondor.AdTypes.Schedd, 'Name=?="%s"' % options.ce)
    value = schedd_ads[0].get(options.ad, None)
    if value is None:
        return 1
    else:
        print value
    return 0

if __name__ == '__main__':
    sys.exit(main())
