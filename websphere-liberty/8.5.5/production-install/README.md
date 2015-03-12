Building IBM WebSphere Application Server Liberty image from Liberty Runtime Archive downloaded from Passport Advantage and IBM Java Runtime Environment
IBM WebSphere Application Server Liberty image can be built by downloading the following images from Passport Advantage / Fix Central .
•	Liberty Runtime Archive 
IBM JRE ( It is not available as part of the eAssembly, IBM JRE can be downloaded from  https://www.ibm.com/developerworks/java/jdk/linux/download.html )

Information is provided on how 
•	IBM WebSphere Application Server Liberty Docker image can be built using the supplied Dockerfile ( Modifying the binaries file names , if required)  by placing the binaries along with the Dockerfile
o	Advantages : Liberty and JRE binaries are available in the same folder as Dockerfile , they are pushed to the docker daemon directly , so no network delay
o	Disadvantages : Liberty and JRE binaries are pushed to the docker daemon, docker image size includes the size of the binaries pushed.
•	IBM WebSphere Application Server Liberty Docker image can be built using the supplied Dockerfile ( Modifying the binaries file names , if required)  by placing the binaries in a remote server and downloading them using wget during build process
o	Advantages : Liberty and JRE binaries are not pushed to the docker daemon and retrieved from remote server using wget , hence the image size doesn’t include the size of binaries used.
o	Disadvantages : Liberty and JRE binaries are retrieved from a remote server hence there might be some network delay . Remote server has to be configured as a ftp/http server.
•	IBM WebSphere Application Server Liberty Docker image can be built following the instructions provided and referring to the supplied Dockerfile  by placing the binaries along the Dockerfile
•	IBM WebSphere Application Server Liberty Docker image can be built following the instructions provided and referring to the supplied Dockerfile  by placing the binaries in a remote server and downloading them using wget during build process

•	IBM WebSphere Application Server Liberty Docker image can be built using the supplied Dockerfile (Modifying the binaries  file names, if required ) by placing the images along with the Dockerfile


1)	Download the IBM WebSphere Application Server  Liberty Runtime Archive  from Passport Advantage / Fix Central
2)	Download the supplied Dockerfile and server.xml
3)	Copy the downloaded  binaries and Dockerfile to a folder
4)	Move to the folder which contains the binaries and Dockerfile and review the Dockerfile and modify the filenames, if required
5)	Build the image using 
$docker build  -t  <image-name> .

•	IBM WebSphere Application Server Liberty Docker image can be built using the supplied Dockerfile (Modifying the binaries  file names, if required ) by placing the images in a remote server and downloading them using wget during build process


1)	Download the IBM WebSphere Application Server  Liberty Runtime Archive  from Passport Advantage / Fix Central
2)	Copy the binaries to a ftp/http server 
3)	Download the supplied Dockerfile and server.xml 
4)	Move to the folder which contains the binaries and Dockerfile and review the Dockerfile and provide the user credentials , URL of the server from where we could get the binaries
5)	Build the image using 
$docker build  -t  <image-name> .


•	IBM WebSphere Application Server Liberty Docker image can be built following the instructions provided and referring to the supplied Dockerfile  by placing the binaries along the Dockerfile

To build Docker images a Dockerfile is required. 
Follow the below instructions to create a Dockerfile which can be used to build IBM WebSphere Application Server  Liberty image

1)	Download the required binaries from the IBM WebSphere Application Server Liberty Runtime Archive eAssembly from Passport Advantage
2)	Copy the downloaded images to a folder and move to that folder 
3)	Create a new file with the name Dockerfile 
4)	Docker executes the instructions in an order . First instruction must be FROM and the base image using which the new image is built
a.	The supplied Dockerfile uses ubuntu:14.04 as the base image , you can use any base image with valid license or can build a new base image from scratch 
b.	FROM ubuntu:14.04  
i.	ubuntu is the base image and 14.04 is the associated tag
5)	Author information can be provided using MAINTAINER instruction
6)	Install the necessary software required to install the images using the RUN instructions
a.	RUN apt-get update \
          && apt-get install -y unzip
b.	Ubuntu uses apt-get to update and install software, so based on the base image the command to install the software changes, so use the appropriate commands.
7)	During build all the contents present in the folder along with the Dockerfile, unless explicitly stated in the .dockerignore file are pushed to the Docker daemon. ADD instruction can be used to add the required files to a folder
a.	ADD ibm-java*archive.bin /tmp/java.bin 
b.	ADD 855*-wlp*runtime-archive.jar /tmp/855*-wlp*runtime-archive.jar  
c.	Use ADD instruction to add the image to a folder
8)	For installing the images downloaded use the  RUN instructions to extract the zip file and use the install option provided to install that software
a.	IBM JRE is downloaded from https://www.ibm.com/developerworks/java/jdk/linux/download.html and installed  
 RUN chmod +x /tmp/java.bin \
           && /tmp/java.bin -i silent -DUSER_INSTALL_DIR=/opt/ibm/java \
           && rm /tmp/java.bin 
