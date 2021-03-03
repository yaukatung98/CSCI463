#!/bin/bash

# One Liner Update Script
# bash <(curl -s -L https://raw.githubusercontent.com/yaukatung98/CSCI463/master/MISP/misp-install.sh)
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# UPDATE THE SERVER

sudo apt-get update && sudo apt-get upgrade -y

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# INSTALL MISP 

wget -O /tmp/INSTALL.sh https://raw.githubusercontent.com/MISP/MISP/2.4/INSTALL/INSTALL.sh

echo -ne '                       [0%] Installing MISP and all the dependencies\r'
bash /tmp/INSTALL.sh -A
echo -ne '                       [100%] Done\r'

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-