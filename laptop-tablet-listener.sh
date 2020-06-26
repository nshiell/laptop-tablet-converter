#!/bin/bash

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
    echo $accelerometerOrientationProp
    getOrientationFromProp "$accelerometerOrientationProp"
    sleep 1
done