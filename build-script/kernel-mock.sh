#!/bin/sh

"""
This script is used to create kernel SRPMs and build them locally or on Copr.
It uses Koji, Mock, and Copr-cli commands to manage the build process.

The script takes in a list of kernel versions and features, and then iterates over 
this list, creating a new SRPM for each version. It also handles patches and 
custom tags based on the features specified.

Options:
    -c: Build on Copr.
    -f: Specify Copr config file path. This option also enables '-c'.
    -d: DEBUG mode. Enter the shell after the first kernel version/feature setup.
    -l: Show Copr running builds and exit.
    -m: Show mock messages. This is default, unless '-d' is not used.
    -s: Make SRPMs only to the results dir.
    -h: Show this help.

Environment variables:
    NUM_PARALLEL: The number of parallel processes to use.
    PATCHDIR: Directory containing patches.
    RESULTDIR: Directory for storing build results.
"""

export NUM_PARALLEL=8
export PATCHDIR=../
export RESULTDIR=../results

function download_srpm () {
    [[ $@ =~ ^# ]] && return 1

    (cd $RESULTDIR && koji -q download-build --rpm kernel-$1.src.rpm)
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

    # New SRPM name with custom tags
    local NEWSRPM=kernel-${VER%.*}${CUSTOMTAG}.${VER##*.}.src.rpm

    local MOCK="mock -r $OS --uniqueext=$PROJECTID "
    $SHOWMESSAGE || MOCK="$MOCK -q "

    # If $NEWSRPM is already there, reuse it
    if [ ! $DEBUG ] && [ -f $RESULTDIR/$NEWSRPM ]; then
	    echo $NEWSRPM is already there. Reuse it.
    else

	    if [ ! -d $PATCHDIR/${VER%.*-*} ]; then
		    echo "ERROR: $PATCHDIR/${VER%.*-*} is not found."
		    return 1
	    fi
	    # Setup an environment
	    $MOCK --init
	    $MOCK --copyin $RESULTDIR/$SRPM /
	    $MOCK --shell rpm -Uvh /$SRPM
	    $MOCK --copyin $PATCHDIR/${VER%.*-*}/* $PATCHDIR/kernel-local/* /builddir/build/SOURCES

	    # Make kernel-local
	    $MOCK --shell "(cat /builddir/build/SOURCES/kernel-local.general ; echo ) >> /builddir/build/SOURCES/kernel-local; (cd /builddir/build/SOURCES && ./config-patch.sh)"

		# Modify kernel-local for each features
	    local PARAM=${@:4}
	    for i in ${PARAM[@]}
	    do
		echo Feature: $i
		$MOCK --shell -- "test -f /builddir/build/SOURCES/kernel-local.$i && (cat /builddir/build/SOURCES/kernel-local.$i ; echo ) >> /builddir/build/SOURCES/kernel-local"
		$DEBUG && $MOCK --shell -- "cat /builddir/build/SOURCES/kernel-local"

		# Attach patches to kernel.spec
		if [ $i = "eevdf" -o $i = "bmq" -o $i = "pds" -o $i = "cfs" ]; then
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
	    
	    # Make srpm
	    $MOCK --shell "rpmbuild -bs /builddir/build/SPECS/kernel.spec"
	    # Copy srpm to $RESULTDIR
	    $MOCK --copyout /builddir/build/SRPMS/$NEWSRPM $RESULTDIR
    fi

	# If only make SRPM, just return
    if $SRPMONLY ; then
	    # Clean chroot environments
	    $MOCK --scrub=chroot --scrub=bootstrap
	    return 0
    fi

    # Upload to Copr or build in the local environemnt
    if $USECOPR ; then
	    # Run copr build
		$COPR build --bootstrap on --isolation nspawn --timeout $BUILDTIMEOUT --nowait -r $OS --background kernel$PROJECTID $RESULTDIR/$NEWSRPM
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
COPR="copr-cli"
DEBUG=false
SHOWCOPRBUILDS=false
SHOWMESSAGE=false
USECOPR=false
SRPMONLY=false
while getopts cdf:hlms OPT
do
    case $OPT in
        c) USECOPR=true ;;
        d) SHOWMESSAGE=true
	       DEBUG=true ;;
		f) USECOPR=true
		   COPR="copr-cli --config $OPTARG" ;;
		l) SHOWCOPRBUILDS=true ;;
		m) SHOWMESSAGE=true ;;
        h) echo "Usage: $0 [-c] [-f config file path] [-d] [-l] [-m] [-s] [-h]"
            echo "    -c: Build on Copr."
		    echo "        With this option, build on copr environment."
			echo "        You must make your project 'kernel-tkg', etc. on your Copr account."
			echo "        If SRPMs are already in results dir, they are used."
		    echo "        Without this option, rpms are built on this machine and put them into the results dir. This is default."
            echo "    -d: DEBUG mode. Enter the shell after the first kernel version/feature setup."
            echo "    -f: Specify Copr config file path. This option also enable '-c' "
            echo "    -l: Show Copr running builds and exit."
            echo "    -m: Show mock messages. This is default, unless -d is not used." 
            echo "    -s: Make SRPMs only to the results dir." 
            echo "    -h: Show this help." 
            exit 0
            ;;
        s) SRPMONLY=true ;;
        *) DEBUG=false ;;
    esac
done
export DEBUG
export USECOPR
export COPR
export SRPMONLY
export SHOWCOPRBUILDS
export SHOWMESSAGE

# Make $RESULTDIR if it doesn't exist.
mkdir -p $RESULTDIR

# Show Copr builds and exit
if $SHOWCOPRBUILDS ; then
	while read FEAT
	do
        [[ $FEAT =~ ^# ]] && continue
		PRJ=`echo $FEAT | awk '{ print $1 }'`
		$COPR monitor --output-format text-row --fields chroot,pkg_version,url_build,state kernel$PRJ
	done < support-features
	exit 0
fi

# Download original srpm and make srpm,build
while read VER
do
    echo $VER
    download_srpm $VER || continue

    # Use first version for debug
    $DEBUG && break

    cat support-features | xargs -I% -P${NUM_PARALLEL} sh -c  "make_srpm $VER %"
done < support-vers

# Debug build, Use first version and feature
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
