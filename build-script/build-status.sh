#!/bin/sh
echo "|Build|Chroot|"
echo "|---|---|"
./kernel-mock.sh -l $@ | awk '{ print "|[" $2 "](" $3 ")|"i $1 "|" }'
