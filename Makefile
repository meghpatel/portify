PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin
VERSION = $(shell cat VERSION)

.PHONY: install uninstall lint deb release help

help:
	@echo "make install     install portify to $(BINDIR)"
	@echo "make uninstall   remove portify"
	@echo "make lint        shellcheck/syntax-check the script"
	@echo "make deb         build a .deb package"
	@echo "make release     cut a new GitHub release (see release.sh)"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 portify $(DESTDIR)$(BINDIR)/portify
	@echo "✓ installed $(DESTDIR)$(BINDIR)/portify"

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/portify

lint:
	bash -n portify && echo "✓ syntax OK"
	@command -v shellcheck >/dev/null && shellcheck portify || echo "(shellcheck not installed — skipped)"

deb:
	bash packaging/debian/build-deb.sh $(VERSION)

release:
	bash release.sh
