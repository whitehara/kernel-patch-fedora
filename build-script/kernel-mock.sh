#!/bin/sh

export NUM_PARALLEL=8
export PATCHDIR=../
export RESULTDIR=../results

function download_srpm () {
    [[ $@ =~ ^# ]] && return 1

    (cd $RESULTDIR && ionice -c3 koji download-build --rpm kernel-$1.src.rpm)
}

function make_srpm () {
    [[ $@ =~ ^# ]] && return 1
    [ $# -le 3 ] && return 1

    local VER=$1  # 6.3.4-200.fc38
    local PROJECTID=$2 # -tkg
    local CUSTOMTAG=$3 # _tkg
    local BUILDTIMEOUT=25200

    local OS="fedora-${VER##*fc}-x86_64"
    local SRPM=kernel-$VER.src.rpm

    local MOCK="mock -r $OS --uniqueext=$PROJECTID "
    $DEBUG || MOCK="ionice -c3 $MOCK -q "

    if [ ! -d $PATCHDIR/${VER%.*-*} ]; then
	    echo "ERROR: $PATCHDIR/${VER%.*-*} is not found."
	    return 1
    fi
    # Setup an environment
    $MOCK --init
    $MOCK --copyin $RESULTDIR/$SRPM /
    $MOCK --shell rpm -Uvh /$SRPM
    $MOCK --copyin $PATCHDIR/${VER%.*-*}/* $PATCHDIR/kernel-local/* /builddir/build/SOURCES

    # Custom files
    $MOCK --shell "(cat /builddir/build/SOURCES/kernel-local.general ; echo ) >> /builddir/build/SOURCES/kernel-local; (cd /builddir/build/SOURCES && ./config-patch.sh)"

    local PARAM=${@:4}
    for i in ${PARAM[@]}
    do
        echo Feature: $i
        $MOCK --shell -- "test -f /builddir/build/SOURCES/kernel-local.$i && (cat /builddir/build/SOURCES/kernel-local.$i ; echo ) >> /builddir/build/SOURCES/kernel-local"
        $DEBUG && $MOCK --shell -- "cat /builddir/build/SOURCES/kernel-local"

        if [ $i = "bmq" -o $i = "pds" -o $i = "cfs" ]; then
            echo CustomTag: $CUSTOMTAG
            echo Scheduler: $i
            $MOCK --shell "cd /builddir/build/SPECS && /builddir/build/SOURCES/spec-mod.sh $CUSTOMTAG $i"
        fi
    done
    
    # Debug shell
    if $DEBUG ; then
        $MOCK --installdeps $RESULTDIR/$SRPM
        $MOCK --install pxz vi less
        $MOCK --shell "sed -i -e 's/\(git --work-tree=. apply\)/\1 --reject/g' /builddir/build/SPECS/kernel.spec "
        $MOCK --shell "rpmbuild -bp /builddir/build/SPECS/kernel.spec"
        echo "$MOCK --shell"
        $MOCK --shell
        exit 0
    fi
    
    # New SRPM name with custom tags
    local NEWSRPM=kernel-${VER%.*}${CUSTOMTAG}.${VER##*.}.src.rpm
    # Make srpm
    $MOCK --shell "rpmbuild -bs /builddir/build/SPECS/kernel.spec"
    # Copy srpm to $RESULTDIR
    $MOCK --copyout /builddir/build/SRPMS/$NEWSRPM $RESULTDIR

    # Upload to Copr
    if $USECOPR ; then
	    # Run copr build
	    nice -19 copr-cli build --bootstrap on --isolation nspawn --timeout $BUILDTIMEOUT --nowait -r $OS --background kernel$PROJECTID $RESULTDIR/$NEWSRPM
    else
	    # Build local without debug packages
	    #$MOCK --shell "rpmbuild -ba --without debug --without debuginfo /builddir/build/SPECS/kernel.spec"
	    echo "Start local build."
	    $MOCK --install pxz
	    $MOCK --no-clean --resultdir $RESULTDIR --rebuild $RESULTDIR/$NEWSRPM
	    if [ $? -ne 0 ]; then
		    echo "ERROR: local build."
		    return 1
	    else
		    echo "Local build finished."
	    fi
    fi

    $MOCK --scrub=chroot --scrub=bootstrap
}
export -f make_srpm

# Main
DEBUG=false
USECOPR=false
while getopts cdh OPT
do
    case $OPT in
        c) USECOPR=true ;;
        d) DEBUG=true ;;
        h) echo "Usage: $0 [-c] [-d] [-h]"
            echo "-c: Build on Copr.\
		    With this option, build on copr environment. you must make your project 'kernel-tkg', etc. on your account.\
		    Without this option, rpms are built on this machine and put them into the results dir." 
            echo "-d: DEBUG mode. Enter the shell after the first kernel setup." 
            echo "-h: Show this help." 
            exit 0
            ;;
        *) DEBUG=false ;;
    esac
done
export DEBUG
export USECOPR

# Make $RESULTDIR if it doesn't exist.
[ ! -d $RESULTDIR ] && mkdir $RESULTDIR

while read VER
do
    echo $VER
    download_srpm $VER || continue

    # Use first version for debug
    $DEBUG && break

    cat support-features | xargs -I% -P${NUM_PARALLEL} sh -c  "make_srpm $VER %"
done < support-vers

# Use first version and feature for debug
if $DEBUG ; then
    while read FEAT
    do
        [[ $FEAT =~ ^# ]] && continue
        echo $FEAT
        break
    done < support-features
    echo Feature: $FEAT
    make_srpm $VER $FEAT
fi
