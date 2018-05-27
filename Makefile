NAME =		scratchpkg
MAIN = 		scratch buildpkg installpkg removepkg
CONF =		$(NAME).conf
BINDIR =	/usr/bin
FUNCDIR =	/usr/share/$(NAME)
PORTDIR =	/etc/ports
CONFDIR =	/etc

install:
	install -d $(DESTDIR)$(BINDIR) $(DESTDIR)$(PORTDIR) $(DESTDIR)$(FUNCDIR)
	install -m755 $(MAIN) extra/* $(DESTDIR)$(BINDIR)
	install -m644 functions/* $(DESTDIR)$(FUNCDIR)
	install -m644 ports/* $(DESTDIR)$(PORTDIR)
	install -m644 $(CONF) $(DESTDIR)$(CONFDIR)

.PHONY: install