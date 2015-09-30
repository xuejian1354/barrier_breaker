#!/bin/sh
#
# by lintel@gmail.com, hoowa.sun@gmail.com
#

append DRIVERS "rt2860v2"

prepare_config() {
#获取参数 存储配置的变量 目标配置关键字

	local num=0 mode disabled
	
#准备产生RaX的无线配置: rt2860v2
	local device=$1

#获取当前的无线频道 "auto"
	config_get channel $device channel

#获取当前的802.11无线模式: sta
	config_get hwmode $device mode
	
#获取WMM支持: ""
	config_get wmm $device wmm
	
#获取设备的传输功率: 100
	config_get txpower $device txpower
	
#获取设备的HT（频宽）: '20+40'
	config_get ht $device ht

#获取国家代码: CN	
	config_get country $device country
	
#是否有MAC过滤: ""
	config_get macpolicy $device macpolicy

#MAC地址过滤列表: ""
	config_get maclist $device maclist
#字符格式转义: ""
	ra_maclist="${maclist// /;};"
#是否支持GREEN AP功能:greenap: 0, antdiv: "", frag: 2346
	config_get_bool greenap $device greenap 0

	config_get_bool antdiv "$device" diversity
	
	config_get frag "$device" frag 2346
	
	config_get rts "$device" rts 2347
	
	config_get distance "$device" distance

	config_get hidessid "$device" hidden 0
	
#获取该Radio下面的虚拟接口	
	config_get vifs "$device" vifs
	
#获取虚拟接口的数量，并提前配置SSID
for vif in $vifs; do
	let num+=1
	config_get_bool disabled "$vif" disabled 0
	config_get mode "$vif" mode 0
	
	#如果某个SSID接口需要隐藏，则所有的接口都隐藏
	[ "$hidessid" == "0" ] && {
	config_get hidessid $vif hidden 0
	}
	
	#已经关闭的接口以及sta模式的排除在外。
	[ "$mode" = "sta" ]&& {
	let num-=1 
	continue
	}
	[ "$disabled" == "1" ]&& {
	let num-=1
	continue
	}
	
	case $num in
	1)
		config_get ssid1 "$vif" ssid
		;;
	2)
		config_get ssid2 "$vif" ssid
		;;
	3)
		config_get ssid3 "$vif" ssid
		;;
	4)
		config_get ssid4 "$vif" ssid
		;;
	*)
		;;
	esac
done

#开始准备HT模式配置，注意HT模式仅在11N下有效。
	HT=1
	HT_CE=1

    if [ "$ht" = "20" ]; then
      HT=0 
    elif [ "$ht" = "20+40" ]; then
      HT=1 
      HT_CE=1
    elif [ "$ht" = "40" ] ; then
      HT=1 
      HT_CE=0
    else
    echo "ht config has some problem!use default!!!"
      HT=0
      HT_CE=1
    fi


	# 在HT40模式下,需要另外的一个频道，如果EXTCHA=0,则当前第二频道为$channel + 4.
	# 如果EXTCHA=1,则当前的第二频道为$channel - 4.
	# 如果当前频道被限制在1-4,则是当前频道+ 4，若否，则为当前频道-4 
	
	EXTCHA=1
	
	[ "$channel" != auto ] && [ "$channel" -lt "5" ] && EXTCHA=1

#配置自动选择无线频道
    [ "$channel" == "auto" ] && {
        channel=11
        AutoChannelSelect=2
    }

#开始判断WiFi的MAC过滤方式.
    case "$macpolicy" in
	allow|2)
	ra_macfilter=1;
	;;
	deny|1)
	ra_macfilter=2;
	;;
	*|disable|none|0)
	ra_macfilter=0;
	;;
    esac

	cat > /tmp/RT2860.dat<<EOF
