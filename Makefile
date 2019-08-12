SHELL=/bin/bash

# Configuration variables
KEYCHAIN_VERSION ?= 2.8.1

# These variables should be used to refer to programs that get run, so we can
# install them if necessary.
BIN_DIR ?= .local/bin
LIB_DIR ?= .local/lib
HDR_DIR ?= .local/include
PC_DIR ?= .local/lib/pkgconfig

KEYCHAIN ?= $(BIN_DIR)/keychain
LOOKUP_PASSWORDS ?= .local/src/helper-scripts/lookup_passwords

# "make all"
ALL = \
	$(BIN_DIR)/e \
	$(BIN_DIR)/mbacklight \
	$(BIN_DIR)/term \
	$(BIN_DIR)/parsetorture \
	$(BIN_DIR)/mkenter \
	$(BIN_DIR)/findenter \
	$(BIN_DIR)/findrenter \
	$(BIN_DIR)/fixhttpssubmodules \
	$(BIN_DIR)/hfipip \
	$(BIN_DIR)/whenis \
	$(BIN_DIR)/make.cross \
	$(BIN_DIR)/sps \
	$(BIN_DIR)/notd \
	$(BIN_DIR)/notw \
	$(BIN_DIR)/pnotw \
	$(BIN_DIR)/mhnotd \
	$(BIN_DIR)/git-send-pull \
	$(BIN_DIR)/git-readd-from \
	$(BIN_DIR)/git-archive-branch \
	$(BIN_DIR)/linux-ccm \
	$(BIN_DIR)/lwirv \
	$(BIN_DIR)/slwirv \
	$(BIN_DIR)/giteditcat \
	$(BIN_DIR)/git-mham \
	$(BIN_DIR)/slock \
	$(BIN_DIR)/pwa \
	$(BIN_DIR)/pwm \
	$(KEYCHAIN) \
	.megarc \
	.ssh/config \
	.parallel/will-cite \
	.gitconfig \
	.gitignore
ALL_NOCLEAN = \
	media \
	scratch \
	life \
	work
.PHONY: all
all: $(ALL) $(ALL_NOCLEAN)

# "make clean" -- use CLEAN, so your output gets in .gitignore
CLEAN = \
	$(ALL)
.PHONY: clean
clean:
	rm -rf $(CLEAN) .local/bin .local/lib .local/libexec .local/include

# I want to use the tools I build
PATH:="$(abspath .local/bin):$(PATH)"
export PATH

# All the arguments to pass to pconfigure
PCONFIGURE_WITH_ARGS=$(abspath $(PCONFIGURE)) --phc $(abspath $(PHC)) --ppkg-config $(abspath $(PPKG_CONFIG))

# Some directories on this system might actually be symlinks somewhere else, if
# I'm on a system where $HOME isn't a big disk.
media:
	if test -d /global/$(USER)@dabbelt.com/media; then ln -s /global/$(USER)@dabbelt.com/media $@; else mkdir -p $@; fi
scratch:
	if test -d /scratch/$(USER); then ln -s /scratch/$(USER) $@; else mkdir -p $@; fi
life:
	mkdir $@
work:
	if test -d /scratch/$(USER)/work; then ln -s /scratch/$(USER)/work $@; fi
	if test -d /work/$(USER); then ln -s /work/$(USER) $@; fi
	mkdir -p $@

# These programs can be manually installed so I can use my home drive
# transparently when on other systems.
.local/bin/%: .local/src/local-scripts/%.bash
	mkdir -p $(dir $@)
	cp $^ $@
	chmod +x $@

.local/bin/%: work/software-weekly-notes/scripts/%.bash
	mkdir -p $(dir $@)
	cp $^ $@
	chmod +x $@

.local/bin/%: work/last-week-in-risc-v/scripts/%.bash
	mkdir -p $(dir $@)
	cp $^ $@
	chmod +x $@

.local/bin/%: /usr/bin/%
	mkdir -p $(dir $@)
	cp -Lf $< $@

.local/lib/%: /usr/lib/%
	mkdir -p $(dir $@)
	cp -Lf $< $@

.local/include/%: /usr/include/%
	mkdir -p $(dir $@)
	cp -Lf $< $@

.local/lib:
	mkdir -p $(dir $@)

.local/lib64 .local/lib32: .local/lib
	cd $(dir $@); ln -s $(notdir $<) $(notdir $@)

