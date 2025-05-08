ARCHS := arm64 arm64e
TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME := DayNightSwitch

DayNightSwitch_FILES += FGARootListController.m
DayNightSwitch_CFLAGS += -fobjc-arc
DayNightSwitch_INSTALL_PATH += /Library/PreferenceBundles
DayNightSwitch_FRAMEWORKS += UIKit
DayNightSwitch_PRIVATE_FRAMEWORKS += Preferences

include $(THEOS_MAKE_PATH)/bundle.mk
