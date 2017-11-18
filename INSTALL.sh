#!/bin/bash

DESTDIR=${DESTDIR:-}
BINDIR=${BINDIR:-/usr/bin}

FUNCDIR=/usr/share/scratchpkg
CONFDIR=/etc
HTTPUPDIR=/etc/ports

mkdir -pv ${DESTDIR}{${BINDIR},${FUNCDIR},${CONFDIR},${HTTPUPDIR}}
install -m755 buildpkg installpkg removepkg scratch ${DESTDIR}${BINDIR}
install -m644 functions/{color,functions,options} ${DESTDIR}${FUNCDIR}
install -m644 scratchpkg.conf ${DESTDIR}${CONFDIR}/scratchpkg.conf.orig
install -m644 ports/{core,extra,xorg}.httpup ${DESTDIR}${HTTPUPDIR}
install -m755 extra/* ${DESTDIR}${BINDIR}
