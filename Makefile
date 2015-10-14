# These variables should be used to refer to programs that get run, so we can
# install them if necessary.
BIN_DIR ?= .local/bin

CONFIG_PP ?= $(BIN_DIR)/config_pp

LOOKUP_PASSWORDS ?= .local/src/helper-scripts/lookup_passwords

# "make all"
ALL = \
	$(BIN_DIR)/e \
	.megarc \
	.ssh/config \
	.gitignore
.PHONY: all
all: $(ALL)

# "make clean" -- use CLEAN, so your output gets in .gitignore
CLEAN = \
	$(ALL) \
	$(CONFIG_PP)
.PHONY: clean
clean:
	rm -rf $(CLEAN)

# These programs can be manually installed so I can use my home drive
# transparently when on other systems.
.local/bin/%: $(HOME)/.local/src/local-scripts/%.bash
	mkdir -p $(dir $@)
	cp $^ $@
	chmod +x $@

# Many files should be processed by some internal scripts
%: %.in $(CONFIG_PP) %.in.d
	mkdir -p $(dir $@)
	rm -f $@
	$(CONFIG_PP) $< | $(LOOKUP_PASSWORDS) > $@
	chmod oug-w $@

# Some special dependency logic for .in files
-include $(patsubst %,%.in.d,$(ALL))
%.in.d: %.in $(LOOKUP_PASSWORDS)
	$(LOOKUP_PASSWORDS) -d $^ $(patsubst %.in.d,%,$^) > $@ 

# This particular file is actually generated from a make variable
.gitignore: .gitignore.in Makefile
	cat .gitignore.in > .gitignore
	echo "$(CLEAN)" | sed 's@ @\n@g' | sed 's@^@/@g' >> .gitignore 
