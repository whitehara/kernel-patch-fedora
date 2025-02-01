#!/bin/sh

# change PREEMPT config

cd /builddir/build/SOURCES

# Since kernel version >= 6.12, there are some config files for the CONFIG_PREEMPT_RT in Fedora.
if [ -f kernel-x86_64-rt-fedora.config ]; then
        # We need to modify preemptive configs to the config files.
        for i in `grep -l "# CONFIG_PREEMPT_RT is not set" kernel-*.config`
        do
                sed -i -e 's/^# \(CONFIG_PREEMPT\) is not set/\1\=y/g' \
                        -e 's/^\(CONFIG_PREEMPT_VOLUNTARY\)=y/# \1 is not set/g' \
                        -e 's/^\(CONFIG_PREEMPT_LAZY\)=y/# \1 is not set/g' \
                        $i
        done
else

        # Add preempt configs for the kernel version <=6.11
        test -f kernel-local.preempt && (cat kernel-local.preempt ; echo ) >> kernel-local
fi