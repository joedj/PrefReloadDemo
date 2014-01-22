TARGET := iphone:clang::4.3
ARCHS := armv7 arm64

ifdef CCC_ANALYZER_OUTPUT_FORMAT
  TARGET_CXX = $(CXX)
  TARGET_LD = $(TARGET_CXX)
endif

ADDITIONAL_CFLAGS += -fobjc-arc -g -fvisibility=hidden
ADDITIONAL_LDFLAGS += -fobjc-arc -Wl,-map,$@.map -g -x c /dev/null -x none

BUNDLE_NAME = PrefsReloadDemoSettings PrefsReloadDemoSwitch

PrefsReloadDemoSettings_BUNDLE_RESOURCE_DIRS = Settings
PrefsReloadDemoSettings_FILES = Settings.m
PrefsReloadDemoSettings_PRIVATE_FRAMEWORKS = Preferences
PrefsReloadDemoSettings_INSTALL_PATH = /Library/PreferenceBundles

PrefsReloadDemoSwitch_BUNDLE_RESOURCE_DIRS = Switch
PrefsReloadDemoSwitch_FILES = Switch.m
PrefsReloadDemoSwitch_INSTALL_PATH = /Library/Switches

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

after-stage::
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) \( -iname '*.plist' -or -iname '*.strings' \) -exec plutil -convert binary1 {} \;$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -d \( -iname '*.dSYM' -or -iname '*.map' \) -execdir rm -rf {} \;$(ECHO_END)

after-install::
	install.exec "killall backboardd"

after-clean::
	rm -f *.deb
