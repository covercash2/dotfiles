#!/bin/bash

# kill running instances
killall -q polybar

# wait for running instances to finish
# while current user has a polybar process
while pgrep -u $UID -x polybar >/dev/null
      # wait
    do sleep 1
done

bar=default

# multi-monitor support
if type "xrandr"; then
    for m in $(xrandr --query | grep " connect" | cut -d" " -f1); do
	echo $m
	MONITOR=$m polybar --reload $bar &
    done
else
    polybar --reload $bar &
fi

echo "polybar launched"
