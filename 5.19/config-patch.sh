#!/bin/sh

# add PREEMPT config

for i in kernel-*.config
do
cat << EOF >> $i
## for tkg
CONFIG_SCHED_ALT=y
CONFIG_SCHED_BMQ=y
# CONFIG_SCHED_PDS is not set
# CONFIG_HZ_750 is not set
CONFIG_WINESYNC=y
CONFIG_ZENIFY=y
CONFIG_USER_NS_UNPRIVILEGED=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE_O3 is not set
# CONFIG_LRU_GEN is not set
## for march
# CONFIG_MK8SSE3 is not set
# CONFIG_MK10 is not set
# CONFIG_MBARCELONA is not set
# CONFIG_MBOBCAT is not set
# CONFIG_MJAGUAR is not set
# CONFIG_MBULLDOZER is not set
# CONFIG_MPILEDRIVER is not set
# CONFIG_MSTEAMROLLER is not set
# CONFIG_MEXCAVATOR is not set
# CONFIG_MZEN is not set
# CONFIG_MZEN2 is not set
# CONFIG_MZEN3 is not set
# CONFIG_MNEHALEM is not set
# CONFIG_MWESTMERE is not set
# CONFIG_MSILVERMONT is not set
# CONFIG_MGOLDMONT is not set
# CONFIG_MGOLDMONTPLUS is not set
# CONFIG_MSANDYBRIDGE is not set
# CONFIG_MIVYBRIDGE is not set
# CONFIG_MHASWELL is not set
# CONFIG_MBROADWELL is not set
# CONFIG_MSKYLAKE is not set
# CONFIG_MSKYLAKEX is not set
# CONFIG_MCANNONLAKE is not set
# CONFIG_MICELAKE is not set
# CONFIG_MCASCADELAKE is not set
# CONFIG_MCOOPERLAKE is not set
# CONFIG_MTIGERLAKE is not set
# CONFIG_MSAPPHIRERAPIDS is not set
# CONFIG_MROCKETLAKE is not set
# CONFIG_MALDERLAKE is not set
# CONFIG_MNATIVE_INTEL is not set
# CONFIG_MNATIVE_AMD is not set
# CONFIG_GENERIC_CPU2 is not set
# CONFIG_GENERIC_CPU3 is not set
# CONFIG_GENERIC_CPU4 is not set
EOF

sed -e "s/CONFIG_CRYPTO_XXHASH=.$/CONFIG_CRYPTO_XXHASH=y/g" $i > $i.tmp
mv $i.tmp $i
sed -e "s/CONFIG_CRYPTO_BLAKE2B=.$/CONFIG_CRYPTO_BLAKE2B=y/g" $i > $i.tmp
mv $i.tmp $i
done
