
# IBM Container Registry (ICR)

WebSphere Liberty container images are available from the IBM Container Registry (ICR) at `icr.io/appcafe/websphere-liberty`. Our recommendation is to use ICR instead of Docker Hub since ICR doesn't impose rate limits on image pulls. Images can be pulled from ICR without authentication. Only images with Universal Base Image (UBI) as the Operating System are available in ICR.

The images for the latest Liberty release and the last two quarterly releases (versions ending in _.3_, _.6_, _.9_ and _.12_) are available and are refreshed regularly to include fixes for the operating system (OS) and Java.

Available image tags are listed below. The tags use the following naming convention. For more information on tags, see [Container image naming conventions](https://www.ibm.com/docs/en/was-liberty/base?topic=images-liberty-container#cntr_r_images__imagename__title__1) documentation.
```
<optional fix pack version-><liberty image type>-<java version>-<java type>-<base image type>
```

Liberty images with Java 21 are based on UBI 9 minimal and include IBM Semeru Runtimes for Java 21 JRE. This combination offers a compact and effective Java runtime that is suited for applications that need Java 21.

Liberty images with Java 8, 11 and 17 and with the `openj9` type are based on UBI 8 standard and include IBM Semeru Runtime for the respective Java version with the JDK. Images with the `ibmjava` type are based on UBI 8 standard and include IBM Java 8 JRE.

The `latest` tag simplifies pulling the full latest Open Liberty release with the latest Java JRE. It is an alias for the full-java21-openj9-ubi-minimal tag. If you do not specify a tag value, `latest` is used by default.

Append a tag to `icr.io/appcafe/websphere-liberty` to pull a specific image. For example, 
```
icr.io/appcafe/websphere-liberty:23.0.0.12-kernel-java17-openj9-ubi
```

Available images can be listed using [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started). Log in with your IBMid prior to running the following commands. Note that authentication is only required to list the images. **Images can be pulled from ICR without authentication** : 
```
ibmcloud cr region-set global 
ibmcloud cr images --restrict appcafe/websphere-liberty
```


## Latest version (24.0.0.1)

```
kernel-java21-openj9-ubi-minimal
kernel-java17-openj9-ubi
kernel-java11-openj9-ubi
kernel-java8-ibmjava-ubi
kernel-java8-openj9-ubi

full-java21-openj9-ubi-minimal
full-java17-openj9-ubi
full-java11-openj9-ubi
full-java8-openj9-ubi
full-java8-ibmjava-ubi

latest
```

## 24.0.0.1

```
24.0.0.1-kernel-java21-openj9-ubi-minimal
24.0.0.1-kernel-java17-openj9-ubi
24.0.0.1-kernel-java11-openj9-ubi
24.0.0.1-kernel-java8-ibmjava-ubi
24.0.0.1-kernel-java8-openj9-ubi

24.0.0.1-full-java21-openj9-ubi-minimal
24.0.0.1-full-java17-openj9-ubi
24.0.0.1-full-java11-openj9-ubi
24.0.0.1-full-java8-openj9-ubi
24.0.0.1-full-java8-ibmjava-ubi
```

## 23.0.0.12

```
23.0.0.12-kernel-java17-openj9-ubi
23.0.0.12-kernel-java11-openj9-ubi
23.0.0.12-kernel-java8-openj9-ubi
23.0.0.12-kernel-java8-ibmjava-ubi

23.0.0.12-full-java17-openj9-ubi
23.0.0.12-full-java11-openj9-ubi
23.0.0.12-full-java8-openj9-ubi
23.0.0.12-full-java8-ibmjava-ubi
```

## 23.0.0.9

```
23.0.0.9-kernel-java17-openj9-ubi
23.0.0.9-kernel-java11-openj9-ubi
23.0.0.9-kernel-java8-openj9-ubi
23.0.0.9-kernel-java8-ibmjava-ubi

23.0.0.9-full-java17-openj9-ubi
23.0.0.9-full-java11-openj9-ubi
23.0.0.9-full-java8-openj9-ubi
23.0.0.9-full-java8-ibmjava-ubi
```
