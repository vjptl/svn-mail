#!/bin/bash

################################################################################################
# PATH2SVN_SERVER : location of the svn server
################################################################################################
PATH2SVN_SERVER=http://svn.abcdefghijk.com/svn

################################################################################################
# PROJECT_NAME  : name of the project
################################################################################################
PROJECT_NAME=project

################################################################################################
# PROJECT_PATH  : It is the location for the project's svn database
#                 By default it is calculated as PATH2SVN_SERVER/PROJECT_NAME
#                 if project path is different than this, then only one may need to modify it.
################################################################################################
PROJECT_PATH=$(echo "$PATH2SVN_SERVER/$PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

################################################################################################
# MAIL_LIST : list of recipients separated by commas
################################################################################################
MAIL_LIST=vishal@patel.com



################################################################################################
# sender's information
################################################################################################
SENDER_NAME=Vishal
SENDER_EMAIL=vishal@patel.com

