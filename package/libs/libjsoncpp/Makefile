#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jsoncpp
PKG_VERSION:=2015-01-06
PKG_RELEASE:=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/open-source-parsers/jsoncpp.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=6eaf150dc7d1b6c84b209d522190618c4e7c73ff
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MAINTAINER:=Christopher Dunn <cdunn2001@gmail.com>


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libjsoncpp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=javascript object notation
  DEPENDS= +libstdcpp
endef

define Package/libjsoncpp/description
 This package contains a library for javascript object notation backends.
endef

CMAKE_OPTIONS += \
	-DJSONCPP_LIB_BUILD_SHARED=OFF \
	-DJSONCPP_WITH_TESTS=OFF


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/jsoncpp
	$(CP) $(PKG_INSTALL_DIR)/usr/include/json/* $(1)/usr/include/jsoncpp
	$(INSTALL_DIR) $(1)/usr/lib/jsoncpp
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjsoncpp.* $(1)/usr/lib/jsoncpp
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/jsoncpp.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libjsoncpp))
