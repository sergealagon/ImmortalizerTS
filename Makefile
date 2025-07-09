TARGET := iphone:clang:16.5:15.0
PACKAGE_FORMAT := ipa
INSTALL_TARGET_PROCESSES = ImmortalizerTS
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = ImmortalizerTS
ImmortalizerTS_FILES = $(wildcard ./src/*.m) $(wildcard ./src/*.mm) 
ImmortalizerTS_FRAMEWORKS = UIKit CoreGraphics QuartzCore IOKit UIKit
ImmortalizerTS_PRIVATE_FRAMEWORKS = CoreServices FrontBoard RunningBoardServices GraphicsServices BackBoardServices SpringBoardServices IOKit Preferences
ImmortalizerTS_CFLAGS = -fcommon -fobjc-arc -Iinclude -I./headers -Wno-error
ImmortalizerTS_CODESIGN_FLAGS = -Sentitlements.xml
ImmortalizerTS_USE_MODULES := 0

include $(THEOS_MAKE_PATH)/application.mk



