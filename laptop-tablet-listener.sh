#!/bin/bash
#trap "killall background" EXIT

LAST_ORIENTATION=
PID_INHIBIT_KEYBOARD=0

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


function rotateNormal {
    xrandr -o normal
    xinput set-prop "Elan Touchscreen" --type=float \
        "Coordinate Transformation Matrix" 0 0 0 0 0 0 0 0 0
}

# @see https://wiki.ubuntu.com/X/InputCoordinateTransformation
function listenToRotation {
    while true; do
        accelerometerOrientationProp=$(getOrientation)
        newOrientation=$(getOrientationFromProp "$accelerometerOrientationProp")
        if [ "$LAST_ORIENTATION" != "$newOrientation" ]; then
            echo "Rotating to $newOrientation"
            LAST_ORIENTATION=$newOrientation

            if [[ "$(ps aux | grep evtest | wc -l)" -gt 2 ]]; then
                case $newOrientation in
                    "right")
                        xrandr -o left
                        xinput set-prop "Elan Touchscreen" --type=float \
                            "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
                        ;;
                    "left")
                        xrandr -o right
                        xinput set-prop "Elan Touchscreen" --type=float \
                            "Coordinate Transformation Matrix" 0 1 0 -1 0 1 0 0 1
                        ;;
                    "upsidedown")
                        xrandr -o inverted
                        xinput set-prop "Elan Touchscreen" --type=float \
                            "Coordinate Transformation Matrix" -1 0 1 0 -1 1 0 0 1
                        ;;
                    *)
                        rotateNormal
                        ;;
                esac
            fi
        fi

        sleep 1
    done
}

function listenToKeyboardFlipEvent {
    evtest --grab /dev/input/event1 SW_TABLET_MODE
}

function listenToKeyboardFlip {
    # | grep --fixed-strings 'Event: time' 
    listenToKeyboardFlipEvent | grep --line-buffered '(SW_TABLET_MODE), value' | while read line; do
        if [ "${line: -1}" == "1" ]; then
            #xinput --set-prop 5 "Device Enabled" 0
            #xinput disable "Virtual core XTEST keyboard"
            xinput set-prop 8 'Device Enabled' 0 # touchpad
            #xinput disable "Virtual core XTEST keyboard"
            echo tablet mode
            echo
            echo
            evtest --grab /dev/input/event0 &
            PID_INHIBIT_KEYBOARD=$!
        else
            #xinput enable "Virtual core XTEST keyboard"
            xinput set-prop 8 'Device Enabled' 1
            if [[ "$PID_INHIBIT_KEYBOARD" -gt 0 ]]; then
                echo "Killing $PID_INHIBIT_KEYBOARD"
                kill $PID_INHIBIT_KEYBOARD
                echo laptop mode
                PID_INHIBIT_KEYBOARD=0
                rotateNormal
            fi
        fi
    done
}

#sudo echo "Got root"

listenToKeyboardFlip &
listenToRotation
