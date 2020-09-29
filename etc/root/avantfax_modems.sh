#!/bin/sh
# ADD MODEMS TO AvantFax DATABASE

for i in `ls /var/spool/hylafax/etc/config.*`; do
	if [ "$i" != "/var/spool/hylafax/etc/config.sav" ]; then
		if [ "$i" != "/var/spool/hylafax/etc/config.devid" ]; then
			tilde=`echo $i | grep '~'`
			if [ "$?" -eq "1" ]; then
				if [ -f $i ]; then
					modem=`echo $i | awk -F'/' '{print $6}' | awk -F'.' '{print $2}'`
					exists=`mysql --user=root --password=CLEARTEXT_PASSWORD avantfax -sNe "select count(*) existe from Modems where device='$modem'"`
					if [ "$exists" -eq "0" ]; then
						mysql --user=root --password=CLEARTEXT_PASSWORD -e "INSERT INTO Modems SET device='$modem', alias ='$modem'" avantfax
					fi
				fi
			fi
		fi
	fi
done

if [ -f /etc/mail/trusted-users ]; then
  grep ^asterisk$ /etc/mail/trusted-users || \
     echo asterisk >> /etc/mail/trusted-users
fi
