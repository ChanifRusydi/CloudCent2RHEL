#!/bin/bash
# Centos 8 Stream to RHEL 8
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
                sudo yum -y install iptables iptables-ebtables iptables-libs krb5-libs libnghttp2 python2 python2-libs python2-pip python2-pip-wheel python2-setuptools python2-setuptools-wheel python36 qemu-guest-agent bash bind-export-libs ca-certificates device-mapper device-mapper-libs dmidecode gnupg2 gnupg2-smime gnutls grub2-common grub2-efi-x64 grub2-tools grub2-tools-efi grub2-tools-extra grub2-tools-minimal gzip iproute krb5-libs libcap libgcrypt libksba libnghttp2 libsemanage libssh libssh-config libtasn1 libxml2 nspr openssl openssl-libs pcre2 shim-x64 sqlite-libs vim-common vim-enhanced vim-filesystem vim-minimal xz xz-libs
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
                sudo yum install kernel-core-4.18.0-540.el8 -y
                echo "kernel-core-4.18.0-540.el8" > kupdate.txt
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
    sudo convert2rhel --enablerepo rhui-rhel-8-for-x86_64-appstream-rhui-rpms --enablerepo rhui-rhel-8-for-x86_64-baseos-rhui-rpms --no-rhsm -y
else
    exit 0
fi
