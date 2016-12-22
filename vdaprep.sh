#!/bin/bash
. ./variables.sh

echo "export JAVA_HOME=/etc/alternatives/java" >> ~/.bashrc
. ~/.bashrc

echo "Installing Prerequisites...."
yum install postgresql-server postgresql-jdbc ImageMagick motif foomatic-filters tdb-tools -y
postgresql-setup initdb
systemctl start postgresql
systemctl enable postgresql

# AD Auth Prep Part 1

if [ "$ADJOIN_TYPE" == 1 ]; then
	echo "Winbind selected for AD Auth..."
	yum install -y samba-winbind samba-winbind-clients krb5-workstation authconfig oddjob-mkhomedir
	systemctl enable winbind
	authconfig --disablecache --disablesssd --disablesssdauth --enablewinbind --enablewinbindauth --disablewinbindoffline --smbsecurity=ads --smbworkgroup=${ADJOIN_SHORT} --smbrealm=${ADJOIN_REALM} --krb5realm=${ADJOIN_REALM} --krb5kdc=${ADJOIN_DC} --winbindtemplateshell=/bin/bash --enablemkhomedir --updateall

	sed -i '/#--authconfig--end-line--/akerberos method = secrets and keytab\nwinbind refresh tickets = true' /etc/samba/smb.conf
	echo "Joining Domain..."
	net ads join ${ADJOIN_RELAM} -U ${ADJOIN_USERNAME}%${ADJOIN_PASSWORD} createcomputer=${ADJOIN_OU}

	echo "Fixing windbind pam module..."
	echo "krb5_auth = yes" >> /etc/security/pam_winbind.conf
	echo "krb5_ccache_type = FILE" >> /etc/security/pam_winbind.conf
	echo "mkhomedir = yes" >> /etc/security/pam_winbind.conf
	systemctl restart winbind
	sed -i 's/default_ccache_name = KEYRING:persistent:%{uid}/default_ccache_name = FILE:\/tmp\/krb5cc_%{uid}/g' /etc/krb5.conf

	echo "Checking join...."
	net ads testjoin
	net ads info

	if [ ! -f /etc/krb5.keytab ]; then
		echo "Something went wrong and the krb5.keytab wasn't generated"
		echo "You need to leave the domain and figure out what went wrong"
	fi



elif [ "$ADJOIN_TYPE" == 4 ]; then
	echo "SSSD selected for AD Auth..."
	authconfig --smbsecurity=ads --smbworkgroup=${ADJOIN_SHORT} --smbrealm=${ADJOIN_REALM} --krb5realm=${ADJOIN_REALM} --krb5kdc=${ADJOIN_DC} --update
	sed -i '/#--authconfig--end-line--/akerberos method = secrets and keytab' /etc/samba/smb.conf

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

else
	echo "Oh Noes! ADJOINTYPE isn't set correctly..."
	echo "You need to fix this and rerun the script"
fi

