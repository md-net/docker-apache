FROM mdnetdesign/base

RUN yum -y install httpd

RUN mkdir /etc/httpd/sites/
RUN rm -f /etc/httpd/conf.d/welcome.conf 2> /dev/null
RUN echo "IncludeOptional sites/*.conf" >> /etc/httpd/conf/httpd.conf
RUN echo "<VirtualHost *:80>" > /etc/httpd/sites/default.conf
RUN echo " ServerName localhost" >> /etc/httpd/sites/default.conf
RUN echo " ServerAlias *" >> /etc/httpd/sites/default.conf
RUN echo " DocumentRoot /var/www/html" >> /etc/httpd/sites/default.conf
RUN echo " <Directory /var/www/html>" >> /etc/httpd/sites/default.conf
RUN echo "  AllowOverride All" >> /etc/httpd/sites/default.conf
RUN echo " </Directory>" >> /etc/httpd/sites/default.conf
RUN echo "</VirtualHost>" >> /etc/httpd/sites/default.conf
RUN chmod 555 /etc/httpd/sites/default.conf

RUN chmod 777 /var/www/html

RUN echo "#!/bin/sh" > /container-init
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

VOLUME /var/www/html

CMD ["/container-init"]