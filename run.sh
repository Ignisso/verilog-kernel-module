#!/bin/bash
./qemu-system-riscv32-sykt -M sykt -nographic 			\
-bios fw_jump.elf 						\
-kernel Image 							\
-append "root=/dev/vda ro" 					\
-drive file=rootfs.ext2,format=raw,id=hd0 			\
-device virtio-blk-device,drive=hd0 				\
-netdev user,id=net0 -device virtio-net-device,netdev=net0

