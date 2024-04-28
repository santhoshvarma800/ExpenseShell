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


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE " Disabling previous Nodejs version "


dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE " Enablinf  specified  Nodejs version "


dnf install nodejs -y &>>$LOGFILE
VALIDATE " Installing Nodejs "


id expense &>>$LOGFILE

if [ $? -ne 0 ]
    then
         useradd expense
         VALIDATE " Creating User "
     else
        echo " user is already existed"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE " Creating app Directory "

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE " Downloading the backend code "

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE " Installing the dependencies "


cp /home/ec2-user/ExpenseShell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE " reloading the daemon"

systemctl start backend &>>$LOGFILE
VALIDATE " starting the backend server "

systemctl enable backend &>>$LOGFILE
VALIDATE " Enabled the backend "

dnf install mysql -y &>>$LOGFILE
VALIDATE " Installing mysql client "

mysql -h 172.31.26.155 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE " Schema loading "

systemctl restart backend &>>$LOGFILE
VALIDATE " Restartimg the server"