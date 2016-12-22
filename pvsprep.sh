#!/bin/bash
. ./variables.sh

# Set SELINUX to Permissive
echo "Setting selinux to Permissive (magicalyak is crying somewhere) ....."
setenforce Permissive
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

# Get the CA Cert from the DC and add it to the trust
echo "Adding CA Trust...."
openssl s_client -showcerts -connect ${ADJOIN_CA}:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > /etc/pki/ca-trust/source/anchors/${ADJOIN_CA}.pem
update-ca-trust extract

# Setup PVS Cache Disk
if [ -f ${TGTDEV} ]
  then
    echo "adding PVS Cache Disk using XFS..."

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $TGTDEV
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF
    mkfs.xfs -L 'PVS_Cache' ${TGTDEV}1
fi
