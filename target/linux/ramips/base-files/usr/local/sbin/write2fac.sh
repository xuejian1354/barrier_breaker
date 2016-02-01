#!/bin/ash

export cmd=
export offset=
export size=
export file=
export partition="factory"

usage() {
	cat <<EOF
Usage:	$0 <command> <offset> <size> [<file>]

command:
	write | w	write new mac address to factory partition
	read  | r	read mac address from factory partition

example:
	write factory partition: $0 <write | w> <offset> <size> <file>	
	read factory partition:	 $0 <read  | r> <offset> <size>
EOF
}

[ -z "$1" ] && usage && exit 1
[ $# -lt 3 ] && usage && exit 1

case "$1" in
	write | w)
		export cmd="$1"
		export offset=$2
		export size=$3
		[ -z "$4" ] && exit 1
		export file="$4"
		;;
	read | r)
		export cmd="$1"
		export offset=$2
		export size=$3
		;;
	*) 
		echo "Invalid options: $1"
		exit -2
		;;
esac

find_mtd_index() {
        local part="$(grep "\"$1\"" /proc/mtd | awk -F: '{print $1}')"
        local index="${part##mtd}"
                                 
        echo ${index}                 
}

find_mtd_part() {                                                     
        local index=$(find_mtd_index "$1")
        local prefix=/dev/mtdblock
                                          
        [ -d /dev/mtdblock ] && prefix=/dev/mtdblock/
        echo "${index:+$prefix$index}"                                      
}

[ "$cmd" = "read" ] || [ "$cmd" = "r" ] && {
	eval "dd if=$(find_mtd_part "$partition") bs=1 count=$size skip=$offset 2>/dev/null"

	return $?
}

[ "$cmd" = "write" ] || [ "$cmd" = "w" ] && {
	eval "dd if=$file of=$(find_mtd_part "$partition") bs=1 count=$size skip=$offset 2>/dev/null"

	return $?
}
