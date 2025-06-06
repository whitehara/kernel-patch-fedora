#!/bin/sh

# Add some configs

for i in kernel-*.config
do
cat << EOF >> $i
## for tkg
CONFIG_ZENIFY=y
CONFIG_USER_NS_UNPRIVILEGED=y
CONFIG_NTSYNC=y
# CONFIG_HZ_750 is not set
# CONFIG_AMD_PRIVATE_COLOR is not set
## for OpenRGB
CONFIG_I2C_NCT6775=m
## for cjktty since 6.3.5
CONFIG_FONT_CJK_16x16=y
CONFIG_FONT_CJK_32x32=y
## for cachy
CONFIG_CACHY=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE_O3 is not set
# CONFIG_HZ_600 is not set
CONFIG_MQ_IOSCHED_ADIOS=y
CONFIG_ANON_MIN_RATIO=15
CONFIG_CLEAN_LOW_RATIO=0
CONFIG_CLEAN_MIN_RATIO=15
CONFIG_VHBA=m
CONFIG_V4L2_LOOPBACK=m
CONFIG_DRM_APPLETBDRM=m
CONFIG_HID_APPLETB_BL=m
CONFIG_HID_APPLETB_KBD=m
CONFIG_APPLE_BCE=m
EOF
done

# For workaround of BUG, Disable MLX5
sed -i -e 's/^\(CONFIG_MLX5_CORE\)=m/# \1 is not set/g' \
        kernel-*.config

for i in kernel-x86_64-*.config
do
cat << EOF >> $i
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
# CONFIG_MZEN4 is not set
# CONFIG_MZEN5 is not set
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
# CONFIG_MICELAKE_CLIENT is not set
# CONFIG_MICELAKE_SERVER is not set
# CONFIG_MCASCADELAKE is not set
# CONFIG_MCOOPERLAKE is not set
# CONFIG_MTIGERLAKE is not set
# CONFIG_MSAPPHIRERAPIDS is not set
# CONFIG_MROCKETLAKE is not set
# CONFIG_MALDERLAKE is not set
# CONFIG_MNATIVE_INTEL is not set
# CONFIG_MNATIVE_AMD is not set
# CONFIG_MRAPTORLAKE is not set
# CONFIG_MMETEORLAKE is not set
# CONFIG_MEMERALDRAPIDS is not set
CONFIG_X86_64_VERSION=1
EOF

done
