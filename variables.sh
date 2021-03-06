#!/bin/bash

### Active Directory Section ##

# Select 1 for winbind or 4 for SSSD
export ADJOIN_TYPE=1
# Select Y for VDI only or N for Shared
export ADJOIN_VDI=N
# Account needs rights to join computer accounts and change their passwords.
# Strongly suggest looking up how to do this with minimum rights
export ADJOIN_USERNAME=Joiner
export ADJOIN_PASSWORD=password

# note form of ADJOIN_OU is ParentOU/ChildOU/UnbornBabyOU etc
export ADJOIN_OU=Acworth/VDI

# REALM needs to be in CAPS
export ADJOIN_REALM=AD.GAMULL.COM
export ADJOIN_DOMAIN=$( echo "${ADJOIN_REALM,,}" )

# CAPS here also but probably doesn't matter
export ADJOIN_SHORT=AD

# Domain Controller
export ADJOIN_DC=addc01.ad.gamull.com

# If CA is different change below otherwise leave as is
export ADJOIN_CA=$( echo "${ADJOIN_DC}" )

## XenDesktop Section ##

# Should be self-explanatory
export XDDC_FQDN=adxd01.ad.gamull.com
export XDDC_PORT=80
# Site name is the LDAP site (you can leave this as nothing (not the word but literally nothing))
export XDDC_SITENAME=ad.gamull.com
# Same as above
export XDDC_SEARCHBASE=DC=ad,DC=gamull,DC=com

## PVS Section ##

#IP of PVS Server
export PVS_IP=10.1.102.26
export PVS_USERNAME=svcPVS
export PVS_PASSWORD=password
export PVS_PORT=54321
export PVS_STORE=Store
# Make Collection one word since pvs-imager has issues with spaces
export PVS_COLLECTION=LinuxApps
export PVS_DEVICENAME=adrhelapp0
export PVS_VDISKNAME=adrhelapp

## Disk Device Section ##

# The TGT is the disk you want for the cache (I made mine 10GB)
export TGTDEV=/dev/vdb
# The DISK is the main disk (make sure this disk exists - run lsblk to check or df -h) (you should have /dev/vda1 /dev/vda2 - /dev/vda is the right answer)
export DISKDEV=/dev/vda
