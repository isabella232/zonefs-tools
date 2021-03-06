#!/bin/bash
#
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2019 Western Digital Corporation or its affiliates.
#

. scripts/test_lib

if [ $# == 0 ]; then
	echo "Sequential file append (async)"
        exit 0
fi

require_program fio

echo "Check sequential file append (async)"

zonefs_mkfs "$1"
zonefs_mount "$1"
fio --name=seq_wr --filename="$zonefs_mntdir"/seq/0 \
    --create_on_open=0 --allow_file_create=0 --file_append=1 --unlink=0 \
    --rw=write --ioengine=libaio --iodepth=8 --max-jobs=8 \
    --bs=131072 --size="$seq_file_0_max_size" --verify=md5 --do_verify=1 \
    --continue_on_error=none --direct=1 || \
	exit_failed " --> FAILED"

sz=$(file_size "$zonefs_mntdir"/seq/0)
[ "$sz" != "$seq_file_0_max_size" ] && \
	exit_failed " --> Invalid file size $sz B, expected $seq_file_0_max_size B"

zonefs_umount

exit 0
