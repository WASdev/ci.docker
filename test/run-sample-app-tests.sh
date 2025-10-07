#!/bin/bash

tests=(test-pet-clinic test-stock-quote test-stock-trader)
# Set the images below - i.e. images=(test-image-1:tag-1 test-image-2:tag-2)
images=()

for image in "${images[@]}"; do
    echo ""
    echo "************************************"
    echo "Testing image: $image"
    echo "************************************"
    echo ""

    echo "Update stock quote test with old 20140101 config "
    touch -t 201401010000.00 test-stock-quote/config/server.xml test-stock-quote/config/configDropins/defaults/keystore.xml

    # Build sample app
    for test in "${tests[@]}"; do
        cd $test

        if [[ "$image" == *"full"* ]]; then
            dockerfile="Dockerfile-full"
        else
            dockerfile="Dockerfile"
        fi

        echo ""
        echo "Building sample image: $test on $image"
        docker build -t $test -f $dockerfile --build-arg IMAGE=$image .
        cd ..

        # Verify sample app built on open-liberty image
        echo ""
        echo "Verifying sample image: $test on $image"
        ./verify.sh $test
    done
done
