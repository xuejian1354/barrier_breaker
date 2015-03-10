#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shome
PKG_VERSION:=2015-03-10
PKG_RELEASE=$(PKG_SOURCE_VERSION)


PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=$(CONFIG_PACKAGE_shome-gitsite)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(CONFIG_PACKAGE_shome-version)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Sam Chen <xuejian1354@gmail.com>


PKG_CONFIG_DEPENDS := \
	CONFIG_PACKAGE_shome-app

include $(INCLUDE_DIR)/package.mk


define Package/shome/Default
  SECTION:=apps
  CATEGORY:=Apps
  SUBMENU:=Smart Home/Application
  URL:=$(TOPDIR)/src
  DEPENDS:=+libstdcpp +libpthread +librt
  MAINTAINER:=Sam Chen <xuejian1354@gmail.com>
endef

define Package/shome-app/config
  source "$(SOURCE)/Config.in"
endef

define Package/shome-app
  $(call Package/shome/Default)
  TITLE:=SHome, Projects for Smart Home Applications
  DEPENDS:= +libsqlite3 +libjsoncpp +pjsip-api \
			+boost-chrono +boost-system \
			+boost-regex +boost-date_time \
			+boost-thread +libopenssl +libuuid
endef

define Package/shome-app/description
SHome app is a program that manage smart home feature function.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	prefix=$(patsubst %uclibc-,%,$(TARGET_CROSS)) \
	FIXFLAGS="-I$(STAGING_DIR)/usr/include/pjsip \
	  -L$(STAGING_DIR)/usr/lib/pjsip -L$(STAGING_DIR)/usr/lib/jsoncpp"
endef

define Build/InstallDev
endef

define Package/shome-app/install
    $(INSTALL_DIR) $(1)/usr/local/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/shome $(1)/usr/local/bin/
endef

$(eval $(call BuildPackage,shome-app))
