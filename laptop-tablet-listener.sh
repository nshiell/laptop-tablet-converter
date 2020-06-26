#!/bin/bash
#trap "killall background" EXIT

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

function listenToRotation {
    while true; do
        accelerometerOrientationProp=$(getOrientation)
        newOrientation=$(getOrientationFromProp "$accelerometerOrientationProp")
        if [ "$LAST_ORIENTATION" != "$newOrientation" ]; then
            echo "Rotating to $newOrientation"
            LAST_ORIENTATION=$newOrientation
        fi

        sleep 1
    done
}

function listenToKeyboardFlipEvent {
    sudo evtest --grab /dev/input/event1 SW_TABLET_MODE
}

function listenToKeyboardFlip {
    # | grep --fixed-strings 'Event: time' 
    listenToKeyboardFlipEvent | grep --line-buffered '(SW_TABLET_MODE), value' | while read line; do
        if [ "${line: -1}" == "1" ]; then
            echo tablet mode
        else
            echo laptop mode
        fi
    done
}

sudo echo "Got root"

listenToKeyboardFlip

#listenToRotation
