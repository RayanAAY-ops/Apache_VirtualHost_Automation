This, is a automation script to efficiently create virtualhosts for apache server:

Steps:
-make files executables : chmod u+x main.sh create_vhost.sh  
-change the MY_IP_ADDR :add your ip address
-The script requires root privileges ,run :  sudo ./main.sh <VIRTUALHOST_NAME>
-Install elinks : yum install -y elinks
-Try the validity : elinks <VIRTUALHOST_NAME>.com

-This scripts take cares of :
-package installation required to apache.
-Services enabling ,starting.
-creation of specific configuration file.
-managing  firewall.
-handling errors relating to file existence ,and configuration errors.

