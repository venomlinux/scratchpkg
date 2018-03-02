#!/bin/bash

BINDIR=/usr/bin
FUNCDIR=/usr/share/scratchpkg
CONFDIR=/etc
HOOK_DIR=/etc/hooks
HTTPUPDIR=/etc/ports
CACHE_DIR=/var/cache/scratchpkg
INDEX_DIR=/var/lib/scratchpkg
PORT_DIR=/usr/ports

mkdir -pv ${DESTDIR}{${BINDIR},${FUNCDIR},${CONFDIR},${HOOK_DIR},${HTTPUPDIR},${PORT_DIR}}
install -m755 buildpkg installpkg removepkg scratch ${DESTDIR}${BINDIR}
install -m644 functions/* ${DESTDIR}${FUNCDIR}
install -m644 scratchpkg.conf ${DESTDIR}${CONFDIR}/scratchpkg.conf
install -m644 ports/*.httpup ${DESTDIR}${HTTPUPDIR}
install -m755 extra/* ${DESTDIR}${BINDIR}
mkdir -p ${DESTDIR}${CACHE_DIR}/{backup,log,packages,rejected,sources} ${DESTDIR}${INDEX_DIR}/index
