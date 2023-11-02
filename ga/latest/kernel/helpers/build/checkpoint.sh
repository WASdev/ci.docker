#!/bin/bash

# hack to bump up the pid by 1000
for i in {1..1000}
do
    pidplus.sh
done

ARCH="$(uname -m)";
case "${ARCH}" in
    ppc64el|ppc64le)
        export JVM_ARGS="${JVM_ARGS} -XX:+JVMPortableRestoreMode"
        ;;
    s390x)
        export JVM_ARGS="${JVM_ARGS} -XX:+JVMPortableRestoreMode"
        ;;
    *)
        ;;
esac;


echo "Performing checkpoint --at=$1"
/opt/ibm/wlp/bin/server checkpoint defaultServer --at=$1

rc=$?
if [ $rc -eq 0 ]; then
    # Find all directories in logs/ and output/ that the current user has read/write/execute permissions for
    # and give the same permissions to the group.
    find -L /logs /output -type d -readable -writable -executable -exec chmod g+rwx {} \;

    # Find all files in logs/ and output/ that the current user has read/write permissions for
    # and give the same permissions to the group.
    find -L /logs /output -type f -readable -writable -exec chmod g+rw {} \;
fi

exit $rc