# Fetch keychain
ifeq (,$(wildcard /usr/bin/keychain))
CLEAN += .local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2
CLEAN += .local/src/keychain/

$(KEYCHAIN): .local/src/keychain/keychain
	mkdir -p $(dir $@)
	cp -Lf $< $@

.local/src/keychain/keychain: .local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xjf $< -C $(dir $@) --strip-components=1

.local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2:
	mkdir -p $(dir $@)
	wget http://www.funtoo.org/distfiles/keychain/keychain-$(KEYCHAIN_VERSION).tar.bz2 -O $@
endif

# Fetch tmux
INSTALLED_TMUX_VERSION = $(shell echo -e "$(GMAKE_VERSION)\n`/usr/bin/tmux -V | head -n1 | cut -d' ' -f2`" | sort --version-sort | head -n1)
ifneq ($(INSTALLED_TMUX_VERSION),$(TMUX_BIN_VERSION))
CLEAN += .local/var/distfiles/tmux-$(TMUX_BIN_VERSION).tar.bz2
CLEAN += .local/src/tmux/

$(TMUX_BIN): .local/src/tmux/build/tmux
	mkdir -p $(dir $@)
	cp -Lf $< $@

.local/src/tmux/build/tmux: .local/src/tmux/build/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@) 

.local/src/tmux/build/Makefile: .local/src/tmux/configure $(LIBEVENT) $(LIBCURSES) $(LIBZ)
	mkdir -p $(dir $@)
	cd $(dir $@) && CPPFLAGS="-I$(abspath $(HDR_DIR)) -I$(abspath $(HDR_DIR)/ncurses)" LDFLAGS="-L$(abspath $(LIB_DIR)) -Wl,-rpath,$(abspath $(LIB_DIR))" ../configure

