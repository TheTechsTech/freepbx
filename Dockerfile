FROM centos:7 
MAINTAINER Lawrence Stubbs <technoexpressnet@gmail.com>

# Install Required Dependencies
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
	&& yum update -y 

RUN yum -y install sudo icu gcc-c++ lynx tftp-server unixODBC mariadb-devel \
    mariadb-server mariadb mysql-connector-odbc httpd mod_ssl ncurses curl perl fail2ban \
    fail2ban-hostsdeny denyhosts openssh-server openssh-server-sysvinit sendmail sendmail-cf \
    sox newt libxml2 libtiff iptables-utils iptables-services initscripts mailx \
    audiofile gtk2 subversion unzip rsyslog git crontabs cronie cronie-anacron wget vim \
    uuid sqlite net-tools texinfo icu libicu-devel sysvinit-tools gnutls gnutls-devel perl-devel whois 

# Install Shorewall and the fail2ban action 
RUN yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-core-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall-init-5.1.9-0base.noarch.rpm -y \
    && yum install http://www.shorewall.net/pub/shorewall/5.1/shorewall-5.1.9/shorewall6-5.1.9-0base.noarch.rpm -y \
    && yum install fail2ban-shorewall -y
 
# Install php 5.6 repositories and php5.6w	
RUN yum -y install php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear php56w-process \
        php56w-xml php56w-gd php56w-opcache php56w-ldap php56w-intl php56w-soap php56w-zip 
 
# Install nodejs	
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash - && sudo yum install -y nodejs
 
# Asterisk and FreePBX Repositorie
RUN echo " " > /etc/yum.repos.d/FreePBX.repo && sed -i '1 i\#Core PBX Packages\n[pbx]\nname=pbx\n#mirrorlist=http://mirrorlist.freepbxdistro.org/?pbxver=10.13.66&release=14.4&arch=$basearch&repo=pbx\nbaseurl=http://yum.freepbxdistro.org/pbx/10.13.66/$basearch/\ngpgcheck=0\nenabled=1' /etc/yum.repos.d/FreePBX.repo 

# Install lame jansson iksemel and pjproject 
RUN rpm -Uvh https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
RUN yum --enablerepo=forensics install lame jansson pjproject -y
RUN yum install http://cbs.centos.org/kojifiles/packages/iksemel/1.4/6.el7/x86_64/iksemel-1.4-6.el7.x86_64.rpm -y

# Install Asterisk, Add Asterisk user, Download extra sounds
RUN yum install ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/7.1/x86_64/os/Packages/libical-0.48-6.el7.x86_64.rpm -y 

RUN adduser asterisk -m -c "Asterisk User" \
    && yum install asterisk14 asterisk14-flite asterisk14-doc asterisk14-voicemail \
        asterisk14-configs asterisk14-odbc asterisk14-resample -y \
    && yum install asterisk-sounds-core-* asterisk-sounds-extra-* asterisk-sounds-moh-* -y

RUN rpm -Uvh http://repo.iotti.biz/CentOS/7/noarch/lux-release-7-1.noarch.rpm \
    && rpm -Uvh http://repo.iotti.biz/CentOS/7/noarch/lux-release-rf-7-1.noarch.rpm \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-LUX \
    && yum update -y --skip-broken
    
# Copy configs and set Asterisk ownership permissions
RUN chown asterisk. /var/run/asterisk \
	&& chown -R asterisk. /var/lib/asterisk \
	&& chown -R asterisk. /var/log/asterisk \
	&& chown -R asterisk. /var/spool/asterisk \
	&& chown -R asterisk. /usr/lib64/asterisk \
	&& chown -R asterisk. /var/www/     
COPY etc /etc/
RUN chown -R asterisk. /etc/asterisk \	
	&& chmod 775 /etc/asterisk/cdr_adaptive_odbc.conf  

# Fixes issue with running systemD inside docker builds 
# From https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /usr/bin/systemctl.py
RUN cp -f /usr/bin/systemctl /usr/bin/systemctl.original \
    && chmod +x /usr/bin/systemctl.py \
    && cp -f /usr/bin/systemctl.py /usr/bin/systemctl

# Install FreePBX 
RUN sed -i 's@ulimit @#ulimit @' /usr/sbin/safe_asterisk \
    && systemctl start mariadb \
	&& systemctl start httpd \
    && systemctl start asterisk \
    && systemctl stop asterisk \
	&& mkdir -p /var/www/html/admin/modules/pm2/node/logs \
    && mkdir -p /var/www/html/admin/modules/ucp/node/logs \
    && chmod -R 775 /var/www/html/admin/modules/pm2/node \
    && chmod -R 775 /var/www/html/admin/modules/ucp/node \
    && chown -R asterisk:asterisk /var/www/html/admin/modules/pm2 \
    && chown -R asterisk:asterisk /var/www/html/admin/modules/ucp \
    && cd /usr/src \
    && wget -q http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz \
    && tar xfz freepbx-14.0-latest.tgz \
    && rm -f freepbx-14.0-latest.tgz \
    && cd freepbx \
    && ./start_asterisk start \
    && ./install -n \
    && rm -rf /usr/src/freepbx 
    
# Install Webmin repositorie and Webmin
RUN wget http://www.webmin.com/jcameron-key.asc -q && rpm --import jcameron-key.asc \
    && yum install webmin yum-versionlock -y && yum versionlock systemd && rm jcameron-key.asc
 
RUN systemctl stop firewalld \
    && systemctl.original disable dbus firewalld \
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
    
RUN mkdir /tftpboot \
    && chmod 777 /tftpboot \
    && touch /var/log/asterisk/full /var/log/secure /var/log/maillog /var/log/httpd/access_log /etc/httpd/logs/error_log /var/log/fail2ban.log \
    && sed -i "s@#Port 22@Port 2122@" /etc/ssh/sshd_config \
    && sed -i "s#10000#9990#" /etc/webmin/miniserv.conf \
    && sed -i "s#9000,#9990,#" /etc/shorewall/rules \
    && sed -i "s#STARTUP_ENABLED=No#STARTUP_ENABLED=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#DOCKER=No#DOCKER=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#docker0#eth0#" /etc/shorewall/interfaces \
    && sed -i 's#, #\nAfter=#' /etc/systemd/system/containerstartup.service \
	&& systemctl.original disable sendmail.service \
	&& systemctl.original enable iptables.service fail2ban.service shorewall.service mariadb.service asterisk.service httpd.service freepbx.service crond.service rsyslog.service sshd-keygen.service sshd.service webmin.service containerstartup.service \
    && sed -i 's#localhost.key#localhost.key\n\tcat \"/etc/letsencrypt/archive/$HOSTNAME/privkey1.pem\" \"/etc/letsencrypt/archive/$HOSTNAME/cert1.pem\" >/etc/webmin/miniserv.pem#' /etc/containerstartup.sh \
    && chmod +x /etc/containerstartup.sh \
    && mv -f /etc/containerstartup.sh /containerstartup.sh \
    && echo "root:freepbx" | chpasswd
  
ENV container docker
ENV HTTPPORT 80
ENV SSLPORT 443 
ENV SSHPORT 2122
ENV WEBMINPORT 9990
ENV INTERFACE eth0 

EXPOSE 25 80 443 465 2122 5060/tcp 5060/udp 5061/tcp 5061/udp 8001 8003 8088 8089 9990/tcp 9990/udp 10000-10100/tcp 10000-10100/udp

ENTRYPOINT ["/usr/bin/systemctl","default","--init"]
