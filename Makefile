APP = dd_disable
PLIST = com.local.dd_disable.plist
DEST = /usr/local/bin/$(APP)
PLIST_DEST = /Library/LaunchDaemons/$(PLIST)

.PHONY: all build clean install uninstall

all: build

build: $(APP)

$(APP): $(APP).m
	clang -fobjc-arc -O2 -mmacosx-version-min=14.0 \
		-framework CoreGraphics \
		-o $@ $<

install: build
	sudo cp $(APP) $(DEST)
	sudo chown root:wheel $(DEST)
	sudo chmod 755 $(DEST)
	sudo cp $(PLIST) $(PLIST_DEST)
	sudo chown root:wheel $(PLIST_DEST)
	sudo launchctl load $(PLIST_DEST)

uninstall:
	sudo launchctl unload $(PLIST_DEST) 2>/dev/null || true
	sudo rm -f $(DEST) $(PLIST_DEST)

clean:
	rm -f $(APP)
