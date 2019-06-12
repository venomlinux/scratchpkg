#!/bin/sh

BINDIR=/usr/bin
CONFDIR=/etc
CACHE_DIR=/var/cache/scratchpkg
INDEX_DIR=/var/lib/scratchpkg
PORT_DIR=/usr/ports
REVDEPD=/etc/revdep.d
REVDEPCONF=/etc/revdep.conf

mkdir -pv ${DESTDIR}{${BINDIR},${CONFDIR},${PORT_DIR},${REVDEPD}}
install -m755 revdep pkgadd pkgdel pkgbuild pkgdeplist pkglibdepends scratch pkgbase ${DESTDIR}${BINDIR}
install -m644 scratchpkg.conf scratchpkg.repo ${DESTDIR}${CONFDIR}
install -m755 extra/* ${DESTDIR}${BINDIR}
install -dm777 ${DESTDIR}${CACHE_DIR}/{packages,sources,log,work}
install -m644 revdep.conf ${DESTDIR}${REVDEPCONF}
