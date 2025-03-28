DOCKER := docker run $(shell tty -s && echo -it) -p 8006:8006 --device=/dev/kvm --device=/dev/net/tun --cap-add NET_ADMIN --stop-timeout 10 \
          -e COMMIT=Y -e DISPLAY=web

define make-rules
$(1).install: winetest-windows.install
	$$(MAKE) -C /media/rbernon/LaCie/Downloads $$(IMAGE)/check
	$$(DOCKER) -v $$(IMAGE):/custom.iso -e LANGUAGE=$$(LANGUAGE) -e REGION=$$(LOCALE) -e KEYBOARD=$$(LOCALE) \
	  --cidfile=$$@ --entrypoint=/usr/bin/tini rbernon/winetest-windows:latest -- \
	  bash -c 'mkisofs -J -o /drivers.iso /data; /run/entry.sh' 1>/dev/null
	docker commit $$$$(cat $$@) rbernon/$(1):latest
	docker container rm $$$$(cat $$@)
all-install:: $(1).install
endef

win7u-i386-en.install: LANGUAGE := English
win7u-i386-en.install: LOCALE   := en-US
win7u-i386-en.install: IMAGE    := /media/rbernon/LaCie/Downloads/en_windows_7_ultimate_with_sp1_x86_dvd_u_677460.iso
$(eval $(call make-rules,win7u-i386-en))

win7u-amd64-en.install: LANGUAGE := English
win7u-amd64-en.install: LOCALE   := en-US
win7u-amd64-en.install: IMAGE    := /media/rbernon/LaCie/Downloads/en_windows_7_ultimate_with_sp1_x64_dvd_u_677332.iso
$(eval $(call make-rules,win7u-amd64-en))

win81-i386-en.install: LANGUAGE := English
win81-i386-en.install: LOCALE   := en-US
win81-i386-en.install: IMAGE    := /media/rbernon/LaCie/Downloads/en_windows_8.1_with_update_x86_dvd_6051550.iso
$(eval $(call make-rules,win81-i386-en))

win81-amd64-en.install: LANGUAGE := English
win81-amd64-en.install: LOCALE   := en-US
win81-amd64-en.install: IMAGE    := /media/rbernon/LaCie/Downloads/en_windows_8.1_with_update_x64_dvd_6051480.iso
$(eval $(call make-rules,win81-amd64-en))

win21h1-amd64-en.install: LANGUAGE := English
win21h1-amd64-en.install: LOCALE   := en-US
win21h1-amd64-en.install: IMAGE    := /media/rbernon/LaCie/Downloads/en-us_windows_10_consumer_editions_version_21h1_updated_dec_2022_x64_dvd_c0e97d21.iso
$(eval $(call make-rules,win21h1-amd64-en))

WINETEST64 := $(HOME)/Code/build-wine/build64/programs/winetest/x86_64-windows/winetest.exe
WINETEST32 := $(HOME)/Code/build-wine/build64/programs/winetest/i386-windows/winetest.exe
WINETEST := $(WINETEST64) $(subst /tests/,:,$(subst .ok,,$(filter %.ok,$(MAKECMDGOALS)))) $(subst /tests/check,,$(filter %/check,$(MAKECMDGOALS)))

%/tests: %.install build/sudo.exe
	touch build/winetest.report
	cp $(firstword $(WINETEST)) build/winetest.exe
	echo "start sudo winetest.exe -q -o \\\\\\\\host.lan\\data\\winetest.report -t rbernon -m rbernon@codeweavers.com -i info $(wordlist 2,$(words $(WINETEST)),$(WINETEST))" >build/autorun.bat
	$(DOCKER) --volume=$(CURDIR)/build:/data --rm --entrypoint=/usr/bin/tini rbernon/$* -- bash -c 'mkisofs -J -o /drivers.iso /data; /run/entry.sh' 1>/dev/null
	grep -e "done" -e "Test failed" -e "Test succeeded" -e "tests executed.*failures" build/winetest.report | grep -v -e 'done 0' -e ' 0 failures'

%.ok %/check: win21h1-amd64-en/tests
	echo $@ done

winetest-windows.install: Dockerfile build/sudo.exe build/configure.exe build/install.bat build/startup.bat
	echo "start sudo configure.exe" >build/autorun.bat
	docker build -f Dockerfile -t rbernon/winetest-windows:latest build
	docker push rbernon/winetest-windows:latest
	touch $@

build/%.exe: src/%.c | $(shell mkdir -p build)
	i686-w64-mingw32-gcc -o $@ $< -mwindows -municode

build/%: src/%
	cp -a $< $@

.SUFFIXES:
