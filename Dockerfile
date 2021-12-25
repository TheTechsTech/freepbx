FROM centos:7.8.2003

LABEL maintainer="technoexpressnet@gmail.com"

# Install Required Dependencies
RUN yum install http://mirror.centos.org/centos/7/os/x86_64/Packages/libical-3.0.3-2.el7.x86_64.rpm -y \
    && yum install http://yum.freepbxdistro.org/pbx/10.13.66/x86_64/RPMS/digium/libresample/0.1.3/libresample-0.1.3-11_centos6.x86_64.rpm -y \
    && yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y \
    && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
    && yum -y install https://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/denyhosts-2.6-5.el7.rf.noarch.rpm \
    && yum -y --enablerepo=epel install sudo icu gcc-c++ lynx tftp-server unixODBC mariadb-devel \
    mariadb-server mariadb mysql-connector-odbc httpd mod_ssl ncurses curl perl fail2ban \
    fail2ban-hostsdeny openssh-server openssh-server-sysvinit sendmail sendmail-cf \
    sox newt libxml2 libtiff iptables-utils iptables-services initscripts postfix mailx \
    audiofile gtk2 subversion unzip rsyslog git crontabs cronie cronie-anacron wget vim \
    uuid sqlite net-tools texinfo icu libicu-devel sysvinit-tools bind bind-utils gnutls gnutls-devel perl-devel whois at \
    && yum -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/perl-URI-1.60-9.el7.noarch.rpm \
    && yum -y install perl-DBI perl-DBD-MySQL perl-Crypt-SSLeay perl-LWP-Protocol-https perl-libwww-perl

# Install Shorewall and the fail2ban action
# Install php 5.6 repositories and php5.6w
# Install nodejs
RUN yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-core-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-init-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall6-5.1.9-0base.noarch.rpm -y \
    && yum install fail2ban-shorewall -y \
    && yum -y install php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear php56w-process php56w-xml php56w-gd php56w-opcache php56w-ldap php56w-intl php56w-soap php56w-zip php56w-devel php-pecl-Fileinfo ImageMagick-devel perl-CGI php-pear-Net-Socket php-pear-Auth-SASL \
    && curl -sL https://rpm.nodesource.com/setup_11.x | bash - && yum install -y nodejs

# Asterisk and FreePBX Repositorie
# Install lame jansson iksemel and pjproject
# Copy configs and set Asterisk ownership permissions
COPY etc /etc/

RUN yum update -y \
    && yum -y install lame jansson pjproject iksemel \
    && yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm \
    && yum -y install mpg123 ffmpeg libde265 x265 libdvdcss gstreamer-plugins-bad-nonfree gstreamer1-plugins-bad-freeworld netpbm libungif ghostscript-fonts sharutils expect \
    && pear channel-update pear.php.net \
    && pear install Mail Net_SMTP Mail_mime MDB2_driver_mysql

# Install Asterisk, Add Asterisk user, Download extra sounds
RUN adduser asterisk -m -c "Asterisk User" \
    && yum install asterisk16 asterisk16-flite asterisk16-doc asterisk16-voicemail asterisk16-configs asterisk16-odbc asterisk16-resample -y \
    && yum install asterisk-sounds-core-* asterisk-sounds-extra-* asterisk-sounds-moh-* -y \
    && chown asterisk. /var/run/asterisk \
    && chown -R asterisk. /var/lib/asterisk \
    && chown -R asterisk. /var/log/asterisk \
    && chown -R asterisk. /var/spool/asterisk \
    && chown -R asterisk. /usr/lib64/asterisk \
    && chown -R asterisk. /var/www/ \
    && chown -R asterisk. /etc/asterisk \
    && chmod 775 /etc/asterisk/cdr_adaptive_odbc.conf

# Fixes issue with running systemD inside docker builds
# From https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /usr/bin/systemctl.py

RUN cp -f /usr/bin/systemctl /usr/bin/systemctl.original \
    && chmod +x /usr/bin/systemctl.py \
    && cp -f /usr/bin/systemctl.py /usr/bin/systemctl

