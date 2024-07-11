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