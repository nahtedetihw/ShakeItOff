ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = shakeitoffprefs
shakeitoffprefs_FILES = SHAKEITOFFPreferences.m
shakeitoffprefs_INSTALL_PATH = /Library/PreferenceBundles
shakeitoffprefs_FRAMEWORKS = UIKit
shakeitoffprefs_PRIVATE_FRAMEWORKS = Preferences
shakeitoffprefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/shakeitoffprefs.plist$(ECHO_END)
