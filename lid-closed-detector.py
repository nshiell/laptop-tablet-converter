#!/usr/bin/env python

import struct

infile_path = "/dev/input/event1"
EVENT_SIZE = struct.calcsize("llHHI")
file = open(infile_path, "rb")
event = file.read(EVENT_SIZE)

while event:
    button = struct.unpack("llHHI", event)
    button_id = button[2] + button[3] + button[4]
    if button_id == 7:
        print('TABLET', flush=True)
    elif button_id == 6:
        print('LAPTOP', flush=True)

    (tv_sec, tv_usec, type, code, value) = struct.unpack("llHHI", event)
    event = file.read(EVENT_SIZE)
