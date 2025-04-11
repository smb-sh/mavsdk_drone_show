#!/bin/bash

# Get the number of instances as input
num_instances=$1

# Check if the number of instances is provided
if [ -z "$num_instances" ]
then
    echo "Please provide the number of instances as argument"
    exit 1
fi

# Loop to create instances
for (( i=1; i<=$num_instances; i++ ))
do
    echo "Checking instance drone-$i"

    container_exists=$(docker ps -a -q -f name=^drone-$i$)

    if [ -n "$container_exists" ]; then
        echo "Container drone-$i already exists."

        # بررسی اینکه آیا در حال اجرا نیست، اگر نیست، آن را اجرا کن
        if [ -z "$(docker ps -q -f name=^drone-$i$)" ]; then
            echo "Starting existing container drone-$i"
            docker start drone-$i
        else
            echo "Container drone-$i is already running."
        fi

    else
        echo "Creating and starting new container drone-$i"

        # ساخت فایل hwID خالی
        touch $i.hwID

        # اجرای کانتینر داکر
        #docker run --name drone-$i -d drone-template:v3.0 bash /root/mavsdk_drone_show/multiple_sitl/startup_sitl.sh
        docker run --cpus="0.2" --log-driver=json-file --log-opt max-size=50m --name drone-$i -d drone-template:v3.0 bash /root/mavsdk_drone_show/multiple_sitl/startup_sitl.sh
        # docker run --cpus="0.2" --log-driver=none --name drone-$i -d drone-template:v3.0 bash /root/mavsdk_drone_show/multiple_sitl/startup_sitl.sh

        # وقفه کوتاه
        sleep 2

        # کپی فایل به داخل کانتینر
        docker cp $i.hwID drone-$i:/root/mavsdk_drone_show/

        # حذف فایل محلی
        rm $i.hwID
    fi
done
