export SSHPORT
export WEBMINPORT

systemctl enable denyhosts.service shorewall.service fail2ban.service mariadb.service asterisk.service httpd.service sendmail.service freepbx.service crond.service rsyslog.service webmin.service

if [ "$SSHPORT" =~ ^[0-9]+$ ]
then 
    sed -i "s#Port 2122#Port $SSHPORT#" /etc/ssh/sshd_config
    systemctl enable sshd.service
fi

/usr/sbin/init

if ! pgrep -x "denyhosts.py" > /dev/null
then
	rm -f /var/lock/subsys/denyhosts
    systemctl start denyhosts
    systemctl start shorewall
fi

if ! pgrep -x "fail2ban-server" > /dev/null
then
    systemctl start fail2ban
fi

if ! pgrep -x "mysqld" > /dev/null
then
    systemctl start mariadb
fi

if ! pgrep -x "asterisk" > /dev/null
then
    systemctl start asterisk
fi

if ! pgrep -x "httpd" > /dev/null
then
    systemctl start httpd
fi

if ! pgrep -x "sendmail" > /dev/null
then
    service sendmail start
fi  
 
if ! pgrep -f "PM2" > /dev/null
then
    systemctl start freepbx
fi

if ! pgrep -x "crond" > /dev/null
then
    systemctl start crond
fi

if ! pgrep -x "rsyslogd" > /dev/null
then
    systemctl start rsyslog
fi

if [ "$SSHPORT" == "off" ] && [ pgrep -x "sshd" ] > /dev/null
then
    systemctl disable sshd.service
    service sshd stop
elif [ "$SSHPORT" =~ ^[0-9]+$ ] && [ ! pgrep -x "sshd" ] > /dev/null
then
    service sshd start
fi

if [ "$WEBMINPORT" =~ ^[0-9]+$ ] && [ ! pgrep -x "miniserv.pl" ] > /dev/null
then
    sed -i "s#9000#$WEBMINPORT#" /etc/webmin/miniserv.conf
    systemctl start webmin 
fi
