#!/bin/bash

. ./variables.sh
echo "Creating oneshot service...."

cat >/etc/systemd/system/ctxvdaoneshot.service <<EOL

[Unit]
Description=Citrix VDA Setup
After=default.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/ctxvdaoneshot
TimeoutSec=600

[Install]
WantedBy=default.target
EOL

systemctl daemon-reload

echo '#!/bin/bash' > /usr/local/sbin/ctxvdaoneshot
chmod 700 /usr/local/sbin/ctxvdaoneshot

if [ "$ADJOIN_TYPE" == 4 ]; then
cat >>/usr/local/sbin/ctxvdaoneshot <<EOL
echo "Checking for previous AD Join...."
if [ -f /etc/krb5.keystore ]
  then
    echo "Found existing join, removing from domain and resetting..."
    net ads leave -U ${ADJOIN_USERNAME}%${ADJOIN_PASSWORD}
    rm -rf /etc/krb5.keytab
fi
echo "Looks good, joining domain...."
net ads join ${ADJOIN_RELAM} -U ${ADJOIN_USERNAME}%${ADJOIN_PASSWORD} createcomputer=${ADJOIN_OU}
authconfig --enablesssd --enablesssdauth --enablemkhomedir --update
systemctl start sssd
systemctl enable sssd
systemctl start ctxhdx ctxvda
systemctl enable ctxhdx ctxvda
echo "Configuring Citrix VDA Agent...."
export CTX_XDL_SUPPORT_DDC_AS_CNAME=Y
export CTX_XDL_DDC_LIST=${XDDC_FQDN}
export CTX_XDL_VDA_PORT=${XDDC_PORT}
export CTX_XDL_REGISTER_SERVICE=Y
export CTX_XDL_ADD_FIREWALL_RULES=Y
export CTX_XDL_AD_INTEGRATION=4
export CTX_XDL_HDX_3D_PRO=N
export CTX_XDL_VDI_MODE=Y
export CTX_XDL_SITE_NAME=${XDDC_SITENAME}
export CTX_XDL_LDAP_LIST=${ADJOIN_DC}:389
export CTX_XDL_SEARCH_BASE=${XDDC_SEARCHBASE}
export CTX_XDL_START_SERVICE=Y
sudo -E /opt/Citrix/VDA/sbin/ctxsetup.sh
systemctl disable ctxvdaoneshot.service
EOL
elif [ "$ADJOIN_TYPE" == 1 ]; then
cat >>/usr/local/sbin/ctxvdaoneshot <<EOL
echo "Checking AD Join...."
net ads join ${ADJOIN_REALM} -U ${ADJOIN_USERNAME}%${ADJOIN_PASSWORD} createcomputer=${ADJOIN_OU}
systemctl restart winbind ctxvda ctxhdx
systemctl disable ctxvdaoneshot.service
EOL
fi
