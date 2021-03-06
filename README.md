# citrixpvslinux
Citrix PVS scripts for Linux Targets

Please refer to the blog article on https://magicalyak.org/2016/12/22/using-citrix-pvs-to-stream-linux-vda-rhel-7-workstation/
for instructions on using this repository

# Variables
Edit the file to your settings and source it

```
vim variables.sh
chmod 600
. ./variables.sh
```

# Installation
git clone into your /root directory and cd citrixpvslinux

Set and run the variables as described above, paying particular attention to the settings

Use the Citrix Documentation as a guide - http://docs.citrix.com/en-us/linux-virtual-delivery-agent/7-12/installation-overview/redhat.html
Install RHEL Workstation on a VM and configure hostname and tools if needed
register the subscritpion using subscription-manager and ensure the proper repos are enabled

```
subscription-manager repos --enable=rhel-7-workstation-rpms \
                           --enable=rhel-7-workstation-extras-rpms \
                           --enable=rhel-7-workstation-optional-rpms \
                           --enable=rhel-7-workstation-rh-common-rpms
yum install -y wget screen vim git bash-completion
yum update -y
systemctl reboot # kernel gets updated usually
```
(This is a good time to snapshot in case you mess up)

```
cd ~/citrixpvslinux
. ./variables.sh
./vdaprep.sh
```

copy the citrix vda rpm and install it (might as well copy the PVS Agent also (it's on the PVS 7.12 ISO))
```
yum install -y ImageMagick motif foomatic-filters
rpm -Uvh ~/XenDesktopVDA-7.14.0.400-1.el7_2.x86_64.rpm
```

fix the display issue and prep the AD Join
```
./displayfix.sh
./vdaoneshot.sh

systemctl poweroff
```

Take a snapshot and reboot at this point
You may want to add the Cache disk now, I added a 10G drive
ensure the variables.sh lists that device correctly
also make sure that your cert is from the CA listed in variables
and PVS is setup correctly
```
cd ~/citrixpvslinux
. ./variables.sh
```
Install the PVS Agent

```
yum install -y tdb-tools
rpm -Uvh ~/pvs_RED_HAT_7.14.0_16123_x86_64.rpm
./pvsprep.sh
./pvsimage.sh
```
Once the image is done you can clone the VM and remove the OS drive
add the new VMs to PVS by MAC address and set to boot from PXE

# Troubleshooting
Try the following for AD issues (for SSSD):
```
rm -f /etc/krb5.keytab
net ads leave $REALM -U $domain-administrator
```
* Delete the machine catalog and delivery group on the DDC
* Execute /opt/Citrix/VDA/sbin/ctxinstall.sh
* Create the machine catalog and delivery group on the DDC

# Citrix Info
So PVS may handle winbind without the script if this is true
set the variable $ADJOIN_TYPE to 1 and the scripts should work
you do NOT need the ctxvdaoneshot service for winbind
I did have issues with domain join so you can run winbind and
add the ctxvdaoneshot.sh script to check or join on first launch
just enable ctxvdaoneshot service before sealing the image
