#!/usr/bin/python
# 
# Initiating of COLORES

import sys
import serial
import time

#### Script Arguments ###############################################

if len(sys.argv) != 3 :
    sys.stderr.write("Invalid number of arguments.\n")
    sys.stderr.write("Usage: %s device command\n" % (sys.argv[0], ))
    sys.exit(1)

print("setcol: initiating")

try:
    ser = serial.Serial(sys.argv[1], 9600, timeout=0) 
    time.sleep(2)
    command = sys.argv[2]
    ser.write(command)
    ser.close()
    print("setcol: sending")
    time.sleep(len(command)*1.5)
    print("setcol: done")
    sys.exit(0)

except IOError:
    print("setcol: can not open device.")
    sys.exit(1)
