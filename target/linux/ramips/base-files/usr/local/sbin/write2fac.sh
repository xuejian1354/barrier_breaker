#!/bin/ash

export mac=
export dir="get"
export help=0
export portition="factory"
export offset="0"
export size=$((64 * 1024))
export tmp_dir="/tmp"

while [ -n "$1" ]; do
	case "$1" in
		set) export dir="$1";mac="$2";shift;;
		get) export dir="$1";break;;
		-h | --help) export help=1;break;;
		-*) 
			echo "Invalid options: $1"
			exit 3
		;;
		*) break;;
	esac
	shift;
done

## help option
[ $help -gt 0 ] && {
	cat <<EOF
Usage:	$0 [<options>] <command> mac_address

command:
	set	write new mac address to factory portition
	get	read mac address from factory portition
EOF
	exit 4
}


[ -f "/lib/functions.sh" ] || {
	echo "Unknow /lib/functions.sh"
	exit 1
}
. /lib/functions.sh

[ -f "/lib/functions/system.sh" ] || {
	echo "Unknow /lib/functions/system.sh"
	exit 2
}
. /lib/functions/system.sh

[ "$dir" = "get" ] && {
	echo $(mtd_get_mac_binary "$portition" "$offset")

	return 0
}

[ "$dir" = "set" ] && {
	export old_tmp_file="${tmp_dir}/old_tmp_file"
	export new_tmp_file="${tmp_dir}/new_tmp_file"

	[ -z "$mac" ] && {
		echo "unknow mac"
		exit 5
	}

	rm -f "${old_tmp_file}"
	rm -f "${new_tmp_file}"
	
	echo -ne "\\x${mac//:/\\x}" >"${new_tmp_file}"
	eval "dd if=$(find_mtd_part "$portition") of=${old_tmp_file} skip=6 bs=1 count=${size} 2>/dev/null"
	cat "${old_tmp_file}" >>"$new_tmp_file"
	rm -f "${old_tmp_file}"
	cat "${new_tmp_file}" >"$(find_mtd_part "$portition")"
	rm -f "${new_tmp_file}"
	cp -f /rom/etc/uci-defaults/02_network /etc/uci-defaults/02_network
	rm -f /etc/config/network

	return 0
}
