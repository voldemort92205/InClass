#!/bin/bash

# parameters, change here
src="./*.png"	# images you want to convert
dest="./PA_birdview.gif"	# gif name
delay="10"	# the true time interval will be delay/100

# worksection, do not change this part
echo "convert begin"
order="convert -delay ${delay} ${src} ${dest}"
$order
echo "convert done"

