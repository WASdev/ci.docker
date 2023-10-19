
# IBM Container Registry (ICR)

WebSphere Liberty container images are available from the IBM Container Registry (ICR) at `icr.io/appcafe/websphere-liberty`. Our recommendation is to use ICR instead of Docker Hub since ICR doesn't impose rate limits on image pulls. Images can be pulled from ICR without authentication. Only images with Universal Base Image (UBI) as the Operating System are available in ICR.

The images for the latest Liberty release and the last two quarterly releases (versions ending in _.3_, _.6_, _.9_ and _.12_) are available and are refreshed regularly to include fixes for the operating system (OS) and Java.

Available image tags are listed below. The tags follow this naming convention: 
```
<fixpack_version_optional>-<liberty_image_flavour>-<java_version>-<java_type>-ubi
```

Append a tag to `icr.io/appcafe/websphere-liberty` to pull a specific image. For example, 
```
icr.io/appcafe/websphere-liberty:23.0.0.9-kernel-java17-openj9-ubi
```

Available images can be listed using [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started). Log in with your IBMid prior to running the following commands. Note that authentication is only required to list the images. **Images can be pulled from ICR without authentication** : 
```
ibmcloud cr region-set global 
ibmcloud cr images --restrict appcafe/websphere-liberty
```


## Latest version (23.0.0.10)

```
kernel-java8-openj9-ubi
kernel-java8-ibmjava-ubi
kernel-java11-openj9-ubi
kernel-java17-openj9-ubi

full-java8-openj9-ubi
full-java8-ibmjava-ubi
full-java11-openj9-ubi
full-java17-openj9-ubi
```

## 23.0.0.10

```
23.0.0.10-kernel-java8-openj9-ubi
23.0.0.10-kernel-java8-ibmjava-ubi
23.0.0.10-kernel-java11-openj9-ubi
23.0.0.10-kernel-java17-openj9-ubi

23.0.0.10-full-java8-openj9-ubi
23.0.0.10-full-java8-ibmjava-ubi
23.0.0.10-full-java11-openj9-ubi
23.0.0.10-full-java17-openj9-ubi
```

## 23.0.0.9

```
23.0.0.9-kernel-java8-openj9-ubi
23.0.0.9-kernel-java8-ibmjava-ubi
23.0.0.9-kernel-java11-openj9-ubi
23.0.0.9-kernel-java17-openj9-ubi

23.0.0.9-full-java8-openj9-ubi
23.0.0.9-full-java8-ibmjava-ubi
23.0.0.9-full-java11-openj9-ubi
23.0.0.9-full-java17-openj9-ubi
```

## 23.0.0.6

```
23.0.0.6-kernel-java8-openj9-ubi
23.0.0.6-kernel-java8-ibmjava-ubi
23.0.0.6-kernel-java11-openj9-ubi
23.0.0.6-kernel-java17-openj9-ubi

23.0.0.6-full-java8-openj9-ubi
23.0.0.6-full-java8-ibmjava-ubi
23.0.0.6-full-java11-openj9-ubi
23.0.0.6-full-java17-openj9-ubi
```
