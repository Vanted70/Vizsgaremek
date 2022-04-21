#!/bin/bash
apt -y update; apt -y upgrade; apt -y dist-upgrade
apt -y install curl
echo "alias update='apt -y update; apt -y upgrade; apt -y dist-upgrade' ">> /root/.bashrc
echo "alias install='apt -y install' ">> /root/.bashrc
echo "alias reboot='systemctl reboot'" >> /root/.bashrc
echo 'eval "$(starship init bash)"' >> /root/.bashrc
curl -sS https://starship.rs/install.sh | sh
apt -y install printer-driver-all
apt -y install cups*
apt -y install bind9 bind9*
echo 'zone "ldap.lan" {type master;file "/etc/bind/db.ldap.lan";allow-transfer { 192.168.113.90; };};' >> /etc/bind/named.conf.local
sed -i '24d' ./etc/bind/named.conf.options
echo '// hide version number from clients for security reasons.'>> /etc/bind/named.conf.options
echo 'version "not currently available";'>> /etc/bind/named.conf.options
echo '// disable recursion on authoritative DNS server.'>> /etc/bind/named.conf.options
echo 'recursion no;'>> /etc/bind/named.conf.options
echo '// enable the query log'>> /etc/bind/named.conf.options
echo 'querylog yes;'>> /etc/bind/named.conf.options
echo '// disallow zone transfer'>> /etc/bind/named.conf.options
echo "allow-transfer{none;};">> /etc/bind/named.conf.options
echo "};">> /etc/bind/named.conf.options
systemctl restart bind9
systemctl start bind9
systemctl enable named
cp /etc/bind/db.empty /etc/bind/db.ldap.lan
apt -y install samba krb5-user krb5-config winbind libpam-winbind libnss-winbind samba-dsdb-modules samba-vfs-modules
systemctl stop samba-ac-dc smbd nmbd winbind
systemctl disable samba-ac-dc smbd nmbd winbind
cp /etc/samba/smb.conf /etc/samba/smb.original
rm /etc/samba/smb.conf
samba-tool domain provision --use-rfc2307 --interactive
mv /etc/krb5.conf /etc/krb.conf.initial
ln -s /var/lib/samba/private/krb5.conf /etc/
echo "dns-search LDAP.LAN" >> /etc/network/interfaces
echo "search LDAP.LAN" >> /etc/resolve.conf
systemctl unmask samba-ad-dc
systemctl start samba-ad-dc
systemctl enable samba-ad-dc
apt -y install tftpd-hpa tftp
sed -i 's/TFTP_OPTIONS="--secure"/TFTP_OPTIONS="--secure --create"/g' input.txt
chown tftp:tftp /srv/tftp
systemctl restart tftpd-hpa
systemctl start tftpd-hpa
systemctl enable tftpd-hpa
apt install -y rsyslog
systemctl status rsyslog
sed '22 i $template remote-incoming-logs,"/var/log/%HOSTNAME%/%PROGRAMNAME%.log"' /etc/rsyslog.conf
sed '23 i *.* ?remote-incoming-logs' /etc/rsyslog.conf
systemctl restart rsyslog
echo "">> /etc/rsyslog.conf
echo "#Enable sending system logs over UDP to rsyslog server">> /etc/rsyslog.conf
echo "*.* @rsyslog-ip-address:514">> /etc/rsyslog.conf
echo "">> /etc/rsyslog.conf
echo "#Enable sending system logs over TCP to rsyslog server">> /etc/rsyslog.conf
echo "*.* @@rsyslog-ip-address:514">> /etc/rsyslog.conf
echo "">> /etc/rsyslog.conf
echo "$ActionQueueFileName queue">> /etc/rsyslog.conf
echo "$ActionQueueMaxDiskSpace 1g">> /etc/rsyslog.conf
echo "$ActionQueueSaveOnShutdown on">> /etc/rsyslog.conf
echo "$ActionQueueType LinkedList">> /etc/rsyslog.conf
echo "$ActionResumeRetryCount -1">> /etc/rsyslog.conf
systemctl restart rsyslog
systemctl reboot
