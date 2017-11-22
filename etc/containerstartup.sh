#!/bin/bash
export SSHPORT
export WEBMINPORT
export INTERFACE

source /etc/container.ini
if [[ $SSHPORT =~ ^[0-9]+$ ]] && [ "$SSH" != "$SSHPORT" ]
then 
    service sshd stop
    sed -i "s#Port $SSH#Port $SSHPORT#" /etc/ssh/sshd_config
    sed -i "s#$SSH#$SSHPORT#" /etc/container.ini
    service sshd start
elif [ "$SSHPORT" == "off" ]
then
    systemctl disable sshd.service
    service sshd stop  
elif [[ $SSHPORT =~ ^[0-9]+$ ]] && ! pgrep -x "sshd" > /dev/null
then   
    systemctl enable sshd.service
    service sshd start
fi

source <( grep port /etc/webmin/miniserv.conf ) 
if [[ $WEBMINPORT =~ ^[0-9]+$ ]] && [ "$WEBMINPORT" != "$port" ]
then  
    systemctl stop webmin
    sed -i "s#$port#$WEBMINPORT#" /etc/webmin/miniserv.conf
    systemctl start webmin
fi

if [ "$INTERFACE" != "$SHOREWALL" ]
then    
    systemctl stop shorewall 
    sed -i "s#$SHOREWALL#$INTERFACE#" /etc/shorewall/interfaces
    sed -i "s#$SHOREWALL#$INTERFACE#" /etc/container.ini
    systemctl start shorewall
fi
