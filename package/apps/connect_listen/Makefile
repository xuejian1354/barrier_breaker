#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=connect_listen
PKG_VERSION:=2015-02-26
PKG_RELEASE=$(PKG_SOURCE_VERSION)


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=$(CONFIG_PACKAGE_connect-listen-gitsite)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(CONFIG_PACKAGE_connect-listen-version)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Sam Chen <xuejian1354@gmail.com>


PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_connect-listen

include $(INCLUDE_DIR)/package.mk


define Package/connector/Default
  SECTION:=apps
  CATEGORY:=Apps
  SUBMENU:=Smart Home/Application
  URL:=$(TOPDIR)/src
  DEPENDS:=+libpthread +librt
  MAINTAINER:=Sam Chen <xuejian1354@gmail.com>
endef

define Package/connect-listen/config
	source "$(SOURCE)/Config.in"
endef

define Package/connect-listen
  $(call Package/connector/Default)
  TITLE:=Connector, Projects for Smart Home Applications
  DEPENDS:= +libsqlite3
endef

define Package/connect-listen/description
Connector app is a program that manage smart home feature function.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) all prefix=$(TARGET_CROSS)
endef

define Build/InstallDev
endef

define Package/connect-listen/install
    $(INSTALL_DIR) $(1)/usr/local/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/connect_listen $(1)/usr/local/bin/
endef

$(eval $(call BuildPackage,connect-listen))
