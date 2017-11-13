FROM centos:7
MAINTAINER Lawrence Stubbs <technoexpressnet@gmail.com>

# Install Required Dependencies    
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
	&& rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm \
    && yum update -y && yum -y install icu gcc-c++ sudo lynx tftp-server unixODBC mariadb-devel \
    mariadb-server mariadb mysql-connector-odbc httpd mod_ssl ncurses curl perl fail2ban \
    fail2ban-hostsdeny denyhosts openssh-server openssh-server-sysvinit sendmail sendmail-cf \
    sox newt libxml2 libtiff iptables-utils iptables-services initscripts mailx \
    audiofile gtk2 subversion unzip rsyslog git crontabs cronie cronie-anacron wget vim \
    uuid sqlite net-tools texinfo icu libicu-devel sysvinit-tools perl-devel whois 
    
# Install Shorewall firewall and fail2ban action 
RUN yum install -y http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-7/noarch/shorewall-core-5.1.8.0-1.el7.noarch.rpm \
    && yum install -y http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-7/noarch/shorewall-5.1.8.0-1.el7.noarch.rpm \
    && yum install -y http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-7/noarch/shorewall-init-5.1.8.0-1.el7.noarch.rpm \
    && yum install fail2ban-shorewall -y
	
# Install php 5.6 repositories and php5.6w	
RUN yum -y install php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear \
        php56w-process php56w-xml php56w-gd php56w-opcache php56w-ldap php56w-intl php56w-soap php56w-zip 
 		
# Install nodejs	
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash - && sudo yum install -y nodejs

# Asterisk and FreePBX Repositorie
RUN echo " " > /etc/yum.repos.d/FreePBX.repo && sed -i '1 i\#Core PBX Packages\n[pbx]\nname=pbx\n#mirrorlist=http://mirrorlist.freepbxdistro.org/?pbxver=10.13.66&release=14.4&arch=$basearch&repo=pbx\nbaseurl=http://yum.freepbxdistro.org/pbx/10.13.66/$basearch/\ngpgcheck=0\nenabled=1' /etc/yum.repos.d/FreePBX.repo 

# Install lame jansson iksemel and pjproject 
RUN rpm -Uvh https://forensics.cert.org/cert-forensics-tools-release-el7.rpm \
    && yum --enablerepo=forensics install lame jansson iksemel pjproject -y

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
COPY conf /etc/
RUN chown -R asterisk. /etc/asterisk \	
	&& chmod 775 /etc/asterisk/cdr_adaptive_odbc.conf  

# Fixes issue with running systemD inside docker builds 
# From https://github.com/gdraheim/docker-systemctl-replacement
COPY systemctl.py /usr/bin/systemctl
ENV container=docker

# Install FreePBX 
RUN systemctl start mariadb \
	&& systemctl start httpd \
	&& mkdir -p /var/www/html/admin/modules/pm2/node/logs \
    && mkdir -p /var/www/html/admin/modules/ucp/node/logs \
    && chmod -R 775 /var/www/html/admin/modules/pm2/node \
    && chmod -R 775 /var/www/html/admin/modules/ucp/node \
    && chown -R asterisk:asterisk /var/www/html/admin/modules/pm2 \
    && chown -R asterisk:asterisk /var/www/html/admin/modules/ucp \
    && sed -i 's@ulimit @#ulimit @' /usr/sbin/safe_asterisk \
    && cd /usr/src \
    && wget -q http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz \
    && tar xfz freepbx-14.0-latest.tgz \
    && rm -f freepbx-14.0-latest.tgz \
    && cd freepbx \
    && ./start_asterisk start \
    && ./install -n \
    && rm -rf /usr/src/freepbx 
    
# Install Webmin repositorie and Webmin
RUN echo " " > /etc/yum.repos.d/webmin.repo \
   && sed -i '1 i\[Webmin]\nname=Webmin Distribution Neutral\n#baseurl=http://download.webmin.com/download/yum\nmirrorlist=http://download.webmin.com/download/yum/mirrorlist\nenabled=1' /etc/yum.repos.d/webmin.repo \
   && wget http://www.webmin.com/jcameron-key.asc -q && rpm --import jcameron-key.asc \
   && yum install webmin -y && rm jcameron-key.asc

RUN touch /var/log/asterisk/full /var/log/secure /var/log/maillog /var/log/httpd/access_log /etc/httpd/logs/error_log /var/log/fail2ban.log \
    && sed -i "s#10000#9000#" /etc/webmin/miniserv.conf \
    && sed -i "s@#Port 22@Port 2122@" /etc/ssh/sshd_config \
    && sed -i "s#STARTUP_ENABLED=No#STARTUP_ENABLED=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#DOCKER=No#DOCKER=Yes#" /etc/shorewall/shorewall.conf \
    && sed -i "s#docker0#eth0#" /etc/shorewall/interfaces \
	&& systemctl enable iptables.service denyhosts.service shorewall.service fail2ban.service mariadb.service asterisk.service httpd.service sendmail.service freepbx.service crond.service rsyslog.service webmin.service \
    && cat /etc/startup.bashrc >> /etc/bashrc \
    && echo "root:freepbx" | chpasswd

ENV SSHPORT=2122
ENV WEBMINPORT=9000  

EXPOSE 25 80 443 465 2122 5060/tcp 5060/udp 5061/tcp 5061/udp 8001 8003 8088 8089 9000/tcp 9000/udp 10000-10100/tcp 10000-10100/udp

CMD ["/bin/bash"]