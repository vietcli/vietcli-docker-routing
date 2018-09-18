#!/bin/bash
if [ ! -f /vietcli-pw.txt ]; then
    #mysql has to be started this way as it doesn't work to call from /etc/init.d
    /usr/bin/mysqld_safe &
    sleep 10s
    # Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
    ROOT_PASSWORD=`pwgen -c -n -1 12`
    VIETCLI_PASSWORD="vietcli"
    # echo "vietcli:$MAGENTO_PASSWORD" | chpasswd
    echo "root:$ROOT_PASSWORD" | chpasswd

    #This is so the passwords show up in logs.
    mkdir /home/vietcli/.log
    echo root password: $ROOT_PASSWORD
    echo vietcli password: $VIETCLI_PASSWORD
    echo $ROOT_PASSWORD > /home/vietcli/.log/root-pw.txt
    echo $VIETCLI_PASSWORD > /home/vietcli/.log/vietcli-pw.txt

    # Enable Magento 2 site
    #ln -s /etc/nginx/sites-available/magento2.conf /etc/nginx/sites-enabled/

fi

# Check HTTP_SERVER_NAME environment variable to set Virtual Host Name
#if [ -z "$HTTP_SERVER_NAME" ]; then
#    echo "HTTP_SERVER_NAME is empty"
#else
#    sed -i "s/magento2.local/${HTTP_SERVER_NAME}/" /etc/nginx/sites-available/magento2.conf
#    sed -i "s/*.magento2.local/*.${HTTP_SERVER_NAME}/" /etc/nginx/sites-available/magento2.conf
#    service nginx restart
#    service php7.0-fpm restart
#fi

# Initial Services
#service nginx restart

# run SSH
/usr/sbin/sshd -D