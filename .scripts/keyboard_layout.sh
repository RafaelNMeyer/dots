#!/bin/sh

L="BR"

if [ -n "$(setxkbmap -query | grep us)" ]; then
	L="US"
fi

echo $L
