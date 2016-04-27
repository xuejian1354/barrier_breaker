#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bbevents
PKG_VERSION:=2.0
PKG_RELEASE=2

PKG_MAINTAINER:=Sam Chen <xuejian1354@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)


PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_bbevents

include $(INCLUDE_DIR)/package.mk


define Package/bbevents
  SECTION:=apps
  CATEGORY:=Apps
  SUBMENU:=System
  TITLE:=bbevents
  MAINTAINER:=Sam Chen <xuejian1354@gmail.com>
endef

define Package/bbevents/description
Events daemon progress for coding by users.
endef

define Build/Compile
	$(TARGET_CC) -o $(PKG_BUILD_DIR)/bbevents ./files/bbevents.c
endef

define Package/bbevents/install
    $(INSTALL_DIR) $(1)/usr/local/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bbevents $(1)/usr/local/bin/
	$(INSTALL_BIN) ./files/bbevents.init $(1)/etc/init.d/bbevents
endef

$(eval $(call BuildPackage,bbevents))