.local/src/tmux/configure: .local/var/distfiles/tmux-$(TMUX_BIN_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/tmux-$(TMUX_BIN_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/tmux/tmux/releases/download/$(TMUX_BIN_VERSION)/tmux-$(TMUX_BIN_VERSION).tar.gz -O $@
endif

# Fetch libevent
ifeq (,$(wildcard /usr/lib/libevent.so))
CLEAN += .local/var/distfiles/libevent-$(LIBEVENT_VERSION).tar.gz
CLEAN += .local/src/libevent/
CLEAN += .local/include/event.h
CLEAN += .local/include/evhttp.h
CLEAN += .local/include/evdns.h
CLEAN += .local/include/evrpc.h
CLEAN += .local/include/evutil.h
CLEAN += .local/include/event2/
CLEAN += .local/lib/pkgconfig/libevent.pc
CLEAN += .local/lib/pkgconfig/libevent_pthreads.pc
CLEAN += .local/lib/pkgconfig/libevent_openssl.pc
CLEAN += .local/lib/libevent-2.0.so.5
CLEAN += .local/lib/libevent-2.0.so.5.1.9
CLEAN += .local/lib/libevent.a
CLEAN += .local/lib/libevent.la

$(LIBEVENT): .local/src/libevent/build/.libs/libevent.so
	$(MAKE) -C .local/src/libevent/build install

.local/src/libevent/build/.libs/libevent.so: .local/src/libevent/build/Makefile
	$(MAKE) -C .local/src/libevent/build

.local/src/libevent/build/Makefile: .local/src/libevent/configure
	mkdir -p $(dir $@)
	cd $(dir $@) && ../configure --prefix=$(abspath .local)

.local/src/libevent/configure: .local/var/distfiles/libevent-$(LIBEVENT_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/libevent-$(LIBEVENT_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/libevent/libevent/releases/download/release-$(LIBEVENT_VERSION)-stable/libevent-$(LIBEVENT_VERSION)-stable.tar.gz -O $@
endif

# Fetch make
INSTALLED_MAKE_VERSION = $(shell echo -e "$(GMAKE_VERSION)\n`/usr/bin/make --version | head -n1 | cut -d' ' -f3`" | sort --version-sort | head -n1)
ifneq ($(GMAKE_VERSION),$(INSTALLED_MAKE_VERSION))
CLEAN += .local/src/make
CLEAN += .local/var/distfiles/make-$(GMAKE_VERSION).tar.gz

$(GMAKE): .local/src/make/build/make
	cp -Lf $< $@

.local/src/make/build/make: .local/src/make/build/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)

.local/src/make/build/Makefile: .local/src/make/configure
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && ../configure --prefix=$(abspath .local)

.local/src/make/configure: .local/var/distfiles/make-$(GMAKE_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzpf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/make-$(GMAKE_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://ftp.gnu.org/gnu/make/make-$(GMAKE_VERSION).tar.gz -O $@
	touch $@
endif

# Fetch git
INSTALLED_GIT_VERSION = $(shell echo -e "$(GIT_VERSION)\n`/usr/bin/git --version | cut -d' ' -f3`" | sort --version-sort | head -n1)
ifneq ($(GIT_VERSION),$(INSTALLED_GIT_VERSION))
CLEAN += .local/src/git
CLEAN += .local/var/distfiles/git-$(GIT_VERSION).tar.gz
CLEAN += .local/libexec/git-core/

$(GIT): .local/src/git/git
	$(MAKE) NO_TCLTK=YesPlease NO_GETTEXT=YesPlease -C $(dir $<) install
	touch $@

.local/src/git/git: .local/src/git/Makefile
	$(MAKE) NO_TCLTK=YesPlease NO_GETTEXT=YesPlease -C $(dir $@)
	touch $@

.local/src/git/Makefile: .local/src/git/configure $(ZLIB)
	cd $(dir $@) && CFLAGS="-I$(abspath $(HDR_DIR))" LDFLAGS="-L$(abspath $(LIB_DIR))" ./configure --prefix=$(abspath .local/)
	touch $@

.local/src/git/configure: .local/var/distfiles/git-$(GIT_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xpf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/git-$(GIT_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://www.kernel.org/pub/software/scm/git/git-$(GIT_VERSION).tar.gz -O $@
endif

# Fetch pconfigure
ifeq (,$(wildcard /usr/bin/pconfigure))
CLEAN += .local/src/pconfigure
CLEAN += .local/var/distfiles/pconfigure-$(PCONFIGURE_VERSION).tar.gz

$(PHC) $(PPKG_CONFIG): $(PCONFIGURE)
	touch -c $@

$(PCONFIGURE): .local/src/pconfigure/bin/pconfigure
	PATH=$(abspath .local/src/pconfigure/bin):$(PATH) $(MAKE) -C .local/src/pconfigure install

.local/src/pconfigure/bin/pconfigure: .local/src/pconfigure/Makefile
	$(MAKE) -C .local/src/pconfigure

.local/src/pconfigure/Makefile: .local/src/pconfigure/Configfile .local/src/pconfigure/Configfile.local
	+cd $(dir $@) && ./bootstrap.sh

.local/src/pconfigure/Configfile.local:
	mkdir -p $(dir $@)
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@

.local/src/pconfigure/Configfile: .local/var/distfiles/pconfigure-$(PCONFIGURE_VERSION).tar.gz
	rm -rf $(dir $@)i
	mkdir -p $(dir $@)
	tar -C $(dir $@) -xzf $< --strip-components=1
	touch $@

.local/var/distfiles/pconfigure-$(PCONFIGURE_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/palmer-dabbelt/pconfigure/archive/v$(PCONFIGURE_VERSION).tar.gz -O $@
endif

# Fetch pshs
ifeq (,$(wildcard /usr/bin/pshs))
CLEAN += .local/src/pshs
CLEAN += .local/var/distfiles/pshs-$(PSHS_VERSION).tar.bz2

$(PSHS): .local/src/pshs/build/pshs
	cp -Lf $< $@

.local/src/pshs/build/pshs: .local/src/pshs/build/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)

.local/src/pshs/build/Makefile: .local/src/pshs/configure $(LIBEVENT)
	mkdir -p $(dir $@)
	cd $(dir $@) && PKG_CONFIG_PATH=$(abspath $(PC_DIR)) ../configure --prefix=$(abspath .local)

.local/src/pshs/configure: .local/var/distfiles/pshs-$(PSHS_VERSION).tar.bz2
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -C $(dir $@) -xpf $< --strip-components=1
	touch $@

.local/var/distfiles/pshs-$(PSHS_VERSION).tar.bz2:
	mkdir -p $(dir $@)
	wget https://github.com/mgorny/pshs/releases/download/v$(PSHS_VERSION)/pshs-$(PSHS_VERSION).tar.bz2 -O $@
endif

# Fetch pv
ifeq (,$(wildcard /usr/bin/pv))
CLEAN += .local/src/pv
CLEAN += .local/var/distfiles/pv-$(PV_VERSION).tar.gz

$(PV): .local/src/pv/build/pv
	cp -Lf $< $@

.local/src/pv/build/pv: .local/src/pv/build/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)

.local/src/pv/build/Makefile: .local/src/pv/configure
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && ../configure

.local/src/pv/configure: .local/var/distfiles/pv-$(PV_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -C $(dir $@) -xpf $< --strip-components=1
	touch $@

.local/var/distfiles/pv-$(PV_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://www.ivarch.com/programs/sources/pv-$(PV_VERSION).tar.gz -O $@
endif

# Fetch putil
CLEAN += .local/src/putil
CLEAN += .local/var/distfiles/putil-$(PUTIL_VERSION).tar.gz
CLEAN += .local/lib/libputil-*.so
CLEAN += .local/lib/pkgconfig/libputil*.pc
ifeq (,$(wildcard /usr/lib/libputil-*.so))
$(LIBPUTIL): .local/src/putil/lib/pkgconfig/libputil.pc
	$(MAKE) -C .local/src/putil install
	touch $@

.local/src/putil/lib/pkgconfig/libputil.pc: .local/src/putil/Makefile
	$(MAKE) -C .local/src/putil
	touch $@

.local/src/putil/Makefile: .local/src/putil/Configfile .local/src/putil/Configfile.local $(PCONFIGURE) $(LIBGITDATE)
	cd $(dir $@) && PKG_CONFIG_PATH=$(abspath $(PC_DIR)) $(PCONFIGURE_WITH_ARGS)
	touch $@

.local/src/putil/Configfile: .local/var/distfiles/putil-$(PUTIL_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xpf $< --strip-components=1 -C $(dir $@)
	touch $@

.local/src/putil/Configfile.local: .local/src/putil/Configfile
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@
	touch $@

.local/var/distfiles/putil-$(PUTIL_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://github.com/palmer-dabbelt/putil/archive/v$(PUTIL_VERSION).tar.gz -O $@
	touch $@
endif

# Fetch gitdate
ifeq (,$(wildcard /usr/lib/libgitdate.so))
CLEAN += .local/src/gitdate
CLEAN += .local/var/distfiles/gitdate-$(GITDATE_VERSION).tar.gz

$(LIBGITDATE): .local/src/gitdate/lib/libgitdate.so
	$(MAKE) -C .local/src/gitdate install

.local/src/gitdate/lib/libgitdate.so: .local/src/gitdate/Makefile
	$(MAKE) -C .local/src/gitdate

.local/src/gitdate/Makefile: .local/src/gitdate/Configfile .local/src/gitdate/Configfile.local $(PCONFIGURE)
	cd $(dir $@) && PKG_CONFIG_PATH=$(abspath $(PC_DIR)) $(PCONFIGURE_WITH_ARGS)

.local/src/gitdate/Configfile: .local/var/distfiles/gitdate-$(GITDATE_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xpf $< --strip-components=1 -C $(dir $@)
	touch $@

.local/src/gitdate/Configfile.local: .local/src/gitdate/Configfile
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@

.local/var/distfiles/gitdate-$(GITDATE_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://github.com/palmer-dabbelt/gitdate/archive/v$(GITDATE_VERSION).tar.gz -O $@
endif

# Many files should be processed by some internal scripts
%: %.in
	mkdir -p $(dir $@)
	rm -f $@
	cat $< > $@
	chmod oug-w $@

# This particular file is actually generated from a make variable
.gitignore: .gitignore.in Makefile
	rm -f $@
	cat $< > $@
	echo "$(CLEAN)" | sed 's@ @\n@g' | sed 's@^@/@g' >> $@
	echo "$(ALL_NOCLEAN)" | sed 's@ @\n@g' | sed 's@^@/@g' >> $@
	chmod oug-w $@

# GNU porallel is super annoying
.parallel/will-cite:
	mkdir -p $(dir $@)
	touch $@

# Fetch units
ifeq (,$(wildcard /usr/bin/units))
CLEAN += .local/src/units
CLEAN += .local/var/distfiles/units-$(UNITS_VERSION).tar.gz

$(UNITS): .local/src/units/units
	$(MAKE) -C $(dir $^) install

.local/src/units/units: .local/src/units/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)

.local/src/units/Makefile: .local/src/units/configure
	cd $(dir $@); ./configure --prefix=$(HOME)/.local

.local/src/units/configure: .local/var/distfiles/units-$(UNITS_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir $(dir $@)
	tar -xzf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/units-$(UNITS_VERSION).tar.gz:
	wget http://ftp.gnu.org/gnu/units/units-$(UNITS_VERSION).tar.gz -O $@
endif

# Fetch vcddiff
ifeq (,$(wildcard /usr/bin/vcddiff))
CLEAN += .local/src/vcddiff
CLEAN += .local/var/distfiles/vcddiff-$(VCDDIFF_VERSION).tar.gz

$(VCDDIFF): .local/src/vcddiff/bin/vcddiff
	$(MAKE) -C .local/src/vcddiff install

.local/src/vcddiff/bin/vcddiff: .local/src/vcddiff/Makefile
	$(MAKE) -C .local/src/vcddiff

.local/src/vcddiff/Makefile: .local/src/vcddiff/Configfile .local/src/vcddiff/Configfile.local
	+cd $(dir $@) && pconfigure

.local/src/vcddiff/Configfile.local:
	mkdir -p $(dir $@)
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@

.local/src/vcddiff/Configfile: .local/var/distfiles/vcddiff-$(VCDDIFF_VERSION).tar.gz
	rm -rf $(dir $@)i
	mkdir -p $(dir $@)
	tar -C $(dir $@) -xzf $< --strip-components=1
	touch $@

.local/var/distfiles/vcddiff-$(VCDDIFF_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/palmer-dabbelt/vcddiff/archive/v$(VCDDIFF_VERSION).tar.gz -O $@
endif

# A simple speedtest
$(BIN_DIR)/speedtest-cli:
	wget -O $@ https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest_cli.py
	chmod +x $@

# Fetch ncurses
CLEAN += .local/src/ncurses-$(NCURSES_VERSION)
$(LIBCURSES): .local/src/ncurses-$(NCURSES_VERSION)/lib/libncurses.so
	mkdir -p $(dir $@)
	$(MAKE) -C .local/src/ncurses-$(NCURSES_VERSION) install

.local/src/ncurses-$(NCURSES_VERSION)/lib/libncurses.so: .local/src/ncurses-$(NCURSES_VERSION)/Makefile
	$(MAKE) -C .local/src/ncurses-$(NCURSES_VERSION)

.local/src/ncurses-$(NCURSES_VERSION)/Makefile: .local/src/ncurses-$(NCURSES_VERSION)/configure
	cd $(dir $@); CPPFLAGS="-P" ./configure --prefix=$(HOME)/.local --with-shared

.local/src/ncurses-$(NCURSES_VERSION)/configure: .local/var/distfiles/ncurses-$(NCURSES_VERSION).tar.gz
	mkdir -p $(dir $@)
	tar -xzpf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/ncurses-$(NCURSES_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://ftp.gnu.org/gnu/ncurses/ncurses-$(NCURSES_VERSION).tar.gz -O $@

# Fetch zlib
CLEAN += .local/src/zlib-$(ZLIB_VERSION)
$(LIBZ): .local/src/zlib-$(ZLIB_VERSION)/libz.so
	mkdir -p $(dir $@)
	$(MAKE) -C .local/src/zlib-$(ZLIB_VERSION) install

.local/src/zlib-$(ZLIB_VERSION)/libz.so: .local/src/zlib-$(ZLIB_VERSION)/Makefile
	$(MAKE) -C .local/src/zlib-$(ZLIB_VERSION)

.local/src/zlib-$(ZLIB_VERSION)/Makefile: .local/src/zlib-$(ZLIB_VERSION)/configure
	cd $(dir $@); ./configure --prefix=$(HOME)/.local --enable-shared

.local/src/zlib-$(ZLIB_VERSION)/configure: .local/var/distfiles/zlib-$(ZLIB_VERSION).tar.gz
	mkdir -p $(dir $@)
	tar -xzpf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/zlib-$(ZLIB_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://zlib.net/zlib-$(ZLIB_VERSION).tar.gz -O $@

# Fetch nettle
CLEAN += .local/src/nettle-$(NETTLE_VERSION)
ifeq ($(wildcard /usr/lib/libnettle.so),)
$(LIBNETTLE): .local/src/nettle-$(NETTLE_VERSION)/libnettle.so
	mkdir -p $(dir $@)
	$(MAKE) -C .local/src/nettle-$(NETTLE_VERSION) install

.local/src/nettle-$(NETTLE_VERSION)/libnettle.so: \
		.local/src/nettle-$(NETTLE_VERSION)/Makefile \
		.local/lib64 .local/lib32
	$(MAKE) -C .local/src/nettle-$(NETTLE_VERSION)

.local/src/nettle-$(NETTLE_VERSION)/Makefile: \
		.local/src/nettle-$(NETTLE_VERSION)/configure
	cd $(dir $@); ./configure --prefix=$(HOME)/.local --enable-shared

.local/src/nettle-$(NETTLE_VERSION)/configure: .local/var/distfiles/nettle-$(NETTLE_VERSION).tar.xz
	mkdir -p $(dir $@)
	tar -xzpf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/nettle-$(NETTLE_VERSION).tar.xz:
	mkdir -p $(dir $@)
	wget https://ftp.gnu.org/gnu/nettle/nettle-$(NETTLE_VERSION).tar.gz -O $@
endif

# Fetch gnutls
CLEAN += .local/src/gnutls-$(GNUTLS_PATCH_VERSION)
ifeq ($(wildcard /usr/lib/libgnutls.so),)
$(LIBGNUTLS): .local/src/gnutls-$(GNUTLS_PATCH_VERSION)/lib/.libs/libgnutls.so
	mkdir -p $(dir $@)
	$(MAKE) -C .local/src/gnutls-$(GNUTLS_PATCH_VERSION) install
	touch $@

.local/src/gnutls-$(GNUTLS_PATCH_VERSION)/lib/.libs/libgnutls.so: .local/src/gnutls-$(GNUTLS_PATCH_VERSION)/Makefile
	$(MAKE) -C .local/src/gnutls-$(GNUTLS_PATCH_VERSION)
	touch $@

.local/src/gnutls-$(GNUTLS_PATCH_VERSION)/Makefile: \
		.local/src/gnutls-$(GNUTLS_PATCH_VERSION)/configure \
		$(LIBNETTLE)
	cd $(dir $@); PKG_CONFIG_PATH=$(abspath $(PC_DIR)) ./configure --prefix=$(HOME)/.local --libdir=$(HOME)/.local/lib --enable-shared || (cat config.log; find $(abspath $(PC_DIR)); exit 1)
	touch $@

.local/src/gnutls-$(GNUTLS_PATCH_VERSION)/configure: .local/var/distfiles/gnutls-$(GNUTLS_PATCH_VERSION).tar.xz
	mkdir -p $(dir $@)
	tar -xJpf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/gnutls-$(GNUTLS_PATCH_VERSION).tar.xz:
	mkdir -p $(dir $@)
	wget https://www.gnupg.org/ftp/gcrypt/gnutls/v$(GNUTLS_VERSION)/gnutls-$(GNUTLS_PATCH_VERSION).tar.xz -O $@
endif

# Fetch libbase64
ifeq ($(wildcard /usr/lib/libbase64.so),)
CLEAN += .local/src/libbase64-$(LIBBASE64_VERSION)
$(LIBBASE64): .local/src/libbase64-$(LIBBASE64_VERSION)/src/.libs/libbase64.so
	mkdir -p $(dir $@)
	$(MAKE) -C .local/src/libbase64-$(LIBBASE64_VERSION) install
	touch $@

.local/src/libbase64-$(LIBBASE64_VERSION)/src/.libs/libbase64.so: .local/src/libbase64-$(LIBBASE64_VERSION)/Makefile
	$(MAKE) -C .local/src/libbase64-$(LIBBASE64_VERSION)
	touch $@

.local/src/libbase64-$(LIBBASE64_VERSION)/Makefile: \
		.local/src/libbase64-$(LIBBASE64_VERSION)/configure \
		$(LIBNETTLE)
	cd $(dir $@); autoreconf -i
	chmod +x $(dir $@)/configure
	cd $(dir $@); ./configure --prefix=$(abspath .local)
	touch $@

.local/src/libbase64-$(LIBBASE64_VERSION)/configure: .local/var/distfiles/libbase64-$(LIBBASE64_VERSION).tar.gz
	mkdir -p $(dir $@)
	tar -xzpf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/libbase64-$(LIBBASE64_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/palmer-dabbelt/libbase64/archive/v$(LIBBASE64_VERSION).tar.gz -O $@
endif

# Fetch sqlite3
CLEAN += .local/src/sqlite3-$(SQLITE_VERSION)
ifeq ($(wildcard /usr/lib/libsqlite3.so),)
$(LIBSQLITE): .local/src/sqlite3-$(SQLITE_VERSION)/.libs/libsqlite3.so
	mkdir -p $(dir $@)
	$(MAKE) -C .local/src/sqlite3-$(SQLITE_VERSION) install
	touch $@

.local/src/sqlite3-$(SQLITE_VERSION)/.libs/libsqlite3.so: .local/src/sqlite3-$(SQLITE_VERSION)/Makefile
	$(MAKE) -C .local/src/sqlite3-$(SQLITE_VERSION)
	touch $@

.local/src/sqlite3-$(SQLITE_VERSION)/Makefile: \
		.local/src/sqlite3-$(SQLITE_VERSION)/configure \
		$(LIBNETTLE)
	cd $(dir $@); ./configure --prefix=$(abspath .local)
	touch $@

.local/src/sqlite3-$(SQLITE_VERSION)/configure: .local/var/distfiles/sqlite3-$(SQLITE_VERSION).tar.gz
	mkdir -p $(dir $@)
	tar -xzpf $^ -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/sqlite3-$(SQLITE_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://sqlite.org/2017/sqlite-autoconf-$(SQLITE_VERSION).tar.gz -O $@
endif

# Fetch psqlite
CLEAN += .local/src/psqlite
CLEAN += .local/var/distfiles/psqlite-$(PSQLITE_VERSION).tar.gz
CLEAN += .local/lib/libpsqlite.so
ifeq (,$(wildcard /usr/lib/libpsqlite.so))
$(LIBPSQLITE): .local/src/psqlite/lib/libpsqlite.so
	$(MAKE) -C .local/src/psqlite install

.local/src/psqlite/lib/libpsqlite.so: .local/src/psqlite/Makefile
	$(MAKE) -C .local/src/psqlite

.local/src/psqlite/Makefile: \
		.local/src/psqlite/Configfile \
		.local/src/psqlite/Configfile.local \
		$(LIBSQLITE)
	+cd $(dir $@) && pconfigure

.local/src/psqlite/Configfile.local:
	mkdir -p $(dir $@)
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@

.local/src/psqlite/Configfile: .local/var/distfiles/psqlite-$(PSQLITE_VERSION).tar.gz
	rm -rf $(dir $@)i
	mkdir -p $(dir $@)
	tar -C $(dir $@) -xzf $< --strip-components=1
	touch $@

.local/var/distfiles/psqlite-$(PSQLITE_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/palmer-dabbelt/psqlite/archive/v$(PSQLITE_VERSION).tar.gz -O $@
endif

# Fetch mhng
ifeq (,$(wildcard /usr/bin/mhng-install))
CLEAN += .local/src/mhng
CLEAN += .local/var/distfiles/mhng-$(MHNG_VERSION).tar.gz

$(MHNG_INSTALL): .local/src/mhng/bin/mhng-install
	$(MAKE) -C .local/src/mhng install
	touch -c $@

.local/src/mhng/bin/mhng-install: .local/src/mhng/Makefile
	$(MAKE) -C .local/src/mhng
	touch -c $@

.local/src/mhng/Makefile: \
		.local/src/mhng/Configfile \
		.local/src/mhng/Configfile.local \
		$(LIBPUTIL) \
		$(LIBGNUTLS) \
		$(LIBBASE64) \
		$(LIBPSQLITE)
	+cd $(dir $@) && pconfigure

.local/src/mhng/Configfile.local:
	mkdir -p $(dir $@)
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@

.local/src/mhng/Configfile: .local/var/distfiles/mhng-$(MHNG_VERSION).tar.gz
	rm -rf $(dir $@)i
	mkdir -p $(dir $@)
	tar -C $(dir $@) -xzf $< --strip-components=1
	touch $@

.local/var/distfiles/mhng-$(MHNG_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/palmer-dabbelt/mhng/archive/v$(MHNG_VERSION).tar.gz -O $@
endif
