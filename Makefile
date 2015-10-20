# Configuration variables
KEYCHAIN_VERSION ?= 2.8.1

# These variables should be used to refer to programs that get run, so we can
# install them if necessary.
BIN_DIR ?= .local/bin

CONFIG_PP ?= $(BIN_DIR)/config_pp
KEYCHAIN ?= $(BIN_DIR)/keychain

LOOKUP_PASSWORDS ?= .local/src/helper-scripts/lookup_passwords

# "make all"
ALL = \
	$(BIN_DIR)/e \
	$(BIN_DIR)/mbacklight \
	$(KEYCHAIN) \
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
.local/bin/%: $(HOME)/.local/src/local-scripts/%.bash
	mkdir -p $(dir $@)
	cp $^ $@
	chmod +x $@

# Check to see if keychain needs to be installed, and if so fetch/install it
ifeq (,$(wildcard /usr/bin/keychain))
CLEAN += .local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2
CLEAN += .local/src/keychain/

$(KEYCHAIN): .local/src/keychain/keychain
	mkdir -p $(dir $@)
	cp $< $@
	chmod +x $@

.local/src/keychain/keychain: .local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	tar -xjf $< -C $(dir $@) --strip-components=1

.local/var/distfiles/keychain-$(KEYCHAIN_VERSION).tar.bz2:
	mkdir -p $(dir $@)
	wget http://www.funtoo.org/distfiles/keychain/keychain-$(KEYCHAIN_VERSION).tar.bz2 -O $@

else
$(KEYCHAIN):
	mkdir -p $(dir $@)
	ln -s $< $@
endif

# Many files should be processed by some internal scripts
%: %.in $(CONFIG_PP) %.in.d
	mkdir -p $(dir $@)
	rm -f $@
	$(CONFIG_PP) $< | $(LOOKUP_PASSWORDS) > $@
	chmod oug-w $@

# Some special dependency logic for .in files
-include $(patsubst %,%.in.d,$(ALL))
%.in.d: %.in
	$(LOOKUP_PASSWORDS) -d $^ $(patsubst %.in.d,%,$^) > $@ 

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
