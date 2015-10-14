#!/bin/sh

case $1 in
alert) mplayer ~/trombone.wav & ;;
limit) mplayer ~/much.wav & ;;
charge) mplayer ~/charge.wav & ;;
esac
