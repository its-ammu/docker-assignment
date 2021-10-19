#!/bin/bash

while (( $# > 0 )); do case $1 in
        --install) install="$2";;
        --start) start="$2";;
        --stop) stop="$2";;
        --stat) stat="$2";;
        --clone) clone="$2";;
        --help) echo -e "Pass the following arguments as needed : \n 1. '--install true' to install lamp\n 2. '--start true' to start servers\n 3. '--stop true' to stop servers\n 4. '--stat true' to display status and versions of servers \n 5. '--clone true' to clone a repo to the server\n 6. By default status will be displayed ";
                exit;;
        *) break;
esac; shift 2
done


if $install; then
        echo -e "\nInstalling lamp ...\n"
        echo "--------------------------";

        # If yum is found then redhat
        if VERB="$( which yum )" 2> /dev/null; then
                echo -e "\nRedhat-based\n"
                sudo yum update;
                sudo yum -y install httpd;
                sudo systemctl start httpd.service
                sudo systemctl enable --now httpd;

                sudo yum -y install mysql-server;
                chkconfig mysqld on;
                service mysqld start;

                sudo yum -y install php php-common;

                sudo systemctl restart httpd;
                echo -e "\nSystem Ready...\n";

        # If apt-get is found then debian       
        elif VERB="$( which apt-get )" 2> /dev/null; then
                echo -e "\nDebian\n"
                sudo apt-get update;
                sudo apt-get install apache2;


                sudo apt-get install mysql-server;

                sudo apt-get install php libapache2-mod-php;

                sudo systemctl restart apache2;
                echo -e "\nSystem Ready...\n";
        fi
elif $start; then

        echo -e "\nStarting the services...\n";
        echo "--------------------------";

        if VERB="$( which yum )" 2> /dev/null; then

                if VERB="$( which httpd )" 2> /dev/null; then

                        # If the service is running restart if not start the service and if not installed install then start

                        systemctl is-active --quiet httpd.service && sudo systemctl restart httpd.service || sudo systemctl start httpd.service;
                        echo -e "\nWeb server started\n";
                else
                        sudo yum update;
                        sudo yum -y install httpd;
                        sudo systemctl enable --now httpd;
                        echo -e "\nWeb server started\n";
                fi
                if VERB="$( which mysqld )" 2> /dev/null; then

                        # If the service is running restart if not start the service and if not installed install then start

                        systemctl is-active --quiet mysqld && sudo service mysqld restart || sudo service mysqld start;
                        echo -e "\nDB server started";
                else
                        sudo yum -y install mysql-server;
                        chkconfig mysqld on;
                        service mysqld start;
                        echo -e "\nDB server started";
                fi

                echo -e "\nSystem Ready...\n"
        elif VERB="$( which apt-get )" 2> /dev/null; then

                if VERB="$( which apache2 )" 2> /dev/null; then
                        systemctl is-active --quiet apache2.service && sudo systemctl restart apache2 || sudo systemctl start apache2;
                        echo -e "\nWeb server started\n";
                else
                        sudo apt-get update;
                        sudo apt-get install apache2;
                        echo -e "\nWeb server started\n";
                fi
                if VERB="$( which mysql )" 2> /dev/null; then
                        systemctl is-active --quiet mysql && sudo service mysql restart || sudo service mysql start;
                        echo -e "\nDB server started\n";
                else
                        sudo apt-get install mysql-server;
                        sudo service mysql start;
                        echo -e "\nDB server started\n";
                fi
                echo -e "\nSystem Ready...\n"
        fi

elif $stop; then
        echo -e "\nStopping the services...\n"
        echo "--------------------------";
        if VERB="$( which yum )" 2> /dev/null; then
                systemctl stop httpd.service;
                systemctl stop mysql;
                echo -e "\nAll services stopped \n";
        elif VERB="$( which apt-get )" 2> /dev/null; then
                systemctl stop apache2.service;
                systemctl stop mysql;
                echo -e "\nAll services stopped \n"
        fi

elif $stat; then
        echo -e "\nDisplaying status...\n";
        echo "--------------------------";
        echo -e "\nWeb server status\n";
        echo -e "--------------------------\n";

        if VERB="$( which yum )" 2> /dev/null; then
                httpd -v;
                service httpd status;
        elif VERB="$( which apt-get )" 2> /dev/null; then
                apache2 -v;
                service apache2 status;
        fi
        echo -e "\nMysql status \n";
        echo -e "--------------------------\n";
        mysql --version;
        service mysql status;
        echo -e "\nMysql database status\n";
        echo -e "---------------------------\n";
        sudo mysqladmin -u$MYSQL_USER -p$MYSQL_PASSWORD status;
        echo -e "\n--------------------------";
        echo -e "\nGo to http://localhost/info.php to check on php\n"
elif $clone; then
        echo -e "\n Cloning repo to servers\n";
        echo -e "---------------------------\n";
        read -p 'Enter your repo link : ' repo;
        git clone $repo /tmp/assignment/;
        mv /tmp/assignment/* /var/www/html/;
        echo -e "\n Cloned";
fi
exit

