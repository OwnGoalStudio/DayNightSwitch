export PACKAGE_VERSION := 1.2

ARCHS := arm64 arm64e
TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := DayNightSwitch
DayNightSwitch_FILES += Tweak.xm
DayNightSwitch_FILES += DayNightSwitch.m
DayNightSwitch_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard backboardd"

SUBPROJECTS += daynightswitch

include $(THEOS_MAKE_PATH)/aggregate.mk
