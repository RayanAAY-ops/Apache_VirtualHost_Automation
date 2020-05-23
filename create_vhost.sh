#!/bin/bash

function create_VHOST()
{
cat <<CONF > $1
        <VirtualHost *:80>
                ServerName ${2}.com
                DocumentRoot $3
                ErrorLog "logs/${2}_error_log"
        </VirtualHost>

        <Directory $3>
                Require all granted
                AllowOverride None
        </Directory>
CONF
}
create_VHOST $1 $2 $3
