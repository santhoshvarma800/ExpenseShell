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


dnf install nginx -y &>>$LOGFILE
VALIDATE "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE " Removing Existing content "

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE "Downloading the front end code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE "Extracting front end code"

cp /home/ec2-user/ExpenseShell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE "Creating Reverse Proxy"

systemctl restart nginx &>>$LOGFILE
VALIDATE "Restarting Nginx"
