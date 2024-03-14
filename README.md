DRAFT 2: Converting CentOS to RHEL in GCP
Introduction
Convert2rhel is conceptually simple:  It replaces non-RHEL packages from RHEL clones (CentOS, Oracle, and soon Rocky & Alma) with signed RHEL packages. At any given moment, there is a list of supported conversions.  At the moment, the supported conversions are:

CentOS 7.9 to RHEL 7.9
CentOS 8 Stream to RHEL 8
Rocky 8 to RHEL 8


Red Hat’s convert2rhel utility enables a guided and supported conversion in three basic steps:
Configures access to authentic RHEL content in your instance.
Performs various safety checks and reviews informational and remediation guidance on how to proceed.
Performs the conversion by replacing every operating system package with the RHEL equivalent. There is no application or data to migrate—Rocky/CentOS Linux bits are simply replaced by the RHEL equivalents. This is somewhat equivalent to a minor release update in which most or all of the packages are updated, and takes the same amount of time.
For a demonstration of how RHEL’s convert2rhel tool makes this an easy process, watch the following video or try our self-paced labs tutorial to become familiar with the process.
This document explains how the convert2rhel tool simplifies two commonly requested paths for converting CentOS Linux instances running on public cloud to fully supported RHEL, including: 
Converting a CentOS Linux instance in-place to RHEL with Pay As You Go (PAYG) using the BYOS model
Converting a CentOS Linux instance in-place to RHEL with Bring Your Own Subscription (BYOS)
What is a supported conversion?
When a conversion is supported, it means that Red Hat will provide support during the actual conversion process.

Note that Red Hat recently announced an extension to RHEL 7.9 ELS.  This will give CentOS 7 users plenty of time to get to a new release once they have converted a system to RHEL: https://www.redhat.com/en/blog/announcing-4-years-extended-life-cycle-support-els-red-hat-enterprise-linux-7 
What is an unsupported conversion?
Convert2rhel can replace packages on RHEL versions that are not on the list of supported options.  If you choose to convert from an unsupported version, Red Hat will NOT provide support for the conversion itself, but WILL support the resulting RHEL installation if the conversion works.  You can find details around unsupported versions here:
https://access.redhat.com/articles/2360841 

For your reference, here is a list of currently supported RHEL versions.  We don’t support converting to all of them, but this list does provide information on what RHEL releases customers should be trying to land on: https://access.redhat.com/support/policy/updates/errata 

Convert2RHEL in GCP - Pay As You Go (PAYG)
Because of the way convert2rhel works, you can attempt to convert a VM from CentOS to RHEL in pretty much any location. GCP (and in fact most cloud services) utilize custom integrations with the cloud to allow for a seamless fully managed VM environment, these integration usually require some customization to fully convert the VM. GCP uses a RHUI client to provide PAYG capabilities.


