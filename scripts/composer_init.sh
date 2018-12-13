#!/bin/sh
/usr/bin/curl -o /tmp/composer-installer.php https://getcomposer.org/installer
/bin/chmod 755 /tmp/composer-installer.php
sudo php /tmp/composer-installer.php --install-dir=/usr/local/bin --filename=composer
rm /tmp/composer-installer.php
composer global require squizlabs/php_codesniffer