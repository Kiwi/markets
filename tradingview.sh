#!/usr/bin/bash

#open some tradingview windows at specific screen positions

#screen resolution at 1366x768, one display

#sleep between new windows opening
SLEEP=2
#script name
SNAME="${0##*/}"

#get window id
getidf() {
	ids=( $( xdotool search --name tradingview ) )
	id="${ids[-1]}" ||
		echo "$SNAME: cannot get window id" >&2
}

#demonise first google-chrome
{
google-chrome-stable --app=https://www.tradingview.com/chart/ISmYtO7U/
getidf
#first sleep may need to be increased to open chrome fully
xdotool windowsize "$id" 680 700 
xdotool windowmove "$id" 0 0
} &
sleep 6

google-chrome-stable --app=https://www.tradingview.com/chart/vSIVmcxS/
getidf
xdotool windowsize "$id" 680 700 
xdotool windowmove "$id" 680 0
sleep $SLEEP

google-chrome-stable --app=https://www.tradingview.com/chart/h2YRqfnP/
getidf
xdotool windowsize "$id" 680 700
xdotool windowmove "$id" 10 10
sleep $SLEEP

google-chrome-stable --app=https://www.tradingview.com/chart/nNx9sErC/
getidf
xdotool windowsize "$id" 680 700 
xdotool windowmove "$id" 690 10

disown 
echo "$SNAME: took $SECONDS seconds to execute" >&2