GCP using RHUI
RHEL instance with RHUI:
Download the script that would apply to your instance. 
GCP CentOS 7.9 - run the below command
sudo su
bash <(curl -s https://raw.githubusercontent.com/MCurtisRedhat/CloudCent2RHEL/main/CentOS7toRhel7.sh)

In some cases if this fails you many need to run

yum install -y dhclient dhcp-common dhcp-libs gettext gettext-libs mokutil shim-x64

sudo convert2rhel --debug  --enablerepo rhui-rhel-7-server-rhui-rpms --no-rhsm -y

and restart 

sudo su
bash <(curl -s https://raw.githubusercontent.com/MCurtisRedhat/CloudCent2RHEL/main/CentOS2RHEL8.sh)
GCP Rocky 8 raw.githubusercontent.com/MCurtisRedhat/CloudCent2RHEL/main/Rocky82RHEL8.sh
Change the file attributes of the script to make the script executable (chmod +x <script name>) and execute the script
Run the script and follow the prompts 
Note: The script will put information into a text file that will be used to understand the state of the installation after reboot (something that will have to be done in most cases) 

The script performs the following functions: 
Downloads needed files (Keys used by Convert2RHEL and the Convert2RHEL repo)
Updates the repo using YUM
Installs Convert2RHEL
Updates the Kernel and the GRUB configuration
After a reboot it installs the RHUI client 
Corrects the RHUI repo with the GCP specific locations
Corrects the /etc/system_release (for CentOS)
Runs the Convert2RHEL executable 
Currently there is no Automated method to update the license, the method is as follows:
On a NON-GCP console you will need:


Install the GCP Gcloud CLI - Install the gcloud CLI  |  Google Cloud CLI Documentation
Install the  Beta component - gcloud components beta
Initialize the GCP project that the VM is in - Initializing the gcloud CLI  |  Google Cloud CLI Documentation
Turn down the VM - gcloud compute instances stop <VM_Name>
Enter this in the CLI - gcloud beta compute disks update <your vm bootdisk name> \   --update-user-licenses= https://www.googleapis.com/compute/v1/projects/rhel-cloud/global/licenses/rhel-8-server
Turn the Server back on - gcloud compute instances start <VM_Name>



Convert2RHEL in GCP - Bring Your Own Subscription (BYOS)
The first thing to consider is how you intend to pay for your RHEL subscription.  You have a few different options. Here’s the user doc: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/converting_from_an_rpm-based_linux_distribution_to_rhel/index 
Bring Your Own Subscription (BYOS)
The first option is an annual subscription for RHEL which you obtain directly from Red Hat or a reseller. If you choose to replace your CentOS Linux with an annual subscription of RHEL, review the following options depending on how you obtain your subscription.
If you have RHEL subscriptions
Follow these steps to create an activation key and begin.
Login to the Red Hat Hybrid Cloud Console and view your subscriptions.

For the best experience, ensure that Simple Content Access (SCA) is enabled.  Otherwise, you will need to manually specify which subscription to use when you register the instance you wish to convert.
If using SCA, click on menu item All Apps & Services > Remote Host Configuration > Activation Keys.  This will allow you to create a named Activation Key, such as “my_conversions”, to provide to the convert2rhel utility in a later step.  If you choose not to use SCA and Activation keys, you will need to follow the instructions for registering with the subscription manager tool using a username and password, and attaching a specific subscription.  SCA + Activation Keys are far easier and are the recommended method.

Starting the conversion
Use the Organization ID (found on the  Activation Keys page) and the activation key that you created in the previous steps. This enables the convert2RHEL utility to register the system and perform the conversion.
Red Hat cares about your data and systems.  Red Hat strongly recommends creating backups of your volume in the event of unexpected problems.  Within GCP, you can do this by taking a snapshot of the associated Elastic BlockStorage (EBS) volume. 
Review the documentation for Converting from an RPM-based Linux distribution to RHEL.  Please review this carefully so that you understand the support matrix, preparations, and other important details.
Login to the instance using SSH or the Alicloud terminal to access a shell prompt.  This will allow you to execute the following commands.  The user account will require permissions to use the sudo command or become the root super user.
Update to the latest supported version and install errata updates. Reboot the instance to ensure the latest updates and kernel are applied.
# sudo yum -y update
Install a few prerequisites and initiate the conversion.
Copy files to validate that the content is signed by Red Hat. 
# sudo curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release https://www.redhat.com/security/data/fd431d51.txt
# sudo curl --create-dirs -o /etc/rhsm/ca/redhat-uep.pem https://ftp.redhat.com/redhat/convert2rhel/redhat-uep.pem

For CentOS 7
# sudo curl -o /etc/yum.repos.d/convert2rhel.repo https://ftp.redhat.com/redhat/convert2rhel/7/convert2rhel.repo
For CentOS 8
# sudo curl -o /etc/yum.repos.d/convert2rhel.repo https://ftp.redhat.com/redhat/convert2rhel/8/convert2rhel.repo
# sudo yum -y install convert2rhel


Create a configuration file containing the activation key and save the file in the .ini file format.  This is the recommended method for activation keys and passwords to ensure that sensitive information is not leaked.  You can delete the file when the process is complete.  In this example, the vi text editor is used but you can use your editor of choice.
# sudo vi /etc/convert2rhel.ini

[subscription_manager]
activation_key = <activation_key>
Initiate the conversion tool
# sudo convert2rhel --org <Organization_ID> --config-file <config_file_name>
After conversion, it is highly recommended to register with the insights-client to enable your additional management capabilities at the Red Hat Hybrid Cloud Console.
# sudo insights-client --register
After following any remaining guidance in the documentation, the system will be ready to be restarted as 100% authentic RHEL.  If you registered with Insights, you will now see your system in the Inventory.
Cloud-Based Auto-Registration
By enabling Auto-Registration, Simple Content Access (SCA), and Subscription Watch, you will enable fleet-level registration for Red Hat workloads running in select public cloud environments to auto-connect and gain full access to Red Hat content, analytics and tools to manage your fleet across multiple hybrid cloud environments.  No matter how you choose to pay for Red Hat subscriptions, BYOS or PAYG, you will have the best and most comprehensive experience possible.
Step 1:  Follow the simple instructions to configure the mapping of Sources between your Red Hat and Cloud Partner accounts in Cloud Based Auto-Registration.
Step 2: Enable Subscription Watch (optional but recommended).
Step 3: Follow the same instructions defined in the BYOS section above to convert in-place to RHEL.

