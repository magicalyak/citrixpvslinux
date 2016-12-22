#!/bin/bash
. ./variables.sh

# removing subscription-manager and cleaning yum
echo "Cleaning up yum and stuff...."
yum clean all
subscription-manager unregister
subscription-manager remove --all

# set vdaoneshot to run on boot
if [ "$ADJOIN_TYPE" == 4 ]; then
	systemctl enable ctxvdaoneshot
elif [ "$ADJOIN_TYPE" == 1 ]; then
	systemctl enable ctxhdx ctxvda
	echo "Configuring Citrix VDA Agent...."
	export CTX_XDL_SUPPORT_DDC_AS_CNAME=Y
	export CTX_XDL_DDC_LIST=${XDDC_FQDN}
	export CTX_XDL_VDA_PORT=${XDDC_PORT}
	export CTX_XDL_REGISTER_SERVICE=Y
	export CTX_XDL_ADD_FIREWALL_RULES=Y
	export CTX_XDL_AD_INTEGRATION=${ADJOIN_TYPE}
	export CTX_XDL_HDX_3D_PRO=N
	export CTX_XDL_VDI_MODE=${ADJOIN_VDI}
	export CTX_XDL_SITE_NAME=${XDDC_SITENAME}
	export CTX_XDL_LDAP_LIST=${ADJOIN_DC}:389
	export CTX_XDL_SEARCH_BASE=${XDDC_SEARCHBASE}
	export CTX_XDL_START_SERVICE=Y
	sudo -E /opt/Citrix/VDA/sbin/ctxsetup.sh
fi

# create the disk
echo "Creating PVS image...."
pvs-imager -C -a ${PVS_IP} -u ${PVS_USERNAME} -p ${PVS_PASSWORD} -d ${ADJOIN_SHORT} -P ${PVS_PORT} -S "${PVS_STORE}" -c "${PVS_COLLECTION}" -n ${PVS_DEVICENAME} -v ${PVS_VDISKNAME} -D ${DISKDEV}

if [ "$ADJOIN_TYPE" == 4 ]; then
	echo "If something went wrong please run: systemctl disable ctxvdaoneshot"
	echo "before rebooting...."
fi
echo "If you succeeded, please clone this image and remove the OS disk"
echo "Then create a template, create the VMs and add them to the collection in PVS"
if [ "$ADJOIN_TYPE" == 4 ]; then
        echo "In XenDesktop make sure you select Desktop and VDI mode"
elif [ "$ADJOIN_TYPE" == 1 ]; then
	echo "In XenDesktop make sure you select Server and PVS mode"
fi
echo "DO NOT FORGOT to set the boot order to use the NIC first"
echo "You also should have options 66/67 set in DHCP (they are the same old options from years ago)"
