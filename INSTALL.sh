#!/bin/sh

BINDIR=/usr/bin
FUNCDIR=/usr/share/scratchpkg
CONFDIR=/etc
HOOK_DIR=/etc/hooks
SYSUSERS_DIR=/etc/sysusers
CACHE_DIR=/var/cache/scratchpkg
INDEX_DIR=/var/lib/scratchpkg
PORT_DIR=/usr/ports

mkdir -pv ${DESTDIR}{${BINDIR},${FUNCDIR},${CONFDIR},${HOOK_DIR},${SYSUSERS_DIR},${PORT_DIR}}
install -m755 revdep buildpkg installpkg removepkg scratch ${DESTDIR}${BINDIR}
install -m644 functions/* ${DESTDIR}${FUNCDIR}
install -m644 scratchpkg.conf scratchpkg.repo ${DESTDIR}${CONFDIR}
install -m755 extra/* ${DESTDIR}${BINDIR}
mkdir -pv ${DESTDIR}${CACHE_DIR}/{log,packages,sources} ${DESTDIR}${INDEX_DIR}/index
