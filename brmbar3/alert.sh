#!/bin/sh
if [ "$1" = "alert" ]; then
	mplayer ~/trombone.wav &
else
	mplayer ~/much.wav &
fi
