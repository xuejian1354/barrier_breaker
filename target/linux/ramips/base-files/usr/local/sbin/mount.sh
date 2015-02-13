#!/bin/sh

NFS_HOST=$1
NFS_DIRS=/source
MOUNT_DIRS=/mnt/nfs-dirs

try_mkdir() {
	mkdir -p $1
	echo mkdir $1
}

try_mount() {
	mount -t nfs -o nolock $NFS_HOST:$NFS_DIRS $MOUNT_DIRS
	echo mount -t nfs -o nolock $NFS_HOST:$NFS_DIRS $MOUNT_DIRS
}

if [ -f "/mnt/nfs-dirs" ]; then
    rm -rf $MOUNT_DIRS
	try_mkdir $MOUNT_DIRS

elif [ ! -d "/mnt/nfs-dirs" ]; then
	try_mkdir $MOUNT_DIRS
fi

try_mount $1

