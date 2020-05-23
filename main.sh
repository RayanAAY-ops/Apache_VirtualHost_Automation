#!/bin/bash

##Check the package availability of httpd
(systemctl is-active httpd > /dev/null 2>&1)

if [ $? -ne 0 ]; then
	echo "install the specific package..."
	(yum install -y httpd)
	echo "installation done "
	(systemctl start  httpd)
	echo "service started"
fi

#argv variables
VHOSTNAME=$1
#Variables
MY_IP_ADDR=192.168.43.28
HTTPD_CONF=/etc/httpd/conf/httpd.conf
VHOST_CONF_DIR=/etc/httpd/vhost.d
VHOST_CONF_FILE=$VHOST_CONF_DIR/$VHOSTNAME.conf
WWW_ROOT=/srv
VHOST_DIR_ROOT=${WWW_ROOT}/${VHOSTNAME}
VHOST_DOC_ROOT=${VHOST_DIR_ROOT}/www
##checking Check to see if the $VHOST_CONF_DIR  directory is nonexistent. If so, create the directory. Check the exit status of the directory creation and display the error message "ERROR: Failed creating $VHOST_CONF_DIR  if the directory creation failed
if [[ ! -d $VHOST_CONF_DIR  ]]; then
	echo "the vhost directory doesnt exist ,lets create it"
	mkdir $VHOST_CONF_DIR
	if [ $? -ne 0 ]; then
		echo "ERROR: Failed creating $VHOSTCONFDIR. " exit 1 # exit 1
	fi
fi
#in Apache ,you need to specify the name of vhost configuration directory ,
#by including thestatement in the $HTTPD_CONF

grep -q '^IncludeOptional vhost\.d/\*\.conf$' $HTTPD_CONF
if [ $? -ne 0 ]; then
        echo "IncludeOptional vhost.d/*.conf" >> $HTTPD_CONF
        echo "successfully add the include vhost configuration directory"
        if [ $? -ne 0 ]; then
                echo "ERROR: Failed adding include directive."
                exit 1
        fi
fi
##Create the vhost configuration file 
if  [[ -f $VHOST_CONF_FILE ]]; then
	echo "ERROR :the file $VHOST_CONF_FILE  already exists"
	exit 1
	

elif [[ -d $VHOST_DOC_ROOT ]];then
	echo "ERROR: $VHOST_DOC_ROOT already exists"
	exit 1
	
	   
else
mkdir -p $VHOST_DOC_ROOT
restorecon -Rv $WWW_ROOT 

##fill  the virtualhost configuration file with parameters
./create_vhost.sh $VHOST_CONF_FILE $VHOSTNAME $VHOST_DOC_ROOT
##create the index.html file
echo "I love RedHat" >> $VHOST_DOC_ROOT/index.html
fi
(systemctl is-active firewalld > /dev/null 2>&1)

if [ $? -ne 0 ]; then
        echo "install the specific package..."
        (yum install -y firewalld)
        echo "installation done "
        (systemctl start  firewalld)
        echo "service started"
fi
##Add http service to firewall ,and open specific port
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload

##We used domains instead of public ip address instead ,so let's configure
##the host configuration to let our system recognize the serverName
echo "${MY_IP_ADDR} ${VHOSTNAME}.com" >> /etc/hosts
##Check apache configuration
apachectl configtest &> /dev/null
if [ $? -eq 0 ]; then
	systemctl reload httpd &> /dev/null
else
	echo "ERROR: Config error."
	exit 1
fi

