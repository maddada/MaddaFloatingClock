NAME = MaddaFloatingClock
APP_NAME = Madda Floating Clock.app
BUNDLE_CONTENTS = $(APP_NAME)/Contents
BUNDLE_MACOS = $(BUNDLE_CONTENTS)/MacOS
BUNDLE_RESOURCES = $(BUNDLE_CONTENTS)/Resources

PREFIX = /Applications
LAUNCH_AGENTS_DIR = $(HOME)/Library/LaunchAgents

PLIST = $(NAME).plist
INSTALLED_PLIST = $(LAUNCH_AGENTS_DIR)/$(PLIST)

.PHONY: install uninstall all clean register unregister app

all: app

app:
	@echo "Building $(APP_NAME)..."
	@mkdir -p "$(BUNDLE_MACOS)"
	@mkdir -p "$(BUNDLE_RESOURCES)"
	swiftc $(NAME).swift -o "$(BUNDLE_MACOS)/$(NAME)"
	@cp Info.plist "$(BUNDLE_CONTENTS)/Info.plist"
	@echo "Built $(APP_NAME) successfully"

$(PLIST): $(PLIST).in
	cat $< | sed 's,@BIN_DIR@,$(PREFIX)/$(APP_NAME)/Contents/MacOS,g;s,@NAME@,$(NAME),g' > $@

clean:
	rm -rf "$(APP_NAME)" $(PLIST)

install: app $(PLIST)
	@echo "Installing to $(PREFIX)/$(APP_NAME)..."
	@rm -rf "$(PREFIX)/$(APP_NAME)"
	@cp -R "$(APP_NAME)" "$(PREFIX)/"
	@install -m 644 $(PLIST) $(INSTALLED_PLIST)
	@echo "Installed successfully"

uninstall: unregister
	rm -rf "$(PREFIX)/$(APP_NAME)" $(INSTALLED_PLIST)

unregister:
	test -f $(INSTALLED_PLIST) && launchctl unload $(INSTALLED_PLIST) || true

register: install
	launchctl load $(INSTALLED_PLIST)

run: app
	@open "$(APP_NAME)"
