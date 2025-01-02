#ARG D_BASE_IMAGE=registry.access.redhat.com/ubi7:latest
FROM almalinux/8-base:latest

ARG D_OFED_VERSION="23.10-3.2.2.0"
ARG D_OS_VERSION="8.9"
ARG D_OS="rhel${D_OS_VERSION}"
ENV D_OS=${D_OS}
ARG D_ARCH="x86_64"
ARG D_OFED_PATH="MLNX_OFED_LINUX-${D_OFED_VERSION}-${D_OS}-${D_ARCH}"
ENV D_OFED_PATH=${D_OFED_PATH}

ARG D_OFED_TARBALL_NAME="${D_OFED_PATH}.tgz"
ARG D_OFED_BASE_URL="https://content.mellanox.com/ofed/MLNX_OFED-${D_OFED_VERSION}"
ARG D_OFED_URL_PATH="${D_OFED_BASE_URL}/${D_OFED_TARBALL_NAME}"
ARG D_WITHOUT_FLAGS="--without-rshim-dkms --without-iser-dkms --without-isert-dkms --without-srp-dkms --without-kernel-mft-dkms --without-mlnx-rdma-rxe-dkms"
ENV D_WITHOUT_FLAGS=${D_WITHOUT_FLAGS}


RUN yum install dnf -y

RUN yum install -y \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-core-4.18.0-513.5.1.el8_9.x86_64.rpm \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-modules-4.18.0-513.5.1.el8_9.x86_64.rpm \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-4.18.0-513.5.1.el8_9.x86_64.rpm && \
    yum install -y \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-devel-4.18.0-513.5.1.el8_9.x86_64.rpm \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-tools-4.18.0-513.5.1.el8_9.x86_64.rpm \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-tools-libs-4.18.0-513.5.1.el8_9.x86_64.rpm \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-modules-extra-4.18.0-513.5.1.el8_9.x86_64.rpm \
    https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/kernel-headers-4.18.0-513.5.1.el8_9.x86_64.rpm && \
    yum install -y libusbx numactl-libs libnl3 gcc-gfortran fuse-libs tcsh createrepo wget pkgconf-pkg-config platform-python-devel

# Download and extract tarball
WORKDIR /root


RUN yum -y install curl && (curl  ${D_OFED_URL_PATH} | tar -xzf -)

RUN yum install -y  python2-devel python2 dnf-utils && \
    yum install -y  infiniband-diags

RUN yum -y install autoconf automake binutils ethtool gcc git hostname \
    kmod libmnl libtool lsof make pciutils perl procps python36 python36-devel rpm-build tcl tk \
    wget iproute-6.2.0-6.el8_10.x86_64



WORKDIR /
ADD ./mlnxofedinstall.sh /root/mlnxofedinstall.sh

RUN chmod +x /root/mlnxofedinstall.sh

ENTRYPOINT ["/root/mlnxofedinstall.sh"]
