#!/bin/bash
# Centos 7 Stream to RHEL 7
export CONVERT2RHEL_UNSUPPORTED_INCOMPLETE_ROLLBACK=1
export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1
export SKIP_OUTDATED_PACKAGE_CHECK=1
export SKIP_PACKAGE_NOT_UP_TO_DATE=1
export CONVERT2RHEL_PACKAGE_NOT_UP_TO_DATE_CHECK_SKIP=1
if [ -f kupdate.txt ]; then
    echo "Restarting"
else
        read -r -p "First we need to download some files [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release https://www.redhat.com/security/data/fd431d51.txt
                sudo curl --create-dirs -o /etc/rhsm/ca/redhat-uep.pem https://ftp.redhat.com/redhat/convert2rhel/redhat-uep.pem
                sudo curl -o /etc/yum.repos.d/convert2rhel.repo https://ftp.redhat.com/redhat/convert2rhel/7/convert2rhel.repo
                sudo curl -o ./gce-google-rhui-client-el7-x86_64-stable.rpm https://packages.cloud.google.com/yum/repos/gce-google-rhui-client-el7-x86_64-stable/Packages/819edaaa38ddbbb792684fa53b6dbbdff8a9ba22aa8e4aca96441df1130f7fb1-google-rhui-client-rhel7-8.0-1.noarch.rpm
        fi
        read -r -p "May I run the YUM update? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                sudo yum -y update
        else
        exit 0
        fi
        read -r -p "Now lets run the Convert2RHEL Installer [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sudo yum -y install convert2rhel
                sudo yum -y install dhclient dhcp-common dhcp-libs gettext gettext-libs mokutil shim-x64
#               sudo yum -y install iptables iptables-ebtables iptables-libs krb5-libs libnghttp2 python2 python2-libs python2-pip python2-pip-wheel python2-setuptools python2-setuptools-wheel python36 qemu-guest-agent
        else
        exit 0
        fi
fi
if [ -f kupdate.txt ]; then
        echo "Welcome back lets continue preparing your system"
else
        echo "Checking your Kernel"
        read -r -p "Lets Update your Kernel and reboot? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sudo yum install kernel-3.10.0-1160.102.1.el7 -y
                echo "kernel-3.10.0-1160.102.1.el7" > kupdate.txt
                echo "We Now must reboot your VM"
                # sudo reboot
                exit 0
        fi
fi
read -r -p "Now we will run Convert2RHEL [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    yum update
    sudo yum -y install -y gce-google-rhui-client-el7-x86_64-stable.rpm -y
    sudo sed -i 's/$releasever/7Server/g' /etc/yum.repos.d/rh-cloud.repo
#   sudo sed -i 's/8/8.6/g' /etc/system-release
    sudo convert2rhel --debug  --enablerepo rhui-rhel-7-server-rhui-rpms --no-rhsm -y
else
    exit 0
fi


# CentOS release 7
