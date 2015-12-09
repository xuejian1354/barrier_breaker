#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartlab
PKG_VERSION:=2015-12-09
PKG_RELEASE=$(PKG_SOURCE_VERSION)


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=$(CONFIG_PACKAGE_smartlab-gitsite)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(CONFIG_PACKAGE_smartlab-version)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Sam Chen <xuejian1354@163.com>


PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_smartlab

include $(INCLUDE_DIR)/package.mk

define Package/smartlab/config
	source "$(SOURCE)/Config.in"
endef

define Package/smartlab
  SECTION:=apps
  CATEGORY:=Apps
  SUBMENU:=Smart Home/Application
  URL:=$(TOPDIR)/src
  MAINTAINER:=Sam Chen <xuejian1354@163.com>
  TITLE:=SmartLab, Projects for Smart Room Applications
  DEPENDS:=+libpthread +librt +libcurl +libxml2 +libsqlite3
endef

define Package/smartlab/description
SmartLab app is a program that manage smart room feature function.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) smartlab cprefix=$(TARGET_CROSS)
	$(MAKE) -C $(PKG_BUILD_DIR)/tests deulog prefix=$(TARGET_CROSS)
endef

define Build/InstallDev
endef

define Package/smartlab/install
    $(INSTALL_DIR) $(1)/usr/local/bin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/smartlab $(1)/usr/local/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tests/balance_serlist $(1)/etc/balance_serlist
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tests/transconn.conf $(1)/etc/transconn.conf
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tests/deulog $(1)/usr/local/bin/
	$(INSTALL_BIN) ./files/smartlab.init $(1)/etc/init.d/smartlab
endef

$(eval $(call BuildPackage,smartlab))
