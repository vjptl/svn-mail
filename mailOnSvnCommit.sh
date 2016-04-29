#!/bin/bash

source config.sh
#################################################
## nothing below this line shall be edited
#################################################

PWD=$(pwd)
file_presentHead="$PWD/.presentHead_$PROJECT_NAME.txt"
certs_DIR="$PWD/.certs_svnciscirpt"
if [ $# = 1 ] ; then if [ $1 = "clear" ] ; then echo "removing all traces"; rm -rf $certs_DIR; rm -rf $file_presentHead; rm -rf ".pass.txt"; exit; fi; fi
if [ -f "$file_presentHead" ]
then
  OLD_VERSION=$(head -n 1 $file_presentHead)
else
  while ( ! ping -c1 svn.arastusafal.com &>/dev/null); do  notify-send "svn server is down";sleep 1;done 
  OLD_VERSION=$(svn info $PROJECT_PATH -r 'HEAD'| grep "Revision" | cut -c11-); echo $OLD_VERSION > $file_presentHead
fi
while ( ! $(wget -q --tries=1 --retry-connrefused --timeout=20 --spider https://mail.google.com/)); do notify-send "no internet connection";  sleep 5;done
if [ ! -d "$certs_DIR" ] ; then mkdir $certs_DIR; echo "hello123" > ".pass.txt"; certutil -N -d $certs_DIR -f ".pass.txt"; echo -n | openssl s_client -connect smtp.gmail.com:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $certs_DIR/gmail.crt; certutil -A -n "Google Internet Authority" -t "C,," -d ~/.certs -i $certs_DIR/gmail.crt; fi
clear
echo "Script needs email credentials for sending emails. Please provide email id and password"; read -p "E-mail ID: " LOGIN_MAIL; read -s -p "password: " LOGIN_PASSWORD;
echo -e "\nPresent HEAD for ${PROJECT_NAME[@]^} is: $OLD_VERSION"
(while (true)
do
  while ( ! ping -c1 svn.arastusafal.com &>/dev/null); do  notify-send "svn server is down";sleep 1000;done
  while ( ! $(wget -q --tries=1 --retry-connrefused --timeout=20 --spider https://mail.google.com/)); do notify-send "no internet connection";  sleep 5000;done
  VERSION=$(svn info $PROJECT_PATH -r 'HEAD'| grep "Revision" | cut -c11-)
  if [ $VERSION != $OLD_VERSION ]
  then
    VERSION=`expr $OLD_VERSION + 1`
    AUTHOR=$(svn info $PROJECT_PATH -r $VERSION | grep "Last Changed Author" | cut -c22-)
    DATE_TIME=$(svn info $PROJECT_PATH -r $VERSION | grep "Last Changed Date" | cut -c20-)
    MESSAGE=$(svn log $PROJECT_PATH -r $VERSION --incremental | tail -n 1)
    SUBJECT="[${PROJECT_NAME[@]^} SVN commit]#$VERSION: $MESSAGE"
    { echo -e "Revision: $VERSION \nAuthor: $AUTHOR \nDate: $DATE_TIME\n\nMessage:\n$MESSAGE\n\nFiles Changed:"; svn diff $PROJECT_PATH -c $VERSION --summarize; echo -e -n "\nChanges:";  svn diff $PROJECT_PATH -c $VERSION --no-diff-deleted | sed -e 's/$//' | sed '/^Index:/i\ \ '; } | mailx -s "$SUBJECT" -S smtp-use-starttls -S ssl-verify=ignore -S smtp-auth=login -S smtp=smtp://smtp.gmail.com:587 -S from="$SENDER_EMAIL($SENDER_NAME)" -S smtp-auth-user=$LOGIN_MAIL -S smtp-auth-password=$LOGIN_PASSWORD -S ssl-verify=ignore -S nss-config-dir=$certs_DIR $MAIL_LIST 
    notify-send "${PROJECT_NAME[@]^}: version $VERSION available" "$AUTHOR\n$MESSAGE"
    OLD_VERSION=$VERSION && echo $OLD_VERSION > $file_presentHead
  else
    sleep 500
  fi
done) &
disown -h
