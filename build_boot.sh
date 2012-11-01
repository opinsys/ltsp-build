#!/bin/sh

set -eu

cleanup() {
  test -n "$srccopydir" && rm -rf $srccopydir
}

usage() {
  echo "Usage: $(basename $0) boot|ltsp hostname" > /dev/stderr
  exit 1
}

trap cleanup EXIT

if [ "$(id -u)" = "0" ]; then
  echo "Do not run me as root" > /dev/stderr
  exit 1
fi

{
  set +u
  hosttype=$1
  targethostname=$2
}

test -z "$hosttype" -o -z "$targethostname" && usage

srcdir=$(dirname $0)
srccopydir=$(mktemp -d /tmp/build-$hosttype-$USER-$$.XXXXXXXXXXX)
cp -a $srcdir $srccopydir

case "$hosttype" in
  boot)
    extraopts="--addpkg   bridge-utils \
	       --addpkg   btrfs-tools \
	       --addpkg   isc-dhcp-server \
	       --addpkg   kvm \
	       --addpkg   nbd-server \
	       --addpkg   nfs-kernel-server \
	       --addpkg   rsync \
	       --addpkg   syslinux \
	       --addpkg   tftpd-hpa \
	       --addpkg   tmux \
	       --addpkg   tshark \
	       --addpkg   ubuntu-standard \
	       --addpkg   vlan \
	       --arch     amd64 \
               --dest     /virtual/$targethostname \
               --exec     $srccopydir/setup/boot \
               --flavour  server \
               --hostname $targethostname \
               --suite    precise \
              "
    ;;
  ltsp)
    extraopts="--addpkg      bridge-utils \
	       --addpkg      btrfs-tools \
	       --addpkg      ltsp-client \
	       --addpkg      ltsp-server \
	       --addpkg      lvm2 \
	       --addpkg      tmux \
	       --addpkg      tshark \
	       --addpkg      ubuntu-gnome-desktop \
	       --addpkg      ubuntu-standard \
	       --addpkg      vlan \
	       --arch        i386 \
               --dest        /images/$targethostname \
               --exec        $srccopydir/setup/ltsp \
               --flavour     generic \
               --hostname    $targethostname \
	       --only-chroot \
               --suite       quantal \
               --tmp         /virtualtmp \
              "
    ;;
  *)
    usage
    ;;
esac

build_version=$targethostname-$hosttype-$(date +%Y-%m-%d-%H%M%S)
buildlogfile=$srcdir/log/$build_version.log

# workaround the bug:
# https://bugs.launchpad.net/ubuntu/+source/vm-builder/+bug/1037607
proc_bugfix="--addpkg linux-image-generic"

sudo \
  vmbuilder kvm ubuntu \
    $proc_bugfix \
    --addpkg     openssh-server \
    --user       opinsys \
    --pass       opinsys \
    --mirror     http://10.246.131.53:9999/fi.archive.ubuntu.com/ubuntu \
    --debug      \
    -v           \
    --rootsize   20480 \
    $extraopts   \
  2>&1 | tee $buildlogfile