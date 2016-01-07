# Building a IBM WebSphere Application Server Classic Developer image from binaries

An IBM WebSphere Application Server Classic Developer image can be built by obtaining the following binaries:
* IBM Installation Manager binaries from [Developer Works](http://www.ibm.com/developerworks/downloads/ws/wasdevelopers/)
* IBM WebSphere Application Server Classic Developer binaries from [Developer Works](http://www.ibm.com/developerworks/downloads/ws/wasdevelopers/) / [Fix Central](http://www-933.ibm.com/support/fixcentral/)

IBM WebSphere Application Server Classic Developer profile image is created in two steps using the following two Dockerfiles
1. Dockerfile.prereq
2. Dockerfile.install

Dockerfile.prereq does the following 
1. Installs IBM Installation Manager.
2. Installs IBM WebSphere Application Server. 
3. Updates IBM WebSphere Application Server with the Fixpack.
4. When the container is started a tar file of the IBM WebSphere Application Server Classic Developer installation is created.

Dockerfile.prereq takes the values for the following variables during build time                                         
user[default 'was'](optional) - user used for installation                                                               
group[default 'was'](optional) - group the user belongs to                                                               
username(required) - username to download the binaries from the FTP or HTTP Server                                       
password(required) - password for the username to download the binaries           
URL(required) - URL from where the binaries are downloaded                        
                                                                                  
Dockerfile.profile does the following                                             
1. Extracts the tar file created by Dockerfile.prereq.                            
2. Copies the server startup script to the image.                      
3. When the container is started , server is started.      
                                                      
Dockerfile.profile takes the values for the following variables during build time
user[default 'was'](optional) - user used for installation         
group[default 'was'](optional) - group the user belongs to                                                                       
CELL_NAME[default 'DefaultCell01'](optional) - cell name                                                                         
NODE_NAME[default 'DefaultNode01'](optional) - node name                                                                         
PROFILE_NAME[default 'AppSrv01'](optional) - profile name                                                                        
HOST_NAME[default 'localhost'](optional) - host name    

## Building the IBM WebSphere Application Server Classic Developer image

1. Place the downloaded IBM Installation Manager and IBM WebSphere Application Server Classic binaries on the FTP or HTTP server.
2. Clone this repository.
3. Move to the directory `websphere-classic/developer/profile`.
4. Review the Dockerfile for the build time variables.
5. Build the prereq image using:

    ```bash
    docker build --build-arg user=<user> --build-arg group=<group> --build-arg username=<user-name> --build-arg password=<password> --build-arg URL=<URL> -t <prereq-image-name> -f Dockerfile.prereq .
    ```
6. Run a container using the prereq image to get the tar file to the current folder using

    ```bash
    docker run -v <path>/websphere-classic/developer/profile:/tmp -d -t <prereq-image-name>
    ```bash
7. Build the base image using       

    ```bash
    docker build --build-arg user=<user> --build-arg group=<group> -t <profile-image-name> -f Dockerfile.profile .
    ```bash


