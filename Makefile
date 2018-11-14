# vimget
# wget for vim plugins

PREFIX=/usr/local

install:
	cp vimget $(PREFIX)/bin/vimget
	chmod 755 $(PREFIX)/bin/vimget

uninstall:
	rm -f $(PREFIX)/bin/vimget
