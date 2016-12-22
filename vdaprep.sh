#!/bin/bash
. ./variables.sh

echo "export JAVA_HOME=/etc/alternatives/java" >> ~/.bashrc
. ~/.bashrc

yum install postgresql-server postgresql-jdbc -y
postgresql-setup initdb

systemctl start postgresql
systemctl enable postgresql

# AD Auth Prep Part 1

authconfig --smbsecurity=ads --smbworkgroup=${ADJOIN_SHORT} --smbrealm=${ADJOIN_REALM} --krb5realm=${ADJOIN_REALM} --krb5kdc=${ADJOIN_DC} --update
sed -i '/#--authconfig--end-line--/a kerberos method = secrets and keytab' /etc/samba/smb.conf

cat >/etc/sssd/sssd.conf <<EOL

[sssd]
domains = ${ADJOIN_DOMAIN}
config_file_version = 2
services = nss, pam

[domain/${ADJOIN_DOMAIN}]
cache_credentials = True
id_provider = ad
auth_provider = ad
access_provider = ad
ldap_id_mapping = True
ldap_schema = ad
ad_domain = ${ADJOIN_DOMAIN}
krb5_ccachedir = /tmp
krb5_ccname_template = FILE:%d/krb5cc_%U
default_shell = /bin/bash
fallback_homedir = /home/%u@%d
EOL

chown root:root /etc/sssd/sssd.conf
chmod 600 /etc/sssd/sssd.conf
restorecon -v /etc/sssd/sssd.conf

yum install -y ImageMagick motif foomatic-filters
