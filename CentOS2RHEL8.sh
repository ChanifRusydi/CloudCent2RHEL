#!/bin/bash
# Centos 8 Stream to RHEL 8
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
                sudo curl -o /etc/yum.repos.d/convert2rhel.repo https://ftp.redhat.com/redhat/convert2rhel/8/convert2rhel.repo
                sudo curl -o ./google-rhui-client-rhel8-4.0-1.noarch.rpm https://packages.cloud.google.com/yum/repos/gce-google-rhui-client-el8-x86_64-stable/Packages/c1afb73c8c5443c696cff1711ebc7427cdaa009df58cb87df418cc5bb1f690e5-google-rhui-client-rhel8-4.0-1.noarch.rpm
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
                sudo yum install kernel-core-4.18.0-535.el8 -y
                echo "kernel-core-4.18.0-535.el8" > kupdate.txt
                echo "We Now must reboot your VM"
                # sudo reboot
                exit 0
        fi
fi
read -r -p "Now we will run Convert2RHEL [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    sudo yum -y install -y google-rhui-client-rhel8-4.0-1.noarch.rpm -y
    sudo sed -i 's/$releasever/8/g' /etc/yum.repos.d/rh-cloud.repo
    sudo sed -i 's/8/8.6/g' /etc/system-release
    sudo convert2rhel --debug  --enablerepo rhui-rhel-7-server-rhui-rpms --no-rhsm --no-rpm-va -y    
else
    exit 0
fi


# notes:rpm -qi centos-stream-release | grep ^Version
# CentOS Stream release 8
[micurtis@centos-stream-8-2 ~]$ 
