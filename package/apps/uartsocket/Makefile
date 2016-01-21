#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=uartsocket
PKG_VERSION:=2015-01-21
PKG_RELEASE=$(PKG_SOURCE_VERSION)


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=$(CONFIG_PACKAGE_uartsocket-gitsite)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(CONFIG_PACKAGE_uartsocket-version)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Sam Chen <xuejian1354@163.com>


PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_uartsocket

include $(INCLUDE_DIR)/package.mk

define Package/uartsocket/config
	source "$(SOURCE)/Config.in"
endef

define Package/uartsocket
  SECTION:=apps
  CATEGORY:=Apps
  SUBMENU:=Service/Application
  URL:=$(TOPDIR)/src
  MAINTAINER:=Sam Chen <xuejian1354@163.com>
  TITLE:=UartSocket Service
  DEPENDS:=+libpthread
endef

define Package/uartsocket/description
UartSocket Service
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) prefix=$(TARGET_CROSS)
endef

define Build/InstallDev
endef

define Package/uartsocket/install
    $(INSTALL_DIR) $(1)/usr/local/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uartsocket $(1)/usr/local/bin/
	$(INSTALL_BIN) ./files/uartsocket.init $(1)/etc/init.d/uartsocket
endef

$(eval $(call BuildPackage,uartsocket))
