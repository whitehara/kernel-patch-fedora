#/bin/sh
echo This script copies essential files from ../$1 to ../$2
echo You also need to modify some files in ../$2

if [ ! -d ../$1 ]; then
    echo "Directory FROM: ../$1 does not exist"
    exit 1
fi

if [ ! -d ../$2 ]; then
    echo "Directory TO: ../$2 does not exist"
    exit 1
fi

# Copy scripts
cp -v ../$1/*.sh ../$2

# Copy patches
cp -v ../$1/more-ISA-levels-and-uarches-for-kernel-*.patch ../$2
cp -v ../$1/0099-fix-confdata.patch ../$2
cp -v ../$1/amdgpu-ignore-min-pcap.patch ../$2

# Copy cjktty patches
cp -v ../$1/cjktty-*.patch ../$2
mv -v ../$2/cjktty-$1.patch ../$2/cjktty-$2.patch

# Modify scripts version
sed -i -e "s/$1/$2/g" ../$2/*.sh
PRJC_REL=`ls ../$2/0009-prjc_v$2-r*.patch | sed -e "s/^.*0009-prjc_v$2-r\([0-9]\).*$/\1/g"`
sed -i -e "s/PRJC_RELEASE=.*/PRJC_RELEASE=$PRJC_REL/g" ../$2/spec-mod.sh