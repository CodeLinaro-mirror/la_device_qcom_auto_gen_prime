include device/qcom/gen4_gvm/BoardConfig.mk

ifeq ($(ENABLE_VENDOR_CUTTLEFISH), true)

# Remove SEPolicy added by Gen GVM. It clashes with the Cuttlefish SEPolicy below.
BOARD_SEPOLICY_DIRS := $(filter-out device/qcom/sepolicy%,$(BOARD_SEPOLICY_DIRS))
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS := $(filter-out device/qcom/sepolicy%,$(SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS))
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS := $(filter-out device/qcom/sepolicy%,$(SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS))
PRODUCT_PUBLIC_SEPOLICY_DIRS := $(filter-out device/qcom/sepolicy%,$(PRODUCT_PUBLIC_SEPOLICY_DIRS))
PRODUCT_PRIVATE_SEPOLICY_DIRS := $(filter-out device/qcom/sepolicy%,$(PRODUCT_PRIVATE_SEPOLICY_DIRS))
BOARD_SYSTEM_EXT_SEPOLICY_PREBUILT_DIRS := $(filter-out device/qcom/sepolicy%,$(BOARD_SYSTEM_EXT_SEPOLICY_PREBUILT_DIRS))
BOARD_PRODUCT_SEPOLICY_PREBUILT_DIRS := $(filter-out device/qcom/sepolicy%,$(BOARD_PRODUCT_SEPOLICY_PREBUILT_DIRS))

# Add Cuttlefish SEPolicy.
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/graphics/sepolicy
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/vendor
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/vendor/seriallogging
BOARD_VENDOR_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/vendor/google
PRODUCT_PRIVATE_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/product/private
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += device/google/cuttlefish/shared/sepolicy/system_ext/private

# Add auto_gen_prime SEPolicy.
BOARD_VENDOR_SEPOLICY_DIRS += device/qcom/sepolicy_vndr/generic/vendor/auto_gen_prime

# Explicitly specify all required kernel modules. Vendor ramdisk modules and
# DLKM modules are normally picked automatically based on their kernel prebuilt
# location. However, LA Prime and Gen GVM use different subsets of modules
# provided by autogvm, therefore:
#  * Gen GVM picks all modules and uses the default blocklist to avoid loading
#    unneeded modules.
#  * LA Prime picks only required modules and uses the generated load lists for
#    the selected ramdisk, vendor_dlkm and system_dlkm modules.

BOARD_VENDOR_RAMDISK_KERNEL_MODULES := \
    device/qcom/auto_gen-kernel/virtio_mmio.ko \
    device/qcom/auto_gen-kernel/virtio_console.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/virtio_pci.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/virtio_pci_legacy_dev.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/virtio_pci_modern_dev.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/virtio_blk.ko \
    device/qcom/auto_gen-kernel/failover.ko \
    device/qcom/auto_gen-kernel/net_failover.ko \
    device/qcom/auto_gen-kernel/virtio_net.ko \
    device/qcom/auto_gen-kernel/rename_devices.ko \
    device/qcom/auto_gen-kernel/i2c-virtio.ko

BOARD_VENDOR_KERNEL_MODULES := \
    device/qcom/auto_gen-kernel/vendor_dlkm/virtio_dma_buf.ko \
    device/qcom/auto_gen-kernel/vendor_dlkm/virtio-gpu.ko \
    device/qcom/auto_gen-kernel/vendor_dlkm/virtio_snd.ko \
    device/qcom/auto_gen-kernel/vendor_dlkm/virtio_input.ko \
    device/qcom/auto_gen-kernel/vendor_dlkm/virtio-rng.ko \
    device/qcom/auto_gen-kernel/vendor_dlkm/gpio-virtio.ko

BOARD_SYSTEM_KERNEL_MODULES := \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/vmw_vsock_virtio_transport.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/can-dev.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/ptp.ko \
    device/qcom/auto_gen-kernel/system_dlkm/flatten/lib/modules/pps_core.ko

# Filter out kernel modules that don't exist yet — kernel must be built first.
# Once the kernel is built, $(wildcard ...) will pick them up automatically.

# BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD is set by kernel-platform-board.mk and must be adjusted.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES)
# The variable must be set in order to generate non-empty modules.load.
BOARD_SYSTEM_KERNEL_MODULES := $(wildcard $(BOARD_SYSTEM_KERNEL_MODULES))
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(BOARD_SYSTEM_KERNEL_MODULES)
# The variable must remain unset in order to properly generate modules.load.
BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(BOARD_VENDOR_KERNEL_MODULES))

# Modules that are built as PRODUCT_PACKAGES must be added after the filtering.

# QC VirtIO modules.
-include vendor/qcom/defs/board-defs/vendor/virtio_can_board.mk
-include vendor/qcom/defs/board-defs/vendor/virtio_spi_board.mk
-include vendor/qcom/defs/board-defs/vendor/virtio_rtc_board.mk
-include vendor/qcom/defs/board-defs/vendor/virtio_usb_board.mk

# Disable QTI VHAL soong config flags — Cuttlefish provides its own VHAL via APEX
$(call soong_config_set,qti,qti_android_version_above_16,false)
$(call soong_config_set,qti,IS_ANDROID_SHIPPING_W,false)
$(call soong_config_set,qti,enable_qti_vhal,false)

# Build QC VirtIO graphics modules only for LA Prime.
$(call soong_config_set,qcvirtio_graphics,enabled,true)

# Set the state to "orange" to be able to boot on HGY.
# Must be added to BOARD_KERNEL_CMDLINE to have any effect.
BOARD_KERNEL_CMDLINE += androidboot.verifiedbootstate=orange

# Remove console from BOARD_KERNEL_CMDLINE because GVM does not boot on HGY.
# Delete this workaround once proper fix is ready.
# The console is still hvc0: set via andoidboot.console in the included Gen BoardConfig.
BOARD_KERNEL_CMDLINE := $(filter-out console=hvc0%,$(BOARD_KERNEL_CMDLINE))

BOARD_KERNEL_CMDLINE += audit=1

# Select APEXes to avoid name conflicts with Cuttlefish-provided APEXes of the same module name
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.keymint=com.android.hardware.keymint.rust_nonsecure
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.graphics.composer=com.android.hardware.graphics.composer.drm_hwcomposer
BOARD_BOOTCONFIG += androidboot.vendor.apex.com.android.hardware.gatekeeper=com.android.hardware.gatekeeper.nonsecure

# androidboot.hardware=qcom is inherited from gen4_gvm BOARD_BOOTCONFIG.
# Keep it out of BOARD_KERNEL_CMDLINE so first-stage init has a single source.

# Cuttlefish graphics: minigbm gralloc + DRM HWComposer + Mesa3D.
BOARD_BOOTCONFIG += androidboot.hardware.egl=mesa
BOARD_BOOTCONFIG += androidboot.hardware.gralloc=minigbm
BOARD_BOOTCONFIG += androidboot.hardware.hwcomposer=drm_minigbm
BOARD_BOOTCONFIG += androidboot.hardware.hwcomposer.mode=client
BOARD_BOOTCONFIG += androidboot.hardware.hwcomposer.display_finder_mode=drm

# Cuttlefish Vehicle HAL proxy server port (VehicleService reads ro.boot.vhal_proxy_server_port)
BOARD_KERNEL_CMDLINE += androidboot.vhal_proxy_server_port=9300

endif #end of ENABLE_VENDOR_CUTTLEFISH
