FROM mdnetdesign/base

RUN yum -y install httpd mod_ssl openssl

RUN mkdir -p /etc/httpd/sites/
RUN rm -f /etc/httpd/conf.d/welcome.conf 2> /dev/null
RUN echo "IncludeOptional sites/*.conf" >> /etc/httpd/conf/httpd.conf

RUN echo "<VirtualHost *:80>" > /etc/httpd/sites/http.conf
RUN echo " ServerName localhost" >> /etc/httpd/sites/http.conf
RUN echo " ServerAlias *" >> /etc/httpd/sites/http.conf
RUN echo " DocumentRoot /var/www/html" >> /etc/httpd/sites/http.conf
RUN echo " <Directory /var/www/html>" >> /etc/httpd/sites/http.conf
RUN echo "  AllowOverride All" >> /etc/httpd/sites/http.conf
RUN echo " </Directory>" >> /etc/httpd/sites/http.conf
RUN echo "</VirtualHost>" >> /etc/httpd/sites/http.conf
RUN chmod 444 /etc/httpd/sites/http.conf

RUN echo "<VirtualHost *:443>" > /etc/httpd/sites/https.conf
RUN echo " ServerName localhost" >> /etc/httpd/sites/https.conf
RUN echo " ServerAlias *" >> /etc/httpd/sites/https.conf
RUN echo " SSLEngine on" >> /etc/httpd/sites/https.conf
RUN echo " SSLCertificateFile /var/www/cert/cert.crt" >> /etc/httpd/sites/https.conf
RUN echo " SSLCertificateKeyFile /var/www/cert/private.key" >> /etc/httpd/sites/https.conf
RUN echo " SSLCertificateChainFile /var/www/cert/chain.pem" >> /etc/httpd/sites/https.conf
RUN echo " DocumentRoot /var/www/html" >> /etc/httpd/sites/https.conf
RUN echo " <Directory /var/www/html>" >> /etc/httpd/sites/https.conf
RUN echo "  AllowOverride All" >> /etc/httpd/sites/https.conf
RUN echo " </Directory>" >> /etc/httpd/sites/https.conf
RUN echo "</VirtualHost>" >> /etc/httpd/sites/https.conf
RUN chmod 444 /etc/httpd/sites/https.conf

RUN mkdir -p /var/www/html
RUN chmod 777 /var/www/html

RUN mkdir -p /var/www/cert
RUN chmod 777 /var/www/cert

RUN echo "#!/bin/sh" > /container-init
RUN echo "if [ ! -f /var/www/cert/private.key ]; then" >> /container-init
RUN echo " echo No certificate found, generating one - this may take a while..." >> /container-init
RUN echo " openssl genrsa -out /var/www/cert/private.key 2048" >> /container-init
RUN echo " openssl req -new -subj \"/C=DE/ST=SN/L=Dresden/CN=*\" -key /var/www/cert/private.key -out /var/www/cert/request.csr" >> /container-init
RUN echo " openssl x509 -req -days 365 -in /var/www/cert/request.csr -signkey /var/www/cert/private.key -out /var/www/cert/cert.crt" >> /container-init
RUN echo " cat /var/www/cert/cert.crt > /var/www/cert/chain.pem" >> /container-init
RUN echo " chmod 444 /var/www/cert/*" >> /container-init
RUN echo " echo Certificate generated. Please mount /var/www/cert and replace with your own!" >> /container-init
RUN echo "fi" >> /container-init
RUN echo "rm -f /var/run/httpd/httpd.pid 2> /dev/null" >> /container-init
RUN echo "exec httpd -DFOREGROUND" >> /container-init
RUN chmod +x /container-init

ENV APACHE_RUN_USER="httpd" \
  APACHE_RUN_GROUP="httpd" \
  APACHE_PID_FILE="/var/run/httpd/httpd.pid" \
  APACHE_RUN_DIR="/var/run/httpd" \
  APACHE_LOCK_DIR="/var/lock/httpd" \
  APACHE_LOG_DIR="/var/log/httpd" \
  LANG="C"

EXPOSE 80
EXPOSE 443

VOLUME /var/www/html
VOLUME /var/www/cert

CMD ["/container-init"]