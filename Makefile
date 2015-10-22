# Configuration variables
KEYCHAIN_VERSION ?= 2.8.1
TMUX_VERSION ?= 1.9a

# These variables should be used to refer to programs that get run, so we can
# install them if necessary.
BIN_DIR ?= .local/bin

CONFIG_PP ?= $(BIN_DIR)/config_pp
KEYCHAIN ?= $(BIN_DIR)/keychain
TMUX ?= $(BIN_DIR)/tmux

LOOKUP_PASSWORDS ?= .local/src/helper-scripts/lookup_passwords

# "make all"
ALL = \
	$(BIN_DIR)/e \
	$(BIN_DIR)/mbacklight \
	$(KEYCHAIN) \
	$(TMUX) \
	.megarc \
	.ssh/config \
	.parallel/will-cite \
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
	ln -sf $(shell readlink -f $<) $@

# Implicit rules for building GNU stuff
.local/src/%/build/%: .local/src/%/build/Makefile
	$(MAKE) -C $(dir $@)

.local/src/%/build/Makefile: .local/src/%/configure
	mkdir -p $(dir $@)
	cd $(dir $@) && ../configure

# Fetch keychain
ifeq (,$(wildcard /usr/bin/keychain))
CLEAN += .local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2
CLEAN += .local/src/keychain/

$(KEYCHAIN): .local/src/keychain/keychain
	mkdir -p $(dir $@)
	ln -s $< $@

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
	ln -sf $(shell readlink -f $<) $@

.local/src/tmux/configure: .local/var/distfiles/tmux-$(TMUX_VERSION).tar.gz
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xzf $< -C $(dir $@) --strip-components=1

.local/var/distfiles/tmux-$(TMUX_VERSION).tar.gz:
	mkdir -p $(dir $@)
	wget https://github.com/tmux/tmux/releases/download/$(TMUX_VERSION)/tmux-$(TMUX_VERSION).tar.gz -O $@
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
