#!/bin/bash

LAST_ORIENTATION=

function getOrientation {
    gdbus introspect --system --dest net.hadess.SensorProxy --object-path /net/hadess/SensorProxy | grep AccelerometerOrientation
}

function getOrientationFromProp {
    case "$1" in
        *"left"*)
            rotate="left";;
        *"right"*)
            rotate="right";;
        *"normal"*)
            rotate="upsidedown";;
        *)
        rotate="normal";;
    esac

    echo $rotate
}

while true; do
    accelerometerOrientationProp=$(getOrientation)
    newOrientation=$(getOrientationFromProp "$accelerometerOrientationProp")
    if [ "$LAST_ORIENTATION" != "$newOrientation" ]; then
        echo "Rotating to $newOrientation"
        LAST_ORIENTATION=$newOrientation
    fi

    sleep 1
done