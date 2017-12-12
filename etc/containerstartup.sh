#!/bin/bash
export SSHPORT
export WEBMINPORT
export INTERFACE
export HTTPPORT
export SSLPORT

if [ -f "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" ]
then
    ln -sf "/etc/letsencrypt/archive/$HOSTNAME/cert1.pem" /etc/pki/tls/certs/localhost.crt
    ln -sf "/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem" /etc/pki/tls/private/localhost.key
fi

source /etc/container.ini
if [[ $SSLPORT =~ ^[0-9]+$ ]] && [ "$SSL" != "$SSLPORT" ]
then  
    sed -i "s#Listen $SSL#Listen $SSLPORT#" /etc/httpd/conf.d/ssl.conf
    sed -i "s#_:$SSL#_:$SSLPORT#" /etc/httpd/conf.d/ssl.conf
    sed -i "s#SSL=$SSL#SSL=$SSLPORT#" /etc/container.ini
    systemctl restart httpd
fi
if [[ $HTTPPORT =~ ^[0-9]+$ ]] && [ "$HTTP" != "$HTTPPORT" ]
then  
    sed -i "s#Listen $HTTP#Listen $HTTPPORT#" /etc/httpd/conf/httpd.conf 
    sed -i "s#HTTP=$HTTP#HTTP=$HTTPPORT#" /etc/container.ini
    systemctl restart httpd
fi

if [[ $SSHPORT =~ ^[0-9]+$ ]] && [ "$SSH" != "$SSHPORT" ]
then 
    service sshd stop
    sed -i "s#Port $SSH#Port $SSHPORT#" /etc/ssh/sshd_config
    sed -i "s#$SSH#$SSHPORT#" /etc/container.ini
    service sshd start
elif [ "$SSHPORT" == "off" ]
then
    systemctl.original disable sshd-keygen.service sshd.service
    service sshd stop    
    systemctl stop sshd-keygen 
elif [[ $SSHPORT =~ ^[0-9]+$ ]] && ! pgrep -x "sshd" >/dev/null
then 
    systemctl.original enable sshd-keygen.service sshd.service
    systemctl start sshd-keygen 
    service sshd start   
fi

source <( grep listen /etc/webmin/miniserv.conf ) 
if [[ $WEBMINPORT =~ ^[0-9]+$ ]] && [ "$WEBMINPORT" != "$listen" ]
then  
    systemctl stop webmin
    sed -i "s#$listen#$WEBMINPORT#" /etc/webmin/miniserv.conf
    systemctl start webmin
elif [ "$WEBMINPORT" == "off" ]
then
    systemctl.original disable webmin.service   
    systemctl stop webmin    
elif [[ $WEBMINPORT =~ ^[0-9]+$ ]] && ! pgrep -x "miniserv.pl" > /dev/null
then   
    systemctl.original enable webmin.service 
    systemctl start webmin 
fi

if [ "$INTERFACE" != "$SHOREWALL" ]
then    
    systemctl clear shorewall 
    sed -i "s#$SHOREWALL#$INTERFACE#" /etc/shorewall/interfaces
    sed -i "s#$SHOREWALL#$INTERFACE#" /etc/container.ini
    systemctl start shorewall
fi

if ! pgrep -x "sendmail" > /dev/null
then
    service sendmail start
fi  
