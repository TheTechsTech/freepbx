# FreePBX on Docker

### Image includes

 * CentOS 7 latest
 * LAMP stack (apache2, mariadb, php)
 * Shorewall Firewall
 * Webmin UI for System Administration on Port 9000, change on `docker run` by passing:
               `-e WEBMINPORT=xxxx`
 * SSH on Port 2122, can be changed or turned off on `docker run` by passing:
               `-e SSHPORT="off"` or `-e SSHPORT=xxxx`
 * Asterisk 14
 * FreePBX 14

## Running FreePBX

[DockerCloud] (https://hub.docker.com/r/technoexpress/freepbx/builds/) automatically builds the latest changes into images which can easily be pulled and ran with a simple `docker run` command. 

I found for best results and since I have more than one public IP, i'm using macvlan set up:
```
docker network create -d macvlan \
-o macvlan_mode=bridge \
--subnet=111.222.333.443/29 \
--gateway=111.222.333.444 \
-o parent=eth1 macvlan_bridge
```

For the firewall to work adding `--cap-add=NET_ADMIN` is necessary.
For best performance use `--net=host` or custom networking.
```
docker run --name freepbx \
-v freepbx-etc:/etc \
-v freepbx-www:/var/www \
-v freepbx-log:/var/log \
-v freepbx-lib:/var/lib \
-v freepbx-home:/home \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /etc/resolv.conf:/etc/resolv.conf:ro \
--cap-add=NET_ADMIN --net=macvlan_bridge \
--mac-address=00:00:00:00:00:00 --ip=111.222.333.446 --hostname=free.pbx.host \
--restart=always -itd technoexpress/freepbx:centos7
```
## Setup Tips
Using the Webmin UI visit https://ip_or_hostname:9000
* Change root passord from default 'freepbx': 
                    "System -> Change Passwords -> root" 
* Setup automatic software updating:
                    "System -> Software Package Updates -> check for update - every day, - Install any updates"
* Create SSL certificate:
                    "Webmin -> Webmin Configuration -> SSL Encryption -> Let's Encrypt -> 
                             Website root directory for validation file -> Other directory `/var/www/html`"
* Add Let's Encrypt SSL certicate to Apache default:
                    "Servers -> Apache Webserver -> select 443 virtual host -> uncheck -> SSLv2 SSLv3 TLSv1
                            -> SSL Options 
                            *Certificate/private key file    `/etc/webmin/letsencrypt-cert.pem`
                            *Private key file                `/etc/webmin/letsencrypt-key.pem`
                            *Certificate authorities file    `/etc/webmin/letsencrypt-ca.pem`"
                            
### Your now ready to config FreePBX by by visiting your https://hosts_ip or https://hostname address. 