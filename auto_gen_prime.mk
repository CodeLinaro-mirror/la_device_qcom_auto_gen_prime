ENABLE_VENDOR_CUTTLEFISH := true

ifeq ($(ENABLE_VENDOR_CUTTLEFISH), true)
TARGET_SINGLE_TREE := true
endif

include device/qcom/gen4_gvm/gen4_gvm.mk

TARGET_BOARD_PLATFORM        := auto_gen
TARGET_BOOTLOADER_BOARD_NAME := auto_gen
TARGET_BOARD_TYPE            := auto
TARGET_BOARD_SUFFIX          := _prime

# Override KERNEL_MODULES_OUT: gen4_gvm.mk evaluates it using $(TARGET_BOARD_PLATFORM)
# which was gen4_gvm at that point; re-evaluate now with auto_gen_prime's platform settings
KERNEL_MODULES_OUT := out/target/product/$(TARGET_BOARD_PLATFORM)$(TARGET_BOARD_SUFFIX)$(TARGET_BOARD_DERIVATIVE_SUFFIX)/$(KERNEL_MODULES_INSTALL)/lib/modules

PRODUCT_NAME   := auto_gen_prime
PRODUCT_DEVICE := auto_gen_prime
PRODUCT_BRAND  := qti
PRODUCT_MODEL  := auto_gen_prime for arm64

ifeq ($(ENABLE_VENDOR_CUTTLEFISH), true)

# Disable GAS. It adds PRODUCT_PACKAGE_OVERLAYS which results in endless boot animation.
TARGET_USES_GAS := false

# Use empty manifest to avoid VINTF conflict with Cuttlefish audiocontrol fragment
DEVICE_MANIFEST_FILE := device/qcom/auto_gen_prime/manifest.xml

# Disable QTI AIDL VHAL - Cuttlefish provides its own VHAL via APEX
# Prevents VINTF conflict: IVehicle/default @4 (QTI) vs @3 (Cuttlefish)
ENABLE_AIDL_VHAL := false

# This is not supported yet, disable to avoid endless loop animation.
LOCAL_ENABLE_OEMLOCK := false

# Gen GVM BoardConfig.mk sets this variable but it is used before assignment. If set,
# it also sets BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT, which is required for
# LA Prime to boot at all (Cuttlefish also sets it).
TARGET_NO_RECOVERY := true

BOARD_DYNAMIC_PARTITION_ENABLE := true

# Clear gen4_gvm product configuration. Cuttlefish aosp_cf.mk below provides the
# PRODUCT variables for the virtual device.
PRODUCT_PACKAGES :=
PRODUCT_PACKAGES_DEBUG :=
PRODUCT_VENDOR_PROPERTIES :=
PRODUCT_MANUFACTURER :=
# Remove ro.soc.manufacturer set by gen4_gvm.mk to avoid duplicate with Cuttlefish config
PRODUCT_PROPERTY_OVERRIDES := $(filter-out ro.soc.manufacturer=%,$(PRODUCT_PROPERTY_OVERRIDES))

SOONG_CONFIG_NAMESPACES += wpa_supplicant_8
SOONG_CONFIG_wpa_supplicant_8 += enable_vendor_aidl
SOONG_CONFIG_wpa_supplicant_8_enable_vendor_aidl := false
SOONG_CONFIG_wpa_supplicant_8 += exclude_qca_defaults
SOONG_CONFIG_wpa_supplicant_8_exclude_qca_defaults := true

# Prevent Trusty VM from being enabled by Cuttlefish device.mk (TRUSTY_SYSTEM_VM ?= ...)
TRUSTY_SYSTEM_VM :=

$(call inherit-product, device/google/cuttlefish/vsoc_x86_64_only/auto/aosp_cf.mk)

# Cuttlefish fstab configuration
PRODUCT_COPY_FILES += \
    device/qcom/auto_gen_prime/fstab.cf.f2fs.hctr2:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom \
    device/qcom/auto_gen_prime/fstab.cf.f2fs.hctr2:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.qcom

PRODUCT_COPY_FILES += \
    device/qcom/auto_gen_prime/init.target.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.target.rc

PRODUCT_PRODUCT_PROPERTIES += persist.adb.tcp.port=5555
PRODUCT_VENDOR_PROPERTIES += persist.vendor.usb.config=adb

endif #end of ENABLE_VENDOR_CUTTLEFISH