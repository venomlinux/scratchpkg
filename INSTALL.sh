#!/bin/bash

BINDIR=${BINDIR:-/usr/bin}

FUNCDIR=/usr/share/scratchpkg
CONFDIR=/etc
HOOK_DIR=/etc/hooks
HTTPUPDIR=/etc/ports
VAR_DIR=/var/spkg

mkdir -pv ${DESTDIR}{${BINDIR},${FUNCDIR},${CONFDIR},${HOOK_DIR},${HTTPUPDIR}}
install -m755 buildpkg installpkg removepkg scratch ${DESTDIR}${BINDIR}
install -m644 functions/{color,functions,options} ${DESTDIR}${FUNCDIR}
install -m644 scratchpkg.conf ${DESTDIR}${CONFDIR}/scratchpkg.conf.orig
install -m644 ports/{core,extra,xorg}.httpup ${DESTDIR}${HTTPUPDIR}
install -m755 extra/* ${DESTDIR}${BINDIR}
mkdir -p ${DESTDIR}${VAR_DIR}/{backup,index,log,packages,rejected,sources}
