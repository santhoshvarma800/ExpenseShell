#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

echo " please enter your DB password "

read -s mysql_root_password

if [ $USERID -ne 0 ]
  then
       echo " please execute with root user access "
       exit 1
   else
       echo  -e "$G you are a super user $N"
fi

VALIDATE() {

  if [ $? -ne 0 ]
    then
       echo  -e " $1 is $R FAILURE $N"
       exit 1
     else
        echo  -e " $1 is $G SUCCESS $N"
  fi
}

dnf install mysql-server -y &>>$LOGFILE
VALIDATE "Installing MYSQL"


systemctl enable mysqld &>>$LOGFILE
VALIDATE "Enabling the server"

systemctl start mysqld &>>$LOGFILE
VALIDATE "Starting  the server"



#mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
#VALIDATE "Setting up root password"

#Below code will be useful for idempotent nature


mysql -h  172.31.26.155 -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi

