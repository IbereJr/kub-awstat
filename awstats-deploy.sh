#!/bin/bash

kubectl -n web-apps delete configmap awstats-conf 2>/dev/null
kubectl -n web-apps create configmap awstats-conf --from-file=awstats.ibworks.conf  \
                                                  --from-file=awstats.tizio.conf  \
                                                  --from-file=default.conf  \
                                                  --from-file=extra.conf

