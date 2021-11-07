#!/bin/sh

set -e

if [ -x /usr/local/bin/autorun.sh ]; then
    . /usr/local/bin/autorun.sh
fi

exec "$@"
