#!/bin/bash
# Centos 7.9 to RHEL 7.9
# Original Script 
# Edited and Tested by: ChanifRusydi
export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1
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
        read -r -p "Run the YUM update? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                sudo yum -y update
        fi
        read -r -p "Now lets run the Convert2RHEL Installer [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sudo yum -y install convert2rhel
        fi
fi
if [ -f kupdate.txt ]; then
        echo "Welcome back lets continue preparing your system"
else
        echo "Checking your Kernel"
        echo $(uname -r)
        kernel_version=$(uname -r | awk -F'.' '{print $4}')
        if [ "$kernel_version" -eq "119" ]; then
                echo "Your Kernel is up to date"
        else
        echo "Your current kernel is not the latest version"
        read -r -p "Lets Update your Kernel and reboot? [y/N] (update to)" response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sudo yum install kernel-3.10.0-1160.119.1.el7 -y
                echo "kernel-3.10.0-1160.119.1.el7" > kupdate.txt
                echo "We Now must reboot your VM"
                sudo reboot
        fi
fi
read -r -p "Now we will run Convert2RHEL [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    sudo yum update
    sudo yum install -y dhclient dhcp-common dhcp-libs gettext gettext-libs mokutil shim-x64
    sudo yum -y install -y gce-google-rhui-client-el7-x86_64-stable.rpm -y
    sudo sed -i 's/$releasever/7Server/g' /etc/yum.repos.d/rh-cloud.repo
    sudo convert2rhel --debug --enablerepo rhui-rhel-7-server-rhui-rpms --no-rhsm -y
else
    exit 0
fi

# CentOS 7.9 to RHEL 7.9