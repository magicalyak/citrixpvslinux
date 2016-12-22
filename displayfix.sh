#!/bin/bash
sed -e '$aX-GNOME-Autostart-enabled=false' -e '/X-GNOME-Autostart-enabled/d' -i.bak /etc/xdg/autostart/gnome-software-service.desktop

sed -i 's/Exec=\/usr\/bin\/vmware-user-suid-wrapper/#Exec=\/usr\/bin\/vmware-user-suid-wrapper/g' /etc/xdg/autostart/vmware-user.desktop

cat >/etc/polkit-1/rules.d/02-allow-colord.rules <<EOL
polkit.addRule(function(action, subject) {
   if ((action.id == "org.freedesktop.color-manager.create-device" ||
        action.id == "org.freedesktop.color-manager.create-profile" ||
        action.id == "org.freedesktop.color-manager.delete-device" ||
        action.id == "org.freedesktop.color-manager.delete-profile" ||
        action.id == "org.freedesktop.color-manager.modify-device" ||
        action.id == "org.freedesktop.color-manager.modify-profile") &&
       subject.isInGroup("domain users")) {
      return polkit.Result.YES;
   }
});
EOL
