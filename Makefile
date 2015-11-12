# Configuration variables
KEYCHAIN_VERSION ?= 2.8.1
TMUX_VERSION ?= 1.9a
LIBEVENT_VERSION ?= 2.0.22
GMAKE_VERSION ?= 3.82

# These variables should be used to refer to programs that get run, so we can
# install them if necessary.
BIN_DIR ?= .local/bin
LIB_DIR ?= .local/lib
HDR_DIR ?= .local/include

CONFIG_PP ?= $(BIN_DIR)/config_pp
KEYCHAIN ?= $(BIN_DIR)/keychain
TMUX ?= $(BIN_DIR)/tmux
LIBEVENT ?= $(LIB_DIR)/libevent.so
GMAKE ?= $(BIN_DIR)/make

LOOKUP_PASSWORDS ?= .local/src/helper-scripts/lookup_passwords

# "make all"
ALL = \
	$(BIN_DIR)/e \
	$(BIN_DIR)/mbacklight \
	$(KEYCHAIN) \
	$(TMUX) \
	$(LIBEVENT) \
	$(GMAKE) \
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
ifeq (,$(wildcard /usr/bin/tmux))
CLEAN += .local/var/distfiles/tmux-$(TMUX_VERSION).tar.bz2
CLEAN += .local/src/tmux/

$(TMUX): .local/src/tmux/build/tmux
	mkdir -p $(dir $@)
	cp -Lf $< $@

.local/src/tmux/build/tmux: .local/src/tmux/build/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@) 

.local/src/tmux/build/Makefile: .local/src/tmux/configure $(LIBEVENT)
	mkdir -p $(dir $@)
	cd $(dir $@) && CPPFLAGS="-I$(HOME)/$(HDR_DIR)" LDFLAGS="-L$(HOME)/$(LIB_DIR) -Wl,-rpath,$(HOME)/$(LIB_DIR)" ../configure

.local/src/tmux/configure: .local/var/distfiles/tmux-$(TMUX_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/tmux-$(TMUX_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/tmux/tmux/releases/download/$(TMUX_VERSION)/tmux-$(TMUX_VERSION).tar.gz -O $@
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
	cd $(dir $@) && ../configure --prefix=$(HOME)/.local

.local/src/libevent/configure: .local/var/distfiles/libevent-$(LIBEVENT_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/libevent-$(LIBEVENT_VERSION).tar.gz:
	wget https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/libevent-$(LIBEVENT_VERSION)-stable.tar.gz -O $@
endif

# Fetch make
ifeq (3.82,$(lastword $(sort $(MAKE_VERSION) 3.82)))
CLEAN += .local/src/make
CLEAN += .local/var/distfiles/make-$(GMAKE_VERSION).tar.gz

$(GMAKE): .local/src/make/build/make
	cp -Lf $< $@

.local/src/make/build/make: .local/src/make/build/Makefile
	$(MAKE) -C $(dir $@) $(notdir $@)

.local/src/make/build/Makefile: .local/src/make/configure
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && ../configure

.local/src/make/configure: .local/var/distfiles/make-$(GMAKE_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzpf $< -C $(dir $@) --strip-components=1
	touch $@

.local/var/distfiles/make-$(GMAKE_VERSION).tar.gz:
	wget http://ftp.gnu.org/gnu/make/make-$(GMAKE_VERSION).tar.gz -O $@
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
