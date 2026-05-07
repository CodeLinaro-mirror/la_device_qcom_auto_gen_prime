include device/qcom/gen4_gvm/BoardConfig.mk

ifeq ($(ENABLE_VENDOR_CUTTLEFISH), true)

# vendor sepolicy
BOARD_VENDOR_SEPOLICY_DIRS :=
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/vendor
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/vendor/seriallogging
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/vendor/google

# Remove QTI vendor common sepolicy to avoid duplicate type declarations with Cuttlefish sepolicy
BOARD_SEPOLICY_DIRS := $(filter-out device/qcom/sepolicy_vndr%,$(BOARD_SEPOLICY_DIRS))

# Disable QTI VHAL soong config flags — Cuttlefish provides its own VHAL via APEX
$(call soong_config_set,qti,qti_android_version_above_16,false)
$(call soong_config_set,qti,IS_ANDROID_SHIPPING_W,false)
$(call soong_config_set,qti,enable_qti_vhal,false)

PRODUCT_PRIVATE_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/product/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/system_ext/public

# Override console: gen4_gvm sets hvc0 (virtio); auto_gen_prime uses PL011 UART (ttyAMA0)
BOARD_KERNEL_CMDLINE := $(filter-out console=hvc0%,$(BOARD_KERNEL_CMDLINE))
BOARD_BOOTCONFIG := $(filter-out androidboot.console=hvc0,$(BOARD_BOOTCONFIG))
BOARD_KERNEL_CMDLINE += earlycon=pl011,0x1c090000 console=ttyAMA0
BOARD_BOOTCONFIG += androidboot.console=ttyAMA0

BOARD_KERNEL_CMDLINE += audit=1

# Select APEXes to avoid name conflicts with Cuttlefish-provided APEXes of the same module name
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.keymint=com.android.hardware.keymint.rust_nonsecure
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.graphics.composer=com.android.hardware.graphics.composer.ranchu
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.gatekeeper=com.android.hardware.gatekeeper.nonsecure

# androidboot.hardware=qcom is set in gen4_gvm BOARD_BOOTCONFIG which is never loaded on GVM;
# add to BOARD_KERNEL_CMDLINE so ro.boot.hardware=qcom is set at runtime.
BOARD_KERNEL_CMDLINE += androidboot.hardware=qcom

# Cuttlefish graphics: minigbm gralloc + ranchu HWComposer
BOARD_KERNEL_CMDLINE += androidboot.hardware.gralloc=minigbm
BOARD_KERNEL_CMDLINE += androidboot.hardware.hwcomposer=ranchu
BOARD_KERNEL_CMDLINE += androidboot.hardware.hwcomposer.mode=client
BOARD_KERNEL_CMDLINE += androidboot.hardware.hwcomposer.display_finder_mode=drm

# Cuttlefish Vehicle HAL proxy server port (VehicleService reads ro.boot.vhal_proxy_server_port)
BOARD_KERNEL_CMDLINE += androidboot.vhal_proxy_server_port=9300

endif #end of ENABLE_VENDOR_CUTTLEFISH
