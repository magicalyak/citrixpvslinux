#!/bin/bash
. ./variables.sh

# set vdaoneshot
systemctl enable ctxvdaoneshot

# create the disk
echo "Creating PVS image...."
pvs-imager -C -a ${PVS_IP} -u ${PVS_USERNAME} -p ${PVS_PASSWORD} -d ${ADJOIN_SHORT} -P ${PVS_PORT} -S ${PVS_STORE} -c ${PVS_COLLECTION} -n ${PVS_DEVICENAME} -v ${PVS_VDISKNAME} -D ${DISKDEV}

echo "If something went wrong please run: systemctl disable ctxvdaoneshot"
echo "before rebooting...."
echo "If you succeeded, please clone this image and remove the OS disk"
echo "Then create a template, create the VMs and add them to the collection in PVS"
echo "DO NOT FORGOT to set the boot order to use the NIC first"
echo "You also should have options 66/67 set in DHCP (they are the same old options from years ago)"