RUN systemctl stop firewalld \
    && systemctl disable dbus firewalld \
    && (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rm -f /etc/dbus-1/system.d/*; \
    rm -f /etc/systemd/system/sockets.target.wants/*;

# Install FreePBX
RUN sed -i 's@ulimit @#ulimit @' /usr/sbin/safe_asterisk \
    && systemctl start mariadb \
    && mkdir -p /var/www/html/admin/modules/pm2/node/logs \
    && mkdir -p /var/www/html/admin/modules/ucp/node/logs \
    && chmod -R 775 /var/www/html/admin/modules/pm2/node \
    && chmod -R 775 /var/www/html/admin/modules/ucp/node \
    && chown -R asterisk:asterisk /var/www/html/admin/modules/pm2 \
    && chown -R asterisk:asterisk /var/www/html/admin/modules/ucp \
    && cd /usr/src \
    && wget -q https://mirror.freepbx.org/modules/packages/freepbx/freepbx-15.0-latest.tgz \
    && tar xfz freepbx-15.0-latest.tgz \
    && rm -f freepbx-15.0-latest.tgz \
    && cd freepbx \
    && ./start_asterisk start \
    && ./install -n \
    && rm -rf /usr/src/freepbx \
    && fwconsole ma downloadinstall ttsengines \
    && fwconsole ma downloadinstall ucp \
    && fwconsole ma downloadinstall ivr \
    && fwconsole ma downloadinstall filestore \
    && fwconsole ma downloadinstall backup \
    && fwconsole ma downloadinstall arimanager \
    && fwconsole ma downloadinstall asteriskinfo \
    && fwconsole ma downloadinstall pm2 \
    && fwconsole ma upgradeall \
    && mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('CLEARTEXT_PASSWORD')" \
    && mysql -uroot -pCLEARTEXT_PASSWORD -e "GRANT ALL PRIVILEGES ON asterisk.* TO freepbxuser@localhost;" \
    && mysql -uroot -pCLEARTEXT_PASSWORD -e "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO freepbxuser@localhost;" \
    && mysql -uroot -pCLEARTEXT_PASSWORD -e "DELETE FROM mysql.user WHERE User=''; DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DROP DATABASE IF EXISTS test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; FLUSH PRIVILEGES;"

# Install Webmin repositorie and Webmin
RUN wget http://www.webmin.com/jcameron-key.asc -q && rpm --import jcameron-key.asc \
    && yum install webmin yum-versionlock -y && yum versionlock systemd && rm jcameron-key.asc

RUN chmod 777 /tftpboot \
    && chmod 6711 /usr/bin/procmail \
    && chown root:root /usr/bin/procmail \
    && chown -R postfix:postdrop /var/spool/postfix \
    && touch /var/log/asterisk/full /var/log/secure /var/log/maillog /var/log/httpd/access_log /etc/httpd/logs/error_log /var/log/fail2ban.log /etc/postfix/dependent.db \
    && echo "" > /etc/postfix/transport \
    && echo "mailbox_command = /bin/procmail" >>  /etc/postfix/main.cf \
    && sed -i "s@#Port 22@Port 2122@" /etc/ssh/sshd_config \
    && sed -i "s#10000#9990#" /etc/webmin/miniserv.conf \
    && sed -i "s#9000,#9990,#" /etc/shorewall/rules \
    && sed -i "s#STARTUP_ENABLED=No#STARTUP_ENABLED=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#DOCKER=No#DOCKER=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#docker0#eth0#" /etc/shorewall/interfaces \
    && sed -i 's#, #\nAfter=#' /etc/systemd/system/containerstartup.service \
    && sed -i 's#/etc/pki/tls/private/localhost.key#/etc/webmin/letsencrypt-key.pem#' /etc/httpd/conf.d/ssl.conf \
    && sed -i 's#/etc/pki/tls/certs/localhost.crt#/etc/webmin/letsencrypt-cert.pem#' /etc/httpd/conf.d/ssl.conf \
    && sed -i 's#localhost.key#localhost.key\n\tcat \"/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem\" \"/etc/letsencrypt/archive/$HOSTNAME/cert1.pem\" >/etc/webmin/miniserv.pem#' /etc/containerstartup.sh \
    && systemctl.original disable sendmail.service \
    && systemctl.original enable iptables.service fail2ban.service shorewall.service mariadb.service asterisk.service httpd.service freepbx.service crond.service rsyslog.service sshd-keygen.service sshd.service postfix.service named.service webmin.service containerstartup.service \
    && chmod +x /etc/containerstartup.sh \
    && mv -f /etc/containerstartup.sh /containerstartup.sh \
    && echo "root:freepbx" | chpasswd

ENV container docker
ENV HTTPPORT 80
ENV SSLPORT 443
ENV SSHPORT 2122
ENV WEBMINPORT 9990
ENV INTERFACE eth0

EXPOSE 25 53/udp 80 443 465 953 2122 5060/tcp 5060/udp 5061/tcp 5061/udp 5062/tcp 5062/udp 5063/tcp 5063/udp 8001 8003 8088 8089 9990/tcp 9990/udp 10000-10100/tcp 10000-10100/udp

ENTRYPOINT ["/usr/bin/systemctl","default","--init"]
