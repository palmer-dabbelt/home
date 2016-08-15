# Configuration variables
KEYCHAIN_VERSION ?= 2.8.1
TMUX_BIN_VERSION ?= 2.1
LIBEVENT_VERSION ?= 2.0.22
GMAKE_VERSION ?= 3.82
GIT_VERSION ?= 2.4.10
PCONFIGURE_VERSION ?= 0.11.10
PSHS_VERSION ?= 0.3
PV_VERSION ?= 1.6.0
PUTIL_VERSION ?= 0.0.4
GITDATE_VERSION ?= 0.0.2
UNITS_VERSION ?= 2.12
VCDDIFF_VERSION ?= 0.0.5

# These variables should be used to refer to programs that get run, so we can
# install them if necessary.
BIN_DIR ?= .local/bin
LIB_DIR ?= .local/lib
HDR_DIR ?= .local/include
PC_DIR ?= .local/lib/pkgconfig

CONFIG_PP ?= $(BIN_DIR)/config_pp
KEYCHAIN ?= $(BIN_DIR)/keychain
TMUX_BIN ?= $(BIN_DIR)/tmux
LIBEVENT ?= $(LIB_DIR)/libevent.so
GMAKE ?= $(BIN_DIR)/make
GIT ?= $(BIN_DIR)/git
PCONFIGURE ?= $(BIN_DIR)/pconfigure
PSHS ?= $(BIN_DIR)/pshs
PV ?= $(BIN_DIR)/pv
LIBPUTIL ?= $(LIB_DIR)/pkgconfig/libputil.pc
LIBGITDATE ?= $(LIB_DIR)/libgitdate.so
UNITS ?= $(BIN_DIR)/units
VIMURA ?= $(BIN_DIR)/vimura

LOOKUP_PASSWORDS ?= .local/src/helper-scripts/lookup_passwords

# "make all"
ALL = \
	$(BIN_DIR)/e \
	$(BIN_DIR)/mbacklight \
	$(BIN_DIR)/term \
	$(BIN_DIR)/parsetorture \
	$(BIN_DIR)/mkenter \
	$(BIN_DIR)/fixhttpssubmodules \
	$(BIN_DIR)/vimura \
	$(BIN_DIR)/pmake \
	$(BIN_DIR)/speedtest-cli \
	$(BIN_DIR)/hfipip \
	$(KEYCHAIN) \
	$(TMUX_BIN) \
	$(LIBEVENT) \
	$(GMAKE) \
	$(GIT) \
	$(PCONFIGURE) \
	$(PSHS) \
	$(PV) \
	$(LIBPUTIL) \
	$(UNITS) \
	$(VCDDIFF) \
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
	$(ALL) \
	$(CONFIG_PP)
.PHONY: clean
clean:
	rm -rf $(CLEAN)

# Some directories on this system might actually be symlinks somewhere else, if
# I'm on a system where $HOME isn't a big disk.
media:
	if test -d /global/$(USER)@dabbelt.com/media; then ln -s /global/$(USER)@dabbelt.com/media $@; else mkdir -p $@; fi
scratch:
	if test -d /scratch/$(USER); then ln -s /scratch/$(USER) $@; else mkdir -p $@; fi
life:
	mkdir $@
work:
	if test -d /scratch/$(USER)/work; then ln -s /scratch/$(USER)/work $@; else mkdir -p $@; fi

# These programs can be manually installed so I can use my home drive
# transparently when on other systems.
.local/bin/%: .local/src/local-scripts/%.bash
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

.local/src/tmux/build/Makefile: .local/src/tmux/configure $(LIBEVENT)
	mkdir -p $(dir $@)
	cd $(dir $@) && CPPFLAGS="-I$(abspath $(HDR_DIR))" LDFLAGS="-L$(abspath $(LIB_DIR)) -Wl,-rpath,$(abspath $(LIB_DIR))" ../configure

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
	$(MAKE) -C $(dir $<) install
	touch $@

.local/src/git/git: .local/src/git/Makefile
	$(MAKE) -C $(dir $@)
	touch $@

.local/src/git/Makefile: .local/src/git/configure
	cd $(dir $@) && ./configure --prefix=$(abspath .local/)
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
ifeq (,$(wildcard /usr/lib/libputil.so))
CLEAN += .local/src/putil
CLEAN += .local/var/distfiles/putil-$(PUTIL_VERSION).tar.gz

$(LIBPUTIL): .local/src/putil/lib/pkgconfig/libputil.pc
	$(MAKE) -C .local/src/putil install

.local/src/putil/lib/pkgconfig/libputil.pc: .local/src/putil/Makefile
	$(MAKE) -C .local/src/putil

.local/src/putil/Makefile: .local/src/putil/Configfile .local/src/putil/Configfile.local $(PCONFIGURE) $(LIBGITDATE)
	cd $(dir $@) && PKG_CONFIG_PATH=$(abspath $(PC_DIR)) $(abspath $(PCONFIGURE)) --verbose

.local/src/putil/Configfile: .local/var/distfiles/putil-$(PUTIL_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xpf $< --strip-components=1 -C $(dir $@)
	touch $@

.local/src/putil/Configfile.local: .local/src/putil/Configfile
	rm -f $@
	echo "PREFIX = $(abspath .local)" >> $@

.local/var/distfiles/putil-$(PUTIL_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget http://github.com/palmer-dabbelt/putil/archive/v$(PUTIL_VERSION).tar.gz -O $@
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
	cd $(dir $@) && PKG_CONFIG_PATH=$(abspath $(PC_DIR)) $(abspath $(PCONFIGURE)) --verbose

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
%: %.in $(CONFIG_PP)
	mkdir -p $(dir $@)
	rm -f $@
	$(CONFIG_PP) $< | $(LOOKUP_PASSWORDS) > $@
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

$(BIN_DIR)/speedtest-cli:
	wget -O $@ https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest_cli.py
	chmod +x $@
