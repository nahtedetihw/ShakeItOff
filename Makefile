TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1

PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ShakeItOff

ShakeItOff_FILES = Tweak.xm
ShakeItOff_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
ShakeItOff_FRAMEWORKS = UIKit
ShakeItOff_EXTRA_FRAMEWORKS += Cephei
ShakeItOff_PRIVATE_FRAMEWORKS = MediaRemote

SUBPROJECTS += shakeitoffprefs

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences && killall -9 SpringBoard"
include $(THEOS_MAKE_PATH)/aggregate.mk