b.	Install Liberty by extracting the jar file 
RUN java -jar /tmp/855*-wlp*runtime-archive.jar \
         --acceptLicense /opt/ibm \
         && rm /tmp/855*-wlp*runtime-archive.jar

9)	ENV instruction can be used to set the Environment Varibles
a.	ENV PATH /opt/ibm/wlp/bin:$PATH
10)	After installing IBM WebSphere Application Server – Liberty Runtime Archive, Liberty server can be created using the RUN instruction
a.	RUN /opt/ibm/wlp/bin/server create \
     && rm -rf /opt/ibm/wlp/usr/servers/.classCache
11)	 COPY instruction can be used to copy a file to a folder
a.	COPY server.xml /opt/ibm/wlp/usr/servers/defaultServer/
12)	EXPOSE instruction can be used to inform Docker the ports, container will listen to
a.	EXPOSE 9080 9443
13)	CMD instruction can be used to provide defaults for an executing container
a.	CMD ["/opt/ibm/wlp/bin/server", "run","defaultServer"]
b.	Liberty server is run whenever the container is started
14)	When the Dockerfile is ready , build the image using 
a.	$docker build  -t  <image-name> .

•	IBM WebSphere Application Server Liberty Docker image can be built following the instructions provided and referring to the supplied Dockerfile  by placing the binaries in a remote server and downloading them using wget during build process

To build Docker images a Dockerfile is required. 
Follow the below instructions to create a Dockerfile which can be used to build IBM WebSphere Application Server  Liberty image

15)	Download the required binaries from the IBM WebSphere Application Server Liberty Runtime Archive eAssembly from Passport Advantage
16)	Copy the downloaded images to a folder and move to that folder 
17)	Create a new file with the name Dockerfile 
18)	Docker executes the instructions in an order . First instruction must be FROM and the base image using which the new image is built
a.	The supplied Dockerfile uses ubuntu:14.04 as the base image , you can use any base image with valid license or can build a new base image from scratch 
b.	FROM ubuntu:14.04  
i.	ubuntu is the base image and 14.04 is the associated tag
19)	Author information can be provided using MAINTAINER instruction
20)	Install the necessary software required to install the images using the RUN instructions
a.	RUN apt-get update \
&& apt-get install –y wget \
            && apt-get install -y unzip
b.	Ubuntu uses apt-get to update and install software, so based on the base image the command to install the software changes, so use the appropriate commands.
21)	For installing the images downloaded use the  RUN instructions to extract the zip file and use the install option provided to install that software
a.	IBM JRE is downloaded from https://www.ibm.com/developerworks/java/jdk/linux/download.html and installed  
 RUN <User Credentials>  \
     <URL>/ibm-java*archive.bin -O /tmp/java.bin \
     && chmod +x /tmp/java.bin \
     && /tmp/java.bin -i silent -DUSER_INSTALL_DIR=/opt/ibm/java \
     && rm /tmp/java.bin 
b.	Install Liberty by extracting the jar file 
RUN  <User Credentials>   \
    <URL>/855*-wlp*runtime-archive.jar  -O /tmp/855*-wlp*runtime-archive.jar \
    && java -jar /tmp/855*-wlp*runtime-archive.jar \
    --acceptLicense /opt/ibm \
    && rm /tmp/855*-wlp*runtime-archive.jar
22)	ENV instruction can be used to set the Environment Varibles
	    ENV PATH /opt/ibm/wlp/bin:$PATH
23)	After installing IBM WebSphere Application Server – Liberty Runtime Archive, Liberty server can be created using the RUN instruction
a.	RUN /opt/ibm/wlp/bin/server create \
     && rm -rf /opt/ibm/wlp/usr/servers/.classCache
24)	 COPY instruction can be used to copy a file to a folder
a.	COPY server.xml /opt/ibm/wlp/usr/servers/defaultServer/
25)	EXPOSE instruction can be used to inform Docker the ports, container will listen to
a.	EXPOSE 9080 9443
26)	CMD instruction can be used to provide defaults for an executing container
a.	CMD ["/opt/ibm/wlp/bin/server", "run","defaultServer"]
b.	Liberty server is run whenever the container is started
27)	When the Dockerfile is ready , build the image using 
a.	$docker build  -t  <image-name> .