#The word of "Default" must not be removed
Default
CountryRegion=5
CountryRegionABand=7
CountryCode=
ChannelGeography=1
SSID=Dennis2860AP
NetworkType=Infra
WirelessMode=9
Channel=0
BeaconPeriod=100
TxPower=100
BGProtection=0
TxPreamble=0
RTSThreshold=2347
FragThreshold=2346
TxBurst=1
PktAggregate=0
WmmCapable=1
AckPolicy=0;0;0;0
AuthMode=OPEN
EncrypType=NONE
WPAPSK=
DefaultKeyID=1
Key1Type=0
Key1Str=
Key2Type=0
Key2Str=
Key3Type=0
Key3Str=
Key4Type=0
Key4Str=
PSMode=CAM
AutoRoaming=0
RoamThreshold=70
APSDCapable=0
APSDAC=0;0;0;0
HT_RDG=1
HT_EXTCHA=0
HT_OpMode=0
HT_MpduDensity=4
HT_BW=1
HT_AutoBA=1
HT_BADecline=0
HT_AMSDU=0
HT_BAWinSize=64
HT_GI=1
HT_MCS=33
HT_MIMOPSMode=3
HT_DisallowTKIP=1
HT_STBC=0
EthConvertMode=
EthCloneMac=
IEEE80211H=0
TGnWifiTest=0
WirelessEvent=0
MeshId=MESH
MeshAutoLink=1
MeshAuthMode=OPEN
MeshEncrypType=NONE
MeshWPAKEY=
MeshDefaultkey=1
MeshWEPKEY=
CarrierDetect=0
AntDiversity=0
BeaconLostTime=4
FtSupport=0
Wapiifname=ra0
WapiPsk=
WapiPskType=
WapiUserCertPath=
WapiAsCertPath=
PSP_XLINK_MODE=0
WscManufacturer=
WscModelName=
WscDeviceName=
WscModelNumber=
WscSerialNumber=
RadioOn=1
WIDIEnable=1
P2P_L2SD_SCAN_TOGGLE=3
Wsc4digitPinCode=0
P2P_WIDIEnable=0
PMFMFPC=0
PMFMFPR=0
PMFSHA256=0
EOF

}

reload_rt2860v2() {
	local mod="rt2860v2_ap"

	[ -f "/lib/modules/$(uname -r)/rt2860v2_sta.ko" ] && {
		mod=rt2860v2_sta
	}

	ifconfig ra0 down
	rmmod ${mod}

	insmod ${mod}
	ifconfig ra0 up
}

scan_rt2860v2() {
	local device="$1"
}

disable_rt2860v2() {
	local device="$1"
	set_wifi_down $device
	ifconfig $device down
	true
}

rt2860v2_start_vif() {
	local vif="$1"
	local ifname="$2"

	local net_cfg
	net_cfg="$(find_net_config "$vif")"
	[ -z "$net_cfg" ] || start_net "$ifname" "$net_cfg"

	set_wifi_up "$vif" "$ifname"
}

