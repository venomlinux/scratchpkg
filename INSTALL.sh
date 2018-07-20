#!/bin/sh

BINDIR=/usr/bin
CONFDIR=/etc
HOOK_DIR=/etc/hooks
SYSUSERS_DIR=/etc/sysusers
CACHE_DIR=/var/cache/scratchpkg
INDEX_DIR=/var/lib/scratchpkg
PORT_DIR=/usr/ports

mkdir -pv ${DESTDIR}{${BINDIR},${CONFDIR},${HOOK_DIR},${SYSUSERS_DIR},${PORT_DIR}}
install -m755 revdep pkgadd pkgdel pkgbuild pkgcreate pkgdeplist scratch ${DESTDIR}${BINDIR}
install -m644 scratchpkg.conf scratchpkg.repo ${DESTDIR}${CONFDIR}
install -m755 extra/* ${DESTDIR}${BINDIR}
mkdir -pv ${DESTDIR}${CACHE_DIR}/{packages,sources,work} ${DESTDIR}${INDEX_DIR}/index
