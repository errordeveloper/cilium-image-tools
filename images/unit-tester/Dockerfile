FROM ubuntu:20.04 as qemu

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends \
      qemu-kvm \
    && SUDO_FORCE_REMOVE=yes apt-get remove --yes \
      dmsetup \
      sudo \
    && apt-get autoremove --yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#COPY configure.sh /tmp/configure.sh
#RUN /tmp/configure.sh


FROM ubuntu:18.04@sha256:bec5a2727be7fff3d308193cfde3491f8fba1a2ba392b7546b43a051853a341d as ubuntu-bionic-kernels

# apt list 'linux-image-4.15.*-generic' | tail -1
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
      linux-image-4.15.0-91-generic \
      linux-image-4.18.0-25-generic \
      linux-image-5.0.0-43-generic \
      linux-image-5.3.0-45-generic \
      linux-image-4.15.0-1056-kvm \
    && true

## see https://centos.pkgs.org/7/centos-updates-x86_64/ for all available versions
#FROM centos:7@sha256:4a701376d03f6b39b8c2a8f4a8e499441b0d567f9ab9d58e4991de4472fb813c as centos-7-kernels
#RUN yum install -y \
#    kernel-3.10.0-1062.18.1.el7 \
#  && true
#
## see https://centos.pkgs.org/8/centos-baseos-x86_64/ for all available versions
#FROM centos:8@sha256:fe8d824220415eed5477b63addf40fb06c3b049404242b31982106ac204f6700 as centos-8-kernels
#RUN dnf install -y \
#    kernel-4.18.0-147.5.1.el8_1.x86_64 \
#  && true

#FROM fedora:32@sha256:f0a228cac4545c031ed11da1fe5c2fd214c2c3b0b5f090c8000d9358930c7eac as fedora-32-kernels
#  RUN dnf install -y \
#      kernel-5.6.0-0.rc7.git0.2.fc32.x86_6 \ # go find it!
#    && true


FROM ubuntu:20.04 as rootfs-builder

COPY --from=qemu / /out

RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends \
      curl

RUN mkdir -p /out/vm /out/kernel/ubuntu-bionic /out/kernel/centos-7 /out/kernel/centos-8 /out/kernel/linuxkit

COPY --from=ubuntu-bionic-kernels /lib/modules /in/lib/modules
COPY --from=ubuntu-bionic-kernels /boot /out/kernel/ubuntu-bionic

#COPY --from=centos-7-kernels /lib/modules /in/lib/modules
#COPY --from=centos-7-kernels /boot /out/kernel/centos-7

#COPY --from=centos-8-kernels /lib/modules /in/lib/modules
#RUN mv /in/lib/modules/4.18.0-147.5.1.el8_1.x86_64/vmlinuz /out/kernel/centos-8/vmlinuz-4.18.0-147.5.1.el8_1.x86_64

COPY --from=linuxkit/kernel:4.19.104 /kernel /out/kernel/linuxkit/vmlinuz-4.19.104-linuxkit
COPY --from=linuxkit/kernel:4.19.104 /kernel.tar /tmp/modules.tar
RUN tar -C /in -xf /tmp/modules.tar && rm -f /tmp/modules.tar

COPY --from=linuxkit/kernel:5.4.19 /kernel /out/kernel/linuxkit/vmlinuz-5.4.19-linuxkit
COPY --from=linuxkit/kernel:5.4.19 /kernel.tar /tmp/modules.tar
RUN tar -C /in -xf /tmp/modules.tar && rm -f /tmp/modules.tar

ARG ALPINE_ISO_URL=http://dl-cdn.alpinelinux.org/alpine/v3.11/releases/x86_64/alpine-extended-3.11.6-x86_64.iso
# http://dl-cdn.alpinelinux.org/alpine/v3.11/releases/x86_64/alpine-minirootfs-3.11.6-x86_64.tar.gz
RUN curl --silent --fail --show-error --location ${ALPINE_ISO_URL} --output /out/vm/alpine.iso

FROM scratch
COPY --from=rootfs-builder /out /
CMD qemu-system-x86_64 -m 512 -nographic -serial mon:stdio -kernel /kernel/ubuntu-bionic/vmlinuz-5.3.0-45-generic -initrd /mnt/initramfs.cpio.gz -append 'console=ttyS0'
