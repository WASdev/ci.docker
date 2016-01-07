#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to start the server                                                       #
#                                                                                   #
#                                                                                   #
#  Usage : ihsstart.sh                                                              #
#                                                                                   #
#  Author : Kavitha                                                                 #
#                                                                                   #
#####################################################################################

# Starting IBM HTTPServer
/opt/IBM/HTTPServer/bin/apachectl start

echo "IBM HTTP Server started successfully"

while [ `ps -eaf | grep httpd | wc -l` > 4 ]
do
   sleep 5
done
