SHELL=/bin/bash
ENV=PATH="$(abspath .local/bin:$(PATH))" PKG_CONFIG_PATH="$(abspath .local/lib/pkgconfig)"

gitfiles = $(addprefix $(1),$(shell git -C $(1) ls-files))

all: \
	.local/bin/pconfigure \
	.local/lib/libputil-chrono.so \
	.local/lib/libpsqlite.so \
	.local/lib/libbase64.so \
	.local/lib/libpson.so \
	.local/bin/mhng-install \
	.local/bin/msmtp \
	.local/bin/gclient .local/bin/fetch .local/bin/gn \
	$(patsubst .local/src/%.bash,.local/bin/%,$(wildcard .local/src/*.bash))

clean::
	rm -rf .local/bin .local/lib .local/stamp
	git submodule foreach git clean -dfx

# I've got a bunch of scripts, this builds them automatically
.local/bin/%: .local/src/%.bash
	mkdir -p $(dir $@)
	cp $< $@
	chmod +x $@

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
		:.local/stamp/pconfigure
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

.local/lib/libputil-chrono.so: .local/stamp/putil
	touch -c $@

# psqlite
.local/src/psqlite/Makefile: \
		.local/bin/pconfigure \
		.local/lib/libgitdate++.so \
		.local/src/psqlite/Configfile
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/psqlite: .local/src/psqlite/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libpsqlite.so: .local/stamp/psqlite
	touch -c $@

# pson
.local/src/pson/Makefile: \
		.local/bin/pconfigure \
		.local/lib/libgitdate++.so \
		.local/src/pson/Configfile
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/pson: .local/src/pson/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libpson.so: .local/stamp/pson
	touch -c $@

# libbase64
.local/src/libbase64/Makefile: .local/src/libbase64/configure.ac
	env -C $(dir $@) - $(ENV) autoreconf -i
	env -C $(dir $@) - $(ENV) ./configure --prefix=$(abspath .local)

.local/stamp/libbase64: .local/src/libbase64/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/lib/libbase64.so: .local/stamp/libbase64
	touch -c $@

# msmtp
.local/src/msmtp/Makefile: .local/src/msmtp/configure.ac
	env -C $(dir $@) - $(ENV) autoreconf -i
	env -C $(dir $@) - $(ENV) ./configure --prefix=$(abspath .local)

.local/stamp/msmtp: .local/src/msmtp/Makefile
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/bin/msmtp: .local/stamp/msmtp
	touch -c $@

# MHng
.local/src/mhng/Makefile: \
		.local/bin/pconfigure \
		.local/bin/pbashc \
		.local/lib/libputil-chrono.so \
		.local/lib/libpsqlite.so \
		$(call gitfiles,.local/src/mhng/)
	env -C $(dir $@) - $(ENV) $(abspath $<) "PREFIX = $(abspath .local)"

.local/stamp/mhng: \
		.local/src/mhng/Makefile \
		$(call gitfiles,.local/src/mhng/)
	mkdir -p $(dir $@)
	$(MAKE) -C $(dir $<) install
	date > $@

.local/bin/mhng-%: .local/stamp/mhng
	touch -c $@

# depot_tools
.local/bin/gclient \
.local/bin/fetch \
.local/bin/gn \
		: .local/src/depot_tools_wrapper.bash.in
	mkdir -p $(dir $@)
	cat $^ | sed 's@__TOOL__@$(abspath $(dir $<))/depot_tools/$(notdir $@)@g' > $@
	chmod +x $@
