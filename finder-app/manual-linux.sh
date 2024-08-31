#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
   #Clean
   echo "**************************** Clean **********************"
   make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper

    #config setup
    echo "**************************** Config **********************"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig

    #Build kernel image
    echo "**************************** Build Kernel Image **********************"
    make -j64 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

    #Build Modules
    echo "**************************** Build Modules **********************"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

    #Build DeviceTree
    echo "**************************** Build Device Tree **********************"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs


fi

echo "Adding the Image in outdir"
    # copy kernel image
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "**************************** Creating rootfs dirs **********************"
mkdir ${OUTDIR}/rootfs && cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://git.busybox.net/busybox 
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "**************************** Configure busybox **********************"
    make distclean
    make CROSS_COMPILE="$CROSS_COMPILE" defconfig
else
    cd busybox
fi

# TODO: Make and install busybox
echo "**************************** Build busybox **********************"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd ${OUTDIR}/rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)


cp -L ${SYSROOT}/lib/ld-linux-aarch64.* lib
cp -L ${SYSROOT}/lib64/libm.so.* lib64
cp -L ${SYSROOT}/lib64/libresolv.so.* lib64
cp -L ${SYSROOT}/lib64/libc.so.* lib64

# TODO: Make device nodes
echo "*********************** Creating Device Nodes **************"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1
# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
#clean
#make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
TARGET=${OUTDIR}/rootfs/home

cp ${FINDER_APP_DIR}/autorun-qemu.sh ${TARGET}
cp ${FINDER_APP_DIR}/finder.sh ${TARGET}
cp ${FINDER_APP_DIR}/finder-test.sh ${TARGET}
cp ${FINDER_APP_DIR}/dependencies.sh ${TARGET}

cp ${FINDER_APP_DIR}/writer ${TARGET}
cp -r ${FINDER_APP_DIR}/conf/ ${TARGET}
# TODO: Chown the root directory
sudo chown -R root:root ${OUTDIR}/rootfs

# TODO: Create initramfs.cpio.gz
echo "**************************** Create initramfs.cpio.gz **********************"
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio

cd ${OUTDIR}
rm -f initramfs.cpio.gz
gzip -f initramfs.cpio