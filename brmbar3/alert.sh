#!/bin/sh

case $1 in
alert) mplayer -really-quiet ~/trombone.wav & ;;
limit) mplayer -really-quiet ~/much.wav & ;;
charge) mplayer -really-quiet ~/charge.wav & ;;
esac
