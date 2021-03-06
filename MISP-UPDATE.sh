#!/bin/bash

# One Liner Update Script
# bash <(curl -s -L https://raw.githubusercontent.com/yaukatung98/CSCI463/master/MISP-UPDATE.sh)
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# Check if running with sudo in a bash script

if [ "$EUID" -ne 0 ]
  then echo "Please run as root (sudo -i)"
  exit
fi

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

echo -ne '                       [0%] Updating to the latest commit from the 2.4 branch\r'
sleep 2

# To update to the latest commit from the 2.4 branch simply pull the latest commit
cd /var/www/MISP
# Replace www-data with whoever is your webserver user (apache/httpd)
sudo -u www-data git pull origin 2.4
sudo -u www-data git submodule update --init --recursive

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>                       [20%] Updating the MISP code to the latest hotfix\r'
sleep 2

# 1. Update the MISP code to the latest hotfix
cd /var/www/MISP
git fetch
git checkout tags/$(git describe --tags `git rev-list --tags --max-count=1`)
# if the last shortcut doesn't work, specify the latest version manually
# example: git checkout tags/v2.4.XY
# the message regarding a "detached HEAD state" is expected behaviour
# (you only have to create a new branch, if you want to change stuff and do a pull request for example)

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>>>>>                   [40%] Updating cakePHP to the latest supported version\r'
sleep 2

# 2. Update CakePHP to the latest supported version (if for some reason it doesn't get updated automatically with git submodule)
cd /var/www/MISP
git submodule update --init --recursive

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>>>>>>>>>>>>            [60%] Updating Mitres STIX and its dependencies\r'
sleep 2

# 3. Update Mitre's STIX and its dependencies
cd /var/www/MISP/app/files/scripts/
rm -rf python-cybox
rm -rf python-stix
sudo -u www-data git clone https://github.com/CybOXProject/python-cybox.git
sudo -u www-data git clone https://github.com/STIXProject/python-stix.git
cd /var/www/MISP/app/files/scripts/python-cybox 
python3 setup.py install 
cd /var/www/MISP/app/files/scripts/python-stix 
python3 setup.py install

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>   [80%] Updating mixbox to accommodate the new STIX dependencies\r'
sleep 2

# 4. Update mixbox to accommodate the new STIX dependencies:

cd /var/www/MISP/app/files/scripts/
rm -rf mixbox
sudo -u www-data git clone https://github.com/CybOXProject/mixbox.git
cd /var/www/MISP/app/files/scripts/mixbox
python3 setup.py install

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>   [90%] Installing PyMISP\r'
sleep 2

# 5. install PyMISP

cd /var/www/MISP/PyMISP
python3 setup.py install

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# 6. For RHEL/CentOS: enable python3 for php-fpm

#echo 'source scl_source enable rh-python36' >> /etc/opt/rh/rh-php71/sysconfig/php-fpm
#sed -i.org -e 's/^;\(clear_env = no\)/\1/' /etc/opt/rh/rh-php71/php-fpm.d/www.conf
#systemctl restart rh-php71-php-fpm.service

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# 7. Update CakeResque and its dependencies

cd /var/www/MISP/app

# Edit composer.json so that cake-resque is allowed to be updated
# "kamisama/cake-resque": ">=4.1.2"

sed -i "s/"4.1.2"/">=4.1.2"/gi" composer.json

#DISABLED FOR SECURITY PURPOSE, PLEASE CHECK https://getcomposer.org/root FOR MORE DETAILS
#*******************************************************************************
#php composer.phar self-update
# if behind a proxy use HTTP_PROXY="http://yourproxy:port" php composer.phar self-update
#php composer.phar update

# To use the scheduler worker for scheduled tasks, do the following:
#cp -fa /var/www/MISP/INSTALL/setup/config.php /var/www/MISP/app/Plugin/CakeResque/Config/config.php
#*******************************************************************************

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>   [95%] Making sure all file permissions are set correctly\r'
sleep 2

# 8. Make sure all file permissions are set correctly

find /var/www/MISP -type d -exec chmod g=rx {} \;
chmod -R g+r,o= /var/www/MISP/
chown -R www-data:www-data /var/www/MISP/

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[99%] Restarting the CakeResque workers\r'
sleep 2

# 9. Restart the CakeResque workers

su - www-data -s /bin/bash -c 'bash /var/www/MISP/app/Console/worker/start.sh'

echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[100%] DONE!\r'
# EOF