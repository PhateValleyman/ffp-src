#!/ffp/bin/sh

set -e
SHELL="/ffp/bin/sh"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export SHELL PATH
SOURCEDIR=/mnt/HD_a2/build
mkdir -p ${SOURCEDIR}/ffp
cd ${SOURCEDIR}
cp -a /mnt/HD_a2/unfinishedbuilds/build_NSA310.tar.gz $PWD
tar xf build_NSA310.tar.gz trunk/linux-2.6.31.8
cd trunk/linux-2.6.31.8
cp -a NSA310OBM_Kernel.config .config
exit 0
make menuconfig
make prepare
make modules_prepare
make modules
make INSTALL_MOD_PATH=/mnt/HD_a2/build/ffp modules_install
cd /mnt/HD_a2/build/ffp/lib/modules/2.6.31.8
rm modules.order
rm -rf build source
rm -rf kernel/fs
rm -rf kernel/drivers
rm kernel/net/802/p8022.ko
rm kernel/net/802/psnap.ko


kernel/net/802/stp.ko
kernel/net/llc/llc.ko
kernel/net/bridge/bridge.ko