enable_rt2860v2() {
#传参过来的第一个参数是Radio0
	local device="$1" dmode if_num=0;
	
	config_get_bool disabled "$device" disabled 0	
	if [ "$disabled" = "1" ] ;then
	ifconfig ra0 down
	return
	fi
	
	#开始准备该设备的无线配置参数
	prepare_config $device
	
	config_get dmode $device mode
	config_get vifs "$device" vifs

	config_get maxassoc $device maxassoc 0

	for vif in $vifs; do
		local ifname encryption key ssid mode
		
		config_get ifname $vif device	
		
		#根据ifname数量配置多SSID
		[ "$ifname" == "ra0" ] && {
		ifname="ra$if_num"
		}
		let if_num+=1
		#排除如果设置为apcli0
		[ "$mode" = "sta" ]&& {let if_num-=1}
		
		config_get_bool disabled $vif disabled 0
		if [ "$disabled" = "1" ] ;then
		set_wifi_down $ifname
		echo "Interface $ifname disabled"
		return
		fi
		config_get encryption $vif encryption
		config_get key $vif key
		config_get ssid $vif ssid
		config_get mode $vif mode
		config_get wps $vif wps
		#是否隔离客户端
		config_get isolate $vif isolate 0
		#802.11h
		config_get doth $vif doth 0
		#是否隐藏SSID
#		config_get hidessid $vif hidden 0

		#STA APClient配置
		[ "$mode" == "sta" ] && {
					#如果为apcli模式，指定接口名称为apcli0
					echo "#Encryption" >/tmp/wifi_encryption_${ifname}.dat
					ifconfig $ifname down
					iwpriv $ifname set Enable=0
					iwpriv $ifname set SSID=$ssid
					config_get bssid $vif bssid 0
					[ -z "$mode" ] && {
					iwpriv $ifname set BSSID=$bssid
					echo "APCli use bssid connect."
					}
			case "$encryption" in
				none)
					echo "NONE" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=OPEN
					iwpriv $ifname set EncrypType=NONE 
					;;
				WEP|wep|wep-open)
					echo "WEP" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=WEPAUTO
					iwpriv $ifname set ApCliEncrypType=WEP
					iwpriv $ifname set Key0=${key}
					;;
				WEP-SHARE|wep-shared)
					echo "WEP" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=WEPAUTO
					iwpriv $ifname set ApCliEncrypType=WEP
					iwpriv $ifname set Key0=${key}
					;;
				WPA*|wpa*|WPA2-PSK|psk*)
					echo "WPA2" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=WPA2PSK
					iwpriv $ifname set EncrypType=AES
					iwpriv $ifname set WPAPSK=$key
					echo "WPAPSKWPA2PSK" >>/tmp/wifi_encryption_${ifname}.dat
					echo "TKIPAES" >>/tmp/wifi_encryption_${ifname}.dat
					;;
			esac
					iwpriv $ifname set ApCliEnable=1
					ifconfig $ifname up
		}
		#AP模式配置
		[ "$mode" == "ap" ] || {
			[ "$key" = "" -a "$vif" = "private" ] && {
				logger "no key set serial"
				key="AAAAAAAAAA"
			}
			[ "$dmode" == "6" ] && wpa_crypto="aes"
			ifconfig $ifname up
			#判断当前加密模式
			echo "#Encryption" >/tmp/wifi_encryption_${ifname}.dat
			iwpriv $ifname set "SSID=${ssid}"
			case "$encryption" in
				#找到WPA/WPA2加密
				wpa*|psk*|WPA*|Mixed|mixed)
					echo "WPA" >>/tmp/wifi_encryption_${ifname}.dat
					local enc
					case "$encryption" in
						Mixed|mixed|psk+psk2)
							enc=WPAPSKWPA2PSK
							;;
						WPA2*|wpa2*|psk2*)
							enc=WPA2PSK
							;;
						WPA*|WPA1*|wpa*|wpa1*|psk*)
							enc=WPAPSK
							;;
					esac
					local crypto="AES"
					case "$encryption" in
					*tkip+aes*|*tkip+ccmp*|*aes+tkip*|*ccmp+tkip*)
						crypto="TKIPAES"
						;;
					*aes*|*ccmp*)
						crypto="AES"
						;;
					*tkip*) 
						crypto="TKIP"
						echo Warring!!! TKIP not support in 802.11n 40Mhz!!!
					;;
					esac
					echo "$enc" >>/tmp/wifi_encryption_${ifname}.dat
					echo "$crypto" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=$enc
					iwpriv $ifname set EncrypType=$crypto
					iwpriv $ifname set IEEE8021X=0
					iwpriv $ifname set "SSID=${ssid}"
					iwpriv $ifname set "WPAPSK=${key}"
					iwpriv $ifname set DefaultKeyID=2
					iwpriv $ifname set "SSID=${ssid}"
						
					if [ "DefaultKeyID=2$wps" == "1" ]; then
						iw"SSID=${ssid}"priv $ifname set WscConfMode=7
					else
						iwpriv $ifname set WscConfMode=0
					fi
					;;
				WEP|wep|wep-open|wep-shared)
					echo "WEP" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=WEPAUTO
					iwpriv $ifname set EncrypType=WEP
					iwpriv $ifname set IEEE8021X=0
					for idx in 1 2 3 4; do
						config_get keyn $vif key${idx}
						[ -n "$keyn" ] && iwpriv $ifname set "Key${idx}=${keyn}"
					done
					iwpriv $ifname set DefaultKeyID=${key}
					iwpriv $ifname set "SSID=${ssid}"
					echo 
					iwpriv $ifname set WscConfMode=0
					;;
				none|open)
					echo "NONE" >>/tmp/wifi_encryption_${ifname}.dat
					iwpriv $ifname set AuthMode=OPEN
					iwpriv $ifname set WscConfMode=0
					iwpriv $ifname set EncrypType=NONE
					;;
			esac
		}
		
		#如果关闭了WIFI，则关闭RF
		if [ $disabled == 1 ]; then
		 iwpriv $ifname set On=0
		 set_wifi_down $ifname
		else
		 iwpriv $ifname set RadioOn=1
			iwpriv $ifname set On=1
		fi

		#检查是否需要进行SSID隐藏。
#		if [ $hidessid == "1" ]; then
#		 iwpriv $ifname set HideSSID=1
#		else
#		 iwpriv $ifname set HideSSID=0
#		fi

		#隔离客户端连接。
		[ $isolate == "1" ]&&{
			iwpriv $ifname set NoForwarding=1
		}
		
		#802.11h 支持
		[ $doth == "1" ]&&{
			iwpriv $ifname set IEEE80211H=1
		}	
		
		ifconfig "$ifname" up
		if [ "$mode" == "sta" ];then {
			net_cfg="$(find_net_config "$vif")"
			[ -z "$net_cfg" ] || {
					rt2860v2_start_vif "$vif" "$ifname"

			}
		}
		else
		{
			local net_cfg bridge
			net_cfg="$(find_net_config "$vif")"
			[ -z "$net_cfg" ]||{
				bridge="$(bridge_interface "$net_cfg")"
				config_set "$vif" bridge "$bridge"
				rt2860v2_start_vif "$vif" "$ifname"
				#Fix bridge problem
				[ -z `brctl show |grep $ifname` ] && {
				brctl addif $(bridge_interface "$net_cfg") $ifname
				}
				
			}



		}
		fi;
		set_wifi_up "$vif" "$ifname"

		# If isolation is requested, disable forwarding between
		# wireless clients (both within the same BSSID and
		# between BSSID's, though the latter is probably not
		# relevant for our setup).
		
