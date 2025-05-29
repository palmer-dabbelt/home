SHELL=/bin/bash
ENV=PATH="$(abspath .local/bin:$(PATH))" PKG_CONFIG_PATH="$(abspath .local/lib/pkgconfig)"
CFLAGS += -O3 -Wall -Werror
SYSTEM_LIBDIR = /opt/homebrew/lib

# Some helper functions
gitfiles = $(addprefix $(1),$(shell git -C $(1) ls-files))
ppkg-config-deps = $(addprefix .local/lib/pkgconfig/,$(addsuffix .pc,$(shell cat .local/src/$(1)/Configfile |  grep ppkg-config | grep -v optional | sed 's/^.*ppkg-config \([A-Za-z0-9-]*\) .*$$/\1/')))

all: \
	.local/bin/pconfigure \
	.local/lib/libputil-chrono.so \
	.local/lib/libpsqlite.so \
	.local/lib/libbase64.so \
	.local/lib/libpson.so \
	.local/bin/mhng-install \
	$(patsubst .local/src/%.bash,.local/bin/%,$(wildcard .local/src/*.bash)) \
	$(patsubst .local/src/%.pl,.local/bin/%,$(wildcard .local/src/*.pl)) \
	$(patsubst .local/src/%.c,.local/bin/%,$(wildcard .local/src/*.c))

clean::
	rm -rf .local/bin .local/lib .local/stamp
	git submodule foreach git clean -dfx

# I've got a bunch of scripts, this builds them automatically
.local/bin/%: .local/src/%.bash
	mkdir -p $(dir $@)
	cp $< $@
	chmod +x $@

.local/bin/%: .local/src/%.pl
	mkdir -p $(dir $@)
	cp $< $@
	chmod +x $@

.local/bin/%: .local/src/%.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

.local/bin/poly: .local/src/poly.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< -lhidapi-hidraw -o $@

# Allow some system
.local/stamp/apt:
	@mkdir -p $(dir $@)
	sudo apt-get install -y build-essential tmux autoconf texinfo pkg-config libtool libtclap-dev libgnutls28-dev libcurl4-gnutls-dev libnotify-dev libncurses-dev libuv1-dev libglib2.0-dev gettext sqlite3 libsqlite3-dev
	touch -c $@

.local/lib/pkgconfig/%.pc: $(SYSTEM_LIBDIR)/pkgconfig/%.pc
	@mkdir -p $(dir $@)
	cp $< $@

# pconfigure
.local/src/pconfigure/Configfile.local:
	echo "PREFIX = $$HOME/.local" > $@

.local/stamp/pconfigure: \
		$(shell find .local/src/pconfigure -name "*.c") \
		.local/src/pconfigure/Configfile.local
	mkdir -p $(dir $@)
	env -C .local/src/pconfigure -- ./bootstrap.sh --verbose
	$(MAKE) -C .local/src/pconfigure install
	date > $@

.local/bin/pconfigure \
.local/bin/pbashc \
		: .local/stamp/pconfigure
	touch -c $@

# gitdate
.local/src/gitdate/Makefile: \
		.local/bin/pconfigure
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/gitdate: .local/src/gitdate/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libgitdate.so .local/lib/libgitdate++.so: .local/stamp/gitdate
	touch -c $@

# putil
.local/src/putil/Makefile: \
		.local/bin/pconfigure \
		.local/lib/libgitdate++.so \
		.local/src/putil/Configfile \
		$(call gitfiles,.local/src/putil/)
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/putil: \
		.local/src/putil/Makefile \
		$(call gitfiles,.local/src/putil/)
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libputil-chrono.so \
.local/lib/pkgconfig/libputil-chrono.pc \
: .local/stamp/putil
	touch -c $@

# psqlite
.local/src/psqlite/Makefile: \
		.local/bin/pconfigure \
		.local/lib/libgitdate++.so \
		.local/src/psqlite/Configfile \
		$(call ppkg-config-deps,psqlite) 
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/psqlite: .local/src/psqlite/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libpsqlite.so \
.local/lib/pkgconfig/psqlite.pc \
: .local/stamp/psqlite
	touch -c $@

# pson
.local/src/pson/Makefile: \
		.local/bin/pconfigure \
		.local/lib/libgitdate++.so \
		.local/src/pson/Configfile \
		$(call ppkg-config-deps,pson)
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/pson: .local/src/pson/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libpson.so .local/lib/pkgconfig/pson.pc: .local/stamp/pson
	touch -c $@

# libbase64
.local/src/libbase64/Makefile: \
		.local/src/libbase64/configure.ac
	env -C $(dir $@) - $(ENV) autoreconf -i
	env -C $(dir $@) - $(ENV) ./configure --prefix=$(abspath .local)

.local/stamp/libbase64: .local/src/libbase64/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libbase64.so \
.local/lib/pkgconfig/libbase64-1.pc \
: .local/stamp/libbase64
	touch -c $@

# MHng
.local/src/mhng/Makefile: \
		.local/bin/pconfigure \
		.local/bin/pbashc \
		.local/lib/libputil-chrono.so \
		.local/lib/libpsqlite.so \
		$(call gitfiles,.local/src/mhng/) \
		$(call ppkg-config-deps,mhng)
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/mhng: \
		.local/src/mhng/Makefile \
		$(call gitfiles,.local/src/mhng/)
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/bin/mhng-%: .local/stamp/mhng
	touch -c $@

# curl
.local/src/curl/Makefile: \
		$(call gitfiles,.local/src/curl/)
	env -C $(dir $@) - $(ENV) autoreconf -i
	env -C $(dir $@) - $(ENV) ./configure --prefix=$(abspath .local/) --with-openssl

.local/stamp/curl: .local/src/curl/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/bin/curl: .local/stamp/curl
	touch -c $@

# Device Tree tools
.local/stamp/dt-schema: .local/src/dt-schema/setup.py
	mkdir -p $(dir $@)
	env -C $(dir $<) $(abspath $<) install --prefix=$(abspath .local/)
	date > $@

.local/bin/dt-schema: .local/stamp/dt-schema
	touch -c $@


