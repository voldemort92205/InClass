#!/bin/bash

# parameters
src="./*.png"
dest="./PA_birdview.gif"
delay="10"	# the true time will be delay/100

echo "convert begin"
order="convert -delay ${delay} ${src} ${dest}"
$order
echo "convert done"

