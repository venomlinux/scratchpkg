#!/bin/bash

bindir="/usr/bin"
confdir="/etc"
funcdir="/usr/share/scratchpkg"

if [ ! -d $bindir ]; then
	mkdir -pv $bindir
	for i in scratch installpkg buildpkg removepkg; do
		cp -v $i $bindir
	done
else
	for i in scratch installpkg buildpkg removepkg; do
		[ ! -f $bindir/$i ] && cp -v $i $bindir || echo "$bindir/$i exists"
	done
fi

if [ ! -d $confdir ]; then
	mkdir -pv $confdir
	[ ! -f $confdir/scratchpkg.conf ] && cp -v scratchpkg.conf $confdir
else
	[ ! -f $confdir/scratchpkg.conf ] && cp -v scratchpkg.conf $confdir || echo "$confdir/scratchpkg.conf exists"
fi

if [ ! -d $funcdir ]; then
	mkdir -pv $funcdir
	[ ! -f $funcdir/functions ] && cp -v functions $funcdir
else
	[ ! -f $funcdir/functions ] && cp -v functions $funcdir || echo "$funcdir/functions exists"
fi
