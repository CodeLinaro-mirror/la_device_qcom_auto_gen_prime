LOCAL_PATH := $(call my-dir)

# Inherit gen4_gvm board configuration.
# This provides MergeConfig.mk, generate_extra_images.mk,
# AndroidBoardCommon.mk and all other board-level setup.
include device/qcom/gen4_gvm/AndroidBoard.mk
