LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    gui.cpp \
    resources.cpp \
    pages.cpp \
    text.cpp \
    image.cpp \
    action.cpp \
    console.cpp \
    fill.cpp \
    button.cpp \
    checkbox.cpp \
    fileselector.cpp \
    progressbar.cpp \
    animation.cpp \
    conditional.cpp \
    slider.cpp \
    slidervalue.cpp \
    listbox.cpp \
    keyboard.cpp \
    input.cpp \
    blanktimer.cpp \
    partitionlist.cpp

ifneq ($(TWRP_CUSTOM_KEYBOARD),)
  LOCAL_SRC_FILES += $(TWRP_CUSTOM_KEYBOARD)
else
  LOCAL_SRC_FILES += hardwarekeyboard.cpp
endif

LOCAL_SHARED_LIBRARIES += libminuitwrp libc libstdc++
LOCAL_MODULE := libguitwrp

# Use this flag to create a build that simulates threaded actions like installing zips, backups, restores, and wipes for theme testing
#TWRP_SIMULATE_ACTIONS := true
ifeq ($(TWRP_SIMULATE_ACTIONS), true)
LOCAL_CFLAGS += -D_SIMULATE_ACTIONS
endif

#TWRP_EVENT_LOGGING := true
ifeq ($(TWRP_EVENT_LOGGING), true)
LOCAL_CFLAGS += -D_EVENT_LOGGING
endif

ifneq ($(RECOVERY_SDCARD_ON_DATA),)
	LOCAL_CFLAGS += -DRECOVERY_SDCARD_ON_DATA
endif
ifneq ($(TW_EXTERNAL_STORAGE_PATH),)
	LOCAL_CFLAGS += -DTW_EXTERNAL_STORAGE_PATH=$(TW_EXTERNAL_STORAGE_PATH)
endif
ifneq ($(TW_BRIGHTNESS_PATH),)
	LOCAL_CFLAGS += -DTW_BRIGHTNESS_PATH=$(TW_BRIGHTNESS_PATH)
endif
ifneq ($(TW_MAX_BRIGHTNESS),)
	LOCAL_CFLAGS += -DTW_MAX_BRIGHTNESS=$(TW_MAX_BRIGHTNESS)
else
	LOCAL_CFLAGS += -DTW_MAX_BRIGHTNESS=255
endif
ifneq ($(TW_NO_SCREEN_BLANK),)
	LOCAL_CFLAGS += -DTW_NO_SCREEN_BLANK
endif
ifneq ($(TW_NO_SCREEN_TIMEOUT),)
	LOCAL_CFLAGS += -DTW_NO_SCREEN_TIMEOUT
endif
ifeq ($(HAVE_SELINUX), true)
LOCAL_CFLAGS += -DHAVE_SELINUX
endif
ifneq ($(LANDSCAPE_RESOLUTION),)
	LOCAL_CFLAGS += -DTW_HAS_LANDSCAPE
endif
ifneq ($(TW_DEFAULT_ROTATION),)
	LOCAL_CFLAGS += -DTW_DEFAULT_ROTATION=$(TW_DEFAULT_ROTATION)
endif
ifneq ($(BOARD_SYSTEMIMAGE_PARTITION_SIZE),)
    LOCAL_CFLAGS += -DBOARD_SYSTEMIMAGE_PARTITION_SIZE=$(BOARD_SYSTEMIMAGE_PARTITION_SIZE)
endif

LOCAL_C_INCLUDES += bionic external/stlport/stlport $(commands_recovery_local_path)/gui/devices/$(DEVICE_RESOLUTION)

include $(BUILD_STATIC_LIBRARY)

# Transfer in the resources for the device
include $(CLEAR_VARS)
LOCAL_MODULE := twrp
LOCAL_MODULE_TAGS := eng
LOCAL_MODULE_CLASS := RECOVERY_EXECUTABLES
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)/res

TWRP_RES_LOC := $(commands_recovery_local_path)/gui/devices
TWRP_RES_GEN := $(intermediates)/twrp

ifeq ($(LANDSCAPE_RESOLUTION),)
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_RES_LOC)/common/res/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_RES_LOC)/$(DEVICE_RESOLUTION)/res/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	$(TWRP_RES_LOC)/process_includes.sh $(TWRP_RES_LOC)/$(DEVICE_RESOLUTION)/res/ui.xml $(TARGET_RECOVERY_ROOT_OUT)/res/ui.xml
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin/
	ln -sf /sbin/busybox $(TARGET_RECOVERY_ROOT_OUT)/sbin/sh
	ln -sf /sbin/pigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gzip
	ln -sf /sbin/unpigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gunzip
else
$(TWRP_RES_GEN):
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res/
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res/landscape/
	cp -fr $(TWRP_RES_LOC)/$(DEVICE_RESOLUTION)/res/* $(TARGET_RECOVERY_ROOT_OUT)/res/
	cp -fr $(TWRP_RES_LOC)/$(LANDSCAPE_RESOLUTION)/res/* $(TARGET_RECOVERY_ROOT_OUT)/res/landscape/
	$(TWRP_RES_LOC)/process_includes.sh $(TWRP_RES_LOC)/$(DEVICE_RESOLUTION)/res/ui.xml $(TARGET_RECOVERY_ROOT_OUT)/res/ui.xml
	$(TWRP_RES_LOC)/process_includes.sh $(TWRP_RES_LOC)/$(LANDSCAPE_RESOLUTION)/res/ui.xml $(TARGET_RECOVERY_ROOT_OUT)/res/landscape/ui.xml
	mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin/
	ln -sf /sbin/busybox $(TARGET_RECOVERY_ROOT_OUT)/sbin/sh
	ln -sf /sbin/pigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gzip
	ln -sf /sbin/unpigz $(TARGET_RECOVERY_ROOT_OUT)/sbin/gunzip
endif

LOCAL_GENERATED_SOURCES := $(TWRP_RES_GEN)
LOCAL_SRC_FILES := twrp $(TWRP_RES_GEN)
include $(BUILD_PREBUILT)
