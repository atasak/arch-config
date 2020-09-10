#!/bin/python

import os
import datetime
import math
import sys

schedulefile = "/run/systemd/shutdown/scheduled"

if not os.path.isfile(schedulefile):
    print("")
    exit(0)

if len(sys.argv) > 1:
    print (sys.argv[1])
    exit(0)

sfile = open(schedulefile, "r")
sdata = sfile.read()

map = {}

for line in sdata.split("\n"):
    split = line.split("=")
    if len(split) == 2:
        map[split[0]] = split[1]

tdelta = datetime.datetime.fromtimestamp(int(map['USEC']) / 1000 / 1000) - datetime.datetime.now()
hours = math.floor(tdelta.seconds / 3600)
minutes = math.floor((tdelta.seconds / 60) % 60)
seconds = math.floor(tdelta.seconds % 60)
if hours > 0:
    print('{} in {:02d}:{:02d}:{:02d}'.format(map['MODE'], hours, minutes, seconds))
else:
    print('{} in {:02d}:{:02d}'.format(map['MODE'], minutes, seconds))
