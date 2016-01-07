#! /bin/bash

/opt/IBM/HTTPServer/bin/apachectl start

/opt/IBM/HTTPServer/bin/adminctl start

while [ `ps -eaf | grep httpd | wc -l` > 4 ]
do
   sleep 5
done