#		iwpriv $ifname set NoForwarding="${isolate:-0}"
#		iwpriv $ifname set NoForwardingBTNBSSID="${isolate:-0}"

	done
	
	#配置无线最大连接数
	iwpriv $device set MaxStaNum=$maxassoc
}

first_enable() {

ifconfig ra0 down

	cat > /tmp/RT2860.dat<<EOF
#The word of "Default" must not be removed
Default
CountryRegion=5
CountryRegionABand=7
CountryCode=
ChannelGeography=1
SSID=Dennis2860AP
NetworkType=Infra
WirelessMode=9
Channel=0
BeaconPeriod=100
TxPower=100
BGProtection=0
TxPreamble=0
RTSThreshold=2347
FragThreshold=2346
TxBurst=1
PktAggregate=0
WmmCapable=1
AckPolicy=0;0;0;0
AuthMode=OPEN
EncrypType=NONE
WPAPSK=
DefaultKeyID=1
Key1Type=0
Key1Str=
Key2Type=0
Key2Str=
Key3Type=0
Key3Str=
Key4Type=0
Key4Str=
PSMode=CAM
AutoRoaming=0
RoamThreshold=70
APSDCapable=0
APSDAC=0;0;0;0
HT_RDG=1
HT_EXTCHA=0
HT_OpMode=0
HT_MpduDensity=4
HT_BW=1
HT_AutoBA=1
HT_BADecline=0
HT_AMSDU=0
HT_BAWinSize=64
HT_GI=1
HT_MCS=33
HT_MIMOPSMode=3
HT_DisallowTKIP=1
HT_STBC=0
EthConvertMode=
EthCloneMac=
IEEE80211H=0
TGnWifiTest=0
WirelessEvent=0
MeshId=MESH
MeshAutoLink=1
MeshAuthMode=OPEN
MeshEncrypType=NONE
MeshWPAKEY=
MeshDefaultkey=1
MeshWEPKEY=
CarrierDetect=0
AntDiversity=0
BeaconLostTime=4
FtSupport=0
Wapiifname=ra0
WapiPsk=
WapiPskType=
WapiUserCertPath=
WapiAsCertPath=
PSP_XLINK_MODE=0
WscManufacturer=
WscModelName=
WscDeviceName=
WscModelNumber=
WscSerialNumber=
RadioOn=1
WIDIEnable=1
P2P_L2SD_SCAN_TOGGLE=3
Wsc4digitPinCode=0
P2P_WIDIEnable=0
PMFMFPC=0
PMFMFPR=0
PMFSHA256=0
EOF

ifconfig ra0 up
}

#detect_rt2860v2函数用于检测是否存在驱动
detect_rt2860v2() {
	local i=-1
#判断系统是否存在rt2860v2_sta，不存在则退出
	cd /sys/module/
	[ -d rt2860v2_ap ] || return
#检测系统存在多少个wifi接口
	while grep -qs "^ *ra$((++i)):" /proc/net/dev; do
		config_get type ra${i} type
		[ "$type" = rt2860v2 ] && continue
		
#检查并创建WiFi驱动配置链接
	[ -f /etc/Wireless/RT2860/RT2860.dat ] || {
	mkdir -p /etc/Wireless/RT2860/
	ln -s /tmp/RT2860.dat /etc/Wireless/RT2860/RT2860.dat
	}
	
	first_enable
	
		cat <<EOF
config wifi-device  ra${i}
	option type     rt2860v2
	option mode 	9
	option channel  auto
	option txpower 100
	option ht 20+40
    option country CN
# REMOVE THIS LINE TO ENABLE WIFI:
	option disabled 0	
	
config wifi-iface
	option device   ra${i}
	option network	lan
	option mode     ap
	option ssid     LYSOC${i#0}_$(cat /sys/class/net/ra${i}/address|awk -F ":" '{print $4""$5""$6 }'| tr a-z A-Z)AP
	option encryption 'psk2'
	option key '12345678'
EOF

	ifconfig ra0 down 
	done
	
}


