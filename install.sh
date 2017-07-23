#!/bin/bash

bindir="/usr/bin"
confdir="/etc"

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
	[ ! -d $confdir/scratchpkg.conf.d ] && cp -Rv scratchpkg.conf.d $confdir
else
	[ ! -f $confdir/scratchpkg.conf ] && cp -v scratchpkg.conf $confdir || echo "$confdir/scratchpkg.conf exists"
	[ ! -d $confdir/scratchpkg.conf.d ] && cp -Rv scratchpkg.conf.d $confdir || echo "$confdir/scratchpkg.conf.d exists"
fi
