#!/bin/sh

if [ ! -d ../$1 ]; then
	echo "No such directory: ../$1"
	exit 1
else
	VER=$1
fi

cd ../$VER
wget https://raw.githubusercontent.com/CachyOS/kernel-patches/refs/heads/master/$VER/all/0001-cachyos-base-all.patch && \
sed -i -e "s/BUFSIZE 256/BUFSIZE 4096/g" 0001-cachyos-base-all.patch.1 && \
diff -u --color 0001-cachyos-base-all.patch 0001-cachyos-base-all.patch.1
