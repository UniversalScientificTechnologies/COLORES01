#!/usr/bin/python
# 
# Initiating of COLORES

import sys
import serial
import time

#### Script Arguments ###############################################

if len(sys.argv) < 3 :
    sys.stderr.write("Invalid number of arguments.\n")
    sys.stderr.write("Usage: %s device command\n" % (sys.argv[0], ))
    sys.exit(1)

print("setcol: initiating")

try:
    ser = serial.Serial(sys.argv[1])
    time.sleep(2)
    command = sys.argv[2]
    for c in command:
        ser.write(c)
        print("setcol: sending %s" % c)
        time.sleep(2)
    ser.close()
    print("setcol: done")
    sys.exit(0)

except IOError:
    print("setcol: can not open device.")
    sys.exit(1)
