# hybrid.sh by DiamondBond, Deic & Hoholee12

#NOTES (Sign off please)

#Master version
ver_revision="2.2"

#options
initd=`if [ -d $initd_dir ]; then echo 1; else echo 0; fi`
perm=`getprop persist.hybrid.permanent`
catalyst_time=`getprop persist.hybrid.catalyst.time`

#symlinks
tmp_dir="/data/local/tmp/"
initd_dir="/system/etc/init.d/"

#color control
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'
white='\033[0;97m'

#formatting control
bld='\033[0;1m'
blnk='\033[0;5m'
nc='\033[0m'

#code snippets from standard.sh by hoholee12
readonly version=test
readonly BASE_NAME=$(basename $0)
readonly NO_EXTENSION=$(echo $BASE_NAME | sed 's/\..*//')
readonly backup_PATH=$PATH
readonly set_PATH=$(dirname $0 | sed 's/^\.//')
readonly set_PATH2=$(pwd)
if [[ "$set_PATH" ]]; then
	if [[ "$(ls / | grep $(echo $set_PATH | sed 's/\//\n/g' | head -n2 | sed ':a;N;s/\n//g;ba'))" ]] ; then
		export PATH=$set_PATH:$PATH
	else
		export PATH=$set_PATH2:$PATH
	fi
else
	export PATH=$set_PATH2:$PATH
fi
reg_name=$(which $BASE_NAME 2>/dev/null) # somewhat seems to be incompatible with 1.22.1-stericson.
if [[ ! "$reg_name" ]]; then
	echo "you are not running this program in proper location. this may cause trouble for codes that use this function: DIR_NAME"
	readonly DIR_NAME="NULL" #'NULL' will go out instead of an actual directory name
else
	readonly DIR_NAME=$(dirname $reg_name | sed 's/^\.//')
fi
export PATH=$backup_PATH # revert back to default
readonly FULL_NAME=$(echo $DIR_NAME/$BASE_NAME)
print_PARTIAL_DIR_NAME(){
	echo $(echo $DIR_NAME | sed 's/\//\n/g' | head -n$(($1+1)) | sed ':a;N;s/\n/\//g;ba')
}
readonly ROOT_DIR=$(print_PARTIAL_DIR_NAME 1)
error(){
	message=$@
	if [[ "$(echo $message | grep \")" ]]; then
		echo -n $message | sed 's/".*//'
		errmsg=$(echo $message | cut -d'"' -f2)
		echo -e "\e[1;31m\"$errmsg\"\e[0m"
	else
		echo $message
	fi
	CUSTOM_DIR=$(echo $CUSTOM_DIR | sed 's/\/$//')
	cd /
	for i in $(echo $CUSTOM_DIR | sed 's/\//\n/g'); do
		if [[ ! -d $i ]]; then
			mkdir $i
			chmod 755 $i
		fi
		cd $i
	done
	if [[ "$CUSTOM_DIR" ]]; then
		date '+date: %m/%d/%y%ttime: %H:%M:%S ->'"$message"'' >> $CUSTOM_DIR/$NO_EXTENSION.log
	else
		date '+date: %m/%d/%y%ttime: %H:%M:%S ->'"$message"'' >> $DIR_NAME/$NO_EXTENSION.log
	fi
}
# Use /dev/urandom for print_RANDOM_BYTE.
use_urand=1
# invert print_RANDOM_BYTE.
invert_rand=1

print_RANDOM_BYTE(){
	if [[ "$BASH" ]]&&[[ "$RANDOM" ]]; then
		echo $RANDOM
	else
		bb_apg_2 -f od
		if [[ "$?" == 1 ]]; then
			error critical command missing. \"error code 2\"
			exit 2
		fi
		if [[ "$use_urand" != 1 ]]; then
			rand=$(($(od -An -N2 -i /dev/random)%32767))
		else
			rand=$(($(od -An -N2 -i /dev/urandom)%32767))
		fi
		if [[ "$invert_rand" == 1 ]]; then
			if [[ "$rand" -lt 0 ]]; then
				rand=$(($((rand*-1))-1))
			fi
		fi
		echo $rand #output
	fi
}

# Checkers 1.0
# You can type in any strings you would want it to print when called.
# It will start by checking from chk1, and its limit is up to chk20.
chk1="what?"
chk2="i dont understand!"
chk3="pardon?"
chk4="are you retarded?"
checkers(){
	for i in $(seq 1 20); do
		if [[ ! "$(eval echo \$chk$i)" ]]; then
			i=$((i-1))
			break
		fi
	done
	random=$(print_RANDOM_BYTE)
	random=$((random%i+1))
	echo -n -e "\r$(eval echo \$chk$random) "
}
debug_shell(){
	echo "welcome to the debug_shell program! type in: 'help' for more information."
	echo  -e -n "\e[1;32mdebug-\e[1;33m$version\e[0m"
	if [[ "$su_check" == 0 ]]; then
		echo -n '# '
	else
		echo -n '$ '
	fi
	while eval read i; do
		case $i in
			randtest | test9) #test9 version.
				trap "echo -e \"\e[2JI LOVE YOU\"; exit" 2
				while true; do
					random=$(print_RANDOM_BYTE)
					x_axis=$((random%$(($(stty size | awk '{print $2}' 2>/dev/null)-1))))
					random=$(print_RANDOM_BYTE)
					y_axis=$((random%$(stty size | awk '{print $1}' 2>/dev/null)))
					random=$(print_RANDOM_BYTE)
					color=$((random%7+31))
					echo -e -n "\e[${y_axis};${x_axis}H\e[${color}m0\e[0m"
				done
			;;
			help)
				echo -e "this debug shell is \e[1;31mONLY\e[0m used for testing conditions inside this program!
you can now use '>' and '>>' for output redirection. use along with 'set -x' for debugging purposes.
use 'export' if you want to declare a variable.
such includes:
	-functions
	-variables
	-built-in sh or bash commands

instead, you can use these commands built-in to this program:
	-print_PARTIAL_DIR_NAME
	-print_RANDOM_BYTE
	-bb_apg_2
	-as_root
	-any other functions built-in to this program...
you can use set command to view all the functions and variables built-in to this program.

you can also use these built-in commands in debug_shell:
	-randtest (tests if print_RANDOM_BYTE is functioning properly)
	-help (brings out this message)

debug_shell \e[1;33mv$version\e[0m
Copyright (C) 2013-2015 hoholee12@naver.com"
			;;
			return*)
				exit
			;;
			*)
				if [[ "$(echo $i | grep '>')" ]]; then
					if [[ "$(echo $i | grep '>>')" ]]; then
						i=$(echo $i | sed 's/>>/>/')
						if [[ "$(echo $i | cut -d'>' -f1)" ]]; then
							first_comm=$(echo $i | cut -d'>' -f1)
							second_comm=$(echo $i | sed 's/2>&1//' | cut -d'>' -f2)
							if [[ "$(echo $i | grep '2>&1')" ]]; then
								eval $first_comm >> $second_comm 2>&1
							else
								eval $first_comm >> $second_comm
							fi
						fi
					else
						if [[ "$(echo $i | cut -d'>' -f1)" ]]; then
							first_comm=$(echo $i | cut -d'>' -f1)
							second_comm=$(echo $i | sed 's/2>&1//' | cut -d'>' -f2)
							if [[ "$(echo $i | grep '2>&1')" ]]; then
								eval $first_comm > $second_comm 2>&1
							else
								eval $first_comm > $second_comm
							fi
						fi
					fi
				else
					$i
				fi
			;;
		esac
		echo  -e -n "\e[1;32mdebug-\e[1;33m$version\e[0m"
		if [[ "$su_check" == 0 ]]; then
			echo -n '# '
		else
			echo -n '$ '
		fi
	done
}


#SH-OTA v1.2_alpha By Deic & DiamondBond

sh-ota(){
	#Edit from here
	name="main.sh"
	cloud="https://main.sh"

	#Don't edit from here
	ota_ext="$EXTERNAL_STORAGE/Download/$name"
	ota_tmp="/data/local/tmp/$name"

	clear
	if [ -f /system/bin/curl ] || [ -f /system/xbin/curl ]; then
		curl -k -L $ota_tmp $cloud 1>/dev/null
	else
		am start android.intent.action.VIEW com.android.browser $cloud 1>/dev/null
	fi

	run(){
	if [ -f $ota_ext ]; then
		am force-stop com.android.browser
		cp -rf $ota_ext $ota_tmp
		sleep 2
		chmod 755 $ota_tmp
		$SHELL -c $ota_tmp
	else
		run
	fi
	}

exit
}

#sh-ota

body(){
	while true; do
		clear
		echo "$cyan[-=The Hybrid Project=-]$nc"
		echo
		echo "${yellow}Menu:$nc"
		echo " 1|Instant Boost"
		echo " 2|Clean up my crap"
		echo " 3|Optimize my SQLite DB's"
		echo " 4|Tune my VM"
		echo " 5|Tune my LMK"
		echo " 6|Tune my Networks"
		echo " 7|Kernel Kontrol"
		if [ -f /dev/block/zram* ]; then
			zram=0
			echo " 8|zRAM Settings"
		fi
		if [ $zram == 0 ]; then
			echo " 8|Game Booster"
		else

			echo " 9|Game Booster"
		fi
		echo
		echo " O|Options"
		echo " A|About"
		echo " R|Reboot"
		echo " E|Exit"
		echo
		echo -n "> "
		read selection_opt
		case $selection_opt in
			1 ) drop_caches;;
			2 ) clean_up;;
			3 ) sql_optimize;;
			4 ) vm_tune;;
			5 ) lmk_tune_opt;;
			6 ) network_tune;;
			7 ) kernel_kontrol;;
			8 ) zram_settings;;
			9 ) catalyst_control;;
			o|O ) options;;
			a|A ) about_info;;
			r|R ) custom_reboot;;
			e|E ) safe_exit;;
			* ) checkers;;
		esac
	done
}

drop_caches(){
	clear
	echo "${yellow}Dropping caches...$nc"
	sleep 1

	sync
	echo 3 > /proc/sys/vm/drop_caches

	clear
	echo "${yellow}Caches dropped!$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]
	then
		touch $initd_dir/97cache_drop
		chmod 755 $initd_dir/97cache_drop
cat > $initd_dir/97cache_drop <<-EOF
#!/system/bin/sh

sleep 15

sync; echo 3 > /proc/sys/vm/drop_caches

EOF
	clear
	echo "${yellow}Installed!$nc"
	sleep 1
	fi

	body
}

clean_up(){
	clear
	echo "${yellow}Cleaning up...$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]
	then
	 	script_dir=$initd_dir
	else
	 	script_dir=$tmp_dir
	fi

	touch $script_dir/99clean_up
	chmod 755 $script_dir/99clean_up
cat > $script_dir/99clean_up <<-EOF
#!/system/bin/sh

sleep 15

rm -f /cache/*.apk
rm -f /cache/*.tmp
rm -f /cache/recovery/*
rm -f /data/*.log
rm -f /data/*.txt
rm -f /data/anr/*.*
rm -f /data/backup/pending/*.tmp
rm -f /data/cache/*.*
rm -f /data/dalvik-cache/*.apk
rm -f /data/dalvik-cache/*.tmp
rm -f /data/log/*.*
rm -f /data/local/*.apk
rm -f /data/local/*.log
rm -f /data/local/tmp/*.*
rm -f /data/last_alog/*
rm -f /data/last_kmsg/*
rm -f /data/mlog/*
rm -f /data/tombstones/*
rm -f /data/system/dropbox/*
rm -f /data/system/usagestats/*
rm -f $EXTERNAL_STORAGE/LOST.DIR/*

EOF
	$script_dir/99clean_up

	clear
	echo "${yellow}Clean up complete!$nc"
	sleep 1

	if [ $perm == 1 ]
	then
	 	clear
	 	echo "${yellow}Installed!$nc"
	 	sleep 1
	fi

	body
}

sql_optimize(){
	clear
	echo "${yellow}Optimizing SQLite databases...$nc"
	sleep 1

	if [ -e /system/xbin/sqlite3 ]
	then
		chown root.root  /system/xbin/sqlite3
		chmod 755 /system/xbin/sqlite3
		SQLLOC=/system/xbin/sqlite3
	fi

	if [ -e /system/bin/sqlite3 ]
	then
		chown root.root /system/bin/sqlite3
		chmod 755 /system/bin/sqlite3
		SQLLOC=/system/bin/sqlite3
	fi

	if [ -e /system/sbin/sqlite3 ]
	then
		chown root.root /sbin/sqlite3
		chmod 755 /sbin/sqlite3
		SQLLOC=/sbin/sqlite3
	fi
	for i in `find / -iname "*.db" 2>/dev/null`
	do
	 	clear
		$SQLLOC $i 'VACUUM'
		echo "${yellow}Vacuumed:$nc $i"
		$SQLLOC $i 'REINDEX'
		echo "${yellow}Reindexed:$nc $i"
	done

	clear
	echo "${yellow}SQLite database optimizations complete!$nc"
	sleep 1

	body
}

vm_tune(){
	clear
	echo "${yellow}Optimizing VM...$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]
	then
	 	script_dir=$initd_dir
	else
	 	script_dir=$tmp_dir
	fi

	touch $script_dir/75vm
	chmod 755 $script_dir/75vm
cat > $script_dir/75vm <<-EOF
#!/system/bin/sh

sleep 15

echo 80 > /proc/sys/vm/swappiness
echo 10 > /proc/sys/vm/vfs_cache_pressure
echo 3000 > /proc/sys/vm/dirty_expire_centisecs
echo 500 > /proc/sys/vm/dirty_writeback_centisecs
echo 90 > /proc/sys/vm/dirty_ratio
echo 70 > /proc/sys/vm/dirty_background_ratio
echo 1 > /proc/sys/vm/overcommit_memory
echo 150 > /proc/sys/vm/overcommit_ratio
echo 4096 > /proc/sys/vm/min_free_kbytes
echo 1 > /proc/sys/vm/oom_kill_allocating_task

EOF
	$script_dir/75vm

	clear
	echo "${yellow}VM Optimized!$nc"
	sleep 1

	if [ $perm == 1 ]; then
	 	clear
	 	echo "${yellow}Installed!$nc"
	 	sleep 1
	fi

	body
}

lmk_tune_opt(){
	clear
	echo "${yellow}LMK Optimization$nc"
	echo
	echo "${yellow}Minfree profiles available:$nc"
	echo " B|Balanced"
	echo " M|Multitasking|"
	echo " G|Gaming"
	echo
	echo " R|Return"
	echo
	echo -n "> "
	read lmk_opt
	case $lmk_opt in
		b|B|m|M|g|G ) clear; echo "Done"; sleep 1; lmk_profile=$lmk_opt; lmk_apply;;
		r|R ) body;;
		* ) checkers; lmk_tune_opt;;
	esac
}

lmk_apply(){
	clear
	if [ $lmk_profile == b ] || [ $lmk_profile = B ]; then
		minfree_array='1024,2048,4096,8192,12288,16384'
	fi

	if [ $lmk_profile == m ] || [ $lmk_profile = M ]; then
	 minfree_array='1536,2048,4096,5120,5632,6144'
	fi

	if [ $lmk_profile == g ] || [ $lmk_profile = G ]; then
	 minfree_array='10393,14105,18188,27468,31552,37120'
	fi

	echo "${yellow}Optimizing LMK...$nc"
	sleep 1

	echo $minfree_array > /sys/module/lowmemorykiller/parameters/minfree

	clear
	echo "${yellow}LMK Optimized!$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]; then
		touch $initd_dir/95lmk
		chmod 755 $initd_dir/95lmk
cat > $initd_dir/95lmk <<-EOF
#!/system/bin/sh

sleep 15

echo $minfree_array > /sys/module/lowmemorykiller/parameters/minfree

EOF
	 	clear
		echo "${yellow}Installed!$nc"
		sleep 1
	fi

	body
}

network_tune(){
	clear
	echo "${yellow}Optimizing Networks...$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]; then
	 	script_dir=$initd_dir
	else
	 	script_dir=$tmp_dir
	fi

	touch $script_dir/56net
	chmod 755 $script_dir/56net
cat > $script_dir/56net <<-EOF
#!/system/bin/sh

sleep 15

#TCP
echo 2097152 > /proc/sys/net/core/wmem_max
echo 2097152 > /proc/sys/net/core/rmem_max
echo 20480 > /proc/sys/net/core/optmem_max
echo 1 > /proc/sys/net/ipv4/tcp_moderate_rcvbuf
echo 6144 > /proc/sys/net/ipv4/udp_rmem_min
echo 6144 > /proc/sys/net/ipv4/udp_wmem_min
echo 6144 87380 2097152 > /proc/sys/net/ipv4/tcp_rmem
echo 6144 87380 2097152 > /proc/sys/net/ipv4/tcp_wmem
echo 0 > /proc/sys/net/ipv4/tcp_timestamps
echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
echo 1 > /proc/sys/net/ipv4/tcp_tw_recycle
echo 1 > /proc/sys/net/ipv4/tcp_sack
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes
echo 156 > /proc/sys/net/ipv4/tcp_keepalive_intvl
echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
echo 0 > /proc/sys/net/ipv4/tcp_ecn
echo 360000 > /proc/sys/net/ipv4/tcp_max_tw_buckets
echo 2 > /proc/sys/net/ipv4/tcp_synack_retries
echo 1 > /proc/sys/net/ipv4/route/flush
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo 524288 > /proc/sys/net/core/wmem_max
echo 524288 > /proc/sys/net/core/rmem_max
echo 110592 > /proc/sys/net/core/rmem_default
echo 110592 > /proc/sys/net/core/wmem_default

#IPv4
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
echo 1 > /proc/sys/net/ipv4/conf/default/log_martians

EOF
	$script_dir/56net

	clear
	echo "${yellow}Networks Optimized!$nc"
	sleep 1

	if [ $perm == 1 ]; then
	 	clear
	 	echo "${yellow}Installed!$nc"
	 	sleep 1
	fi

	body
}

kernel_kontrol(){
	clear
	echo "${yellow}Kernel Kontrol$nc"
	echo " 1|Set CPU Freq"
	echo " 2|Set CPU Gov"
	echo " 3|Set I/O Sched"
	if [ -d /sys/devices/platform/kcal_ctrl.0/ ]; then
	 	echo " 4|View KCal Values"
	fi
	echo " B|Back"
	echo
	echo -n "> "
	read kk_opt
	case $kk_opt in
		1) setcpufreq;;
		2) setgov;;
		3) setiosched;;
		4) kcal;;
		b|B) body;;
		* ) checkers; kernel_kontrol;;
	 esac
}

setcpufreq(){
	clear
	#configure sub variables
	maxfreq=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq`
	minfreq=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`
	curfreq=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
	listfreq=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`

	echo "${yellow}CPU Control$nc"
	echo
	echo "${bld}Max Freq:$nc $maxfreq"
	echo "${bld}Min Freq:$nc $minfreq"
	echo "${bld}Current Freq:$nc $curfreq"
	echo
	echo "${bld}Available Freq's:$nc"
	echo "$listfreq"
	echo
	echo -n "New Max Freq: "; read newmaxfreq
	echo -n "New Min Freq: "; read newminfreq

	echo $newmaxfreq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
	echo $newminfreq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

	clear
	echo "${yellow}New Freq's applied!$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]; then
		touch $initd_dir/69cpu_freq
		chmod 755 $initd_dir/69cpu_freq
cat > $initd_dir/69cpu_freq <<-EOF
#!/system/bin/sh

sleep 15

echo $newmaxfreq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo $newminfreq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

EOF
	 	clear
		echo "${yellow}Installed!$nc"
	 	sleep 1
	fi

	kernel_kontrol
}

setgov(){
	clear

	#sub-variables
	curgov=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
	listgov=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`

	echo "${yellow}Governor Control$nc"
	echo
	echo "${bld}Current Governor:$nc $curgov"
	echo
	echo "${bld}Available Governors:$nc"
	echo "$listgov"
	echo
	echo -n "New Governor: "; read newgov

	echo "$newgov" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

	clear
	echo "${yellow}New Governor applied!$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]; then
		touch $initd_dir/70cpu_gov
		chmod 755 $initd_dir/70cpu_gov
cat > $initd_dir/70cpu_gov <<-EOF
#!/system/bin/sh

sleep 15

echo "$newgov" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

EOF
	 	clear
		echo "${yellow}Installed!$nc"
	 	sleep 1
	fi

	kernel_kontrol
}


setiosched(){
	clear

	#sub-variables
	curiosched=`cat /sys/block/mmcblk0/queue/scheduler | sed 's/.*\[\([a-zA-Z0-9_]*\)\].*/\1/'`
	listiosched=`cat /sys/block/mmcblk0/queue/scheduler | tr -s "[[:blank:]]" "\n" | sed 's/\[\([a-zA-Z0-9_]*\)\]/\1/'`

	echo "${yellow}I/O Schedulder Control$nc"
	echo
	echo "${bld}Current I/O Scheduler:$nc $curiosched"
	echo
	echo "${bld}Available I/O Schedulers:$nc"
	echo "$listiosched"
	echo
	echo -n "New Scheduler: "; read newiosched

	for j in /sys/block/*/queue/scheduler
	do
	 	echo "$newiosched" > $j
	done

	clear
	echo "${yellow}New I/O Scheduler applied!$nc"
	sleep 1

	if [ $perm == 1 ] && [ $initd == 1 ]
	then
		touch $initd_dir/71io_sched
		chmod 755 $initd_dir/71io_sched
cat > $initd_dir/71io_sched <<-EOF
#!/system/bin/sh

sleep 15

for j in /sys/block/*/queue/scheduler
do
	echo "$newiosched" > dir
done

EOF
		sed -i 's/dir/$j/' $initd_dir/71io_sched

	 	clear
		echo "${yellow}Installed!$nc"
	 	sleep 1
	fi

	kernel_kontrol
}

kcal(){
	clear
	if [ ! -d /sys/devices/platform/kcal_ctrl.0/ ]; then
	 	checkers
	 	kernel_kontrol
	else
	 	echo "${yellow}Current KCal Values:${nc}"
	 	rgb=`cat /sys/devices/platform/kcal_ctrl.0/kcal`
	 	sat=`cat /sys/devices/platform/kcal_ctrl.0/kcal_sat`
	 	cont=`cat /sys/devices/platform/kcal_ctrl.0/kcal_cont`
	 	hue=`cat /sys/devices/platform/kcal_ctrl.0/kcal_hue`
	 	gamma=`cat /sys/devices/platform/kcal_ctrl.0/kcal_val`
	 	echo "rgb: $rgb, sat: $sat, cont: $cont, hue: $hue, gamma: $gamma"
	 	sleep 5

	 	kernel_kontrol
	fi
}

zram_settings(){
	clear
	if [ $zram == 0 ]; then
	 	catalyst_control
	else
	 	echo "${yellow}zRAM Options:$nc"
	 	echo " 1|Disable zRAM"
	 	echo " 2|Enable zRAM"
	 	echo " B|Back"
	 	echo
	 	echo -n "> "
	 	read options_opt
	 	case $options_opt in
	 		1 ) zram_disable;;
	 		2 ) zram_enable;;
	 		b|B ) body;;
	 		* ) checkers; zram_settings;;
	 	esac
	fi
}

zram_enable(){
	clear
	echo "${yellow}Enabling zRAM...$nc"
	sleep 1

	for l in `ls /dev/block/zram*`
	do
		swapon $l
	done

	clear
	echo "${yellow}zRAM enabled!$nc"
	sleep 1
	
	zram_settings
}

zram_disable(){
	clear
	echo "${yellow}Disabling zRAM...$nc"
	sleep 1

	for l in `ls /dev/block/zram*`
	do
		swapoff $l
	done

	clear
	echo "${yellow}zRAM disabled!$nc"
	sleep 1
	
	zram_settings
}

catalyst_control(){
	clear
	if [ $zram == 0 ]; then
		checkers
	fi
	echo "${yellow}Game Booster$nc"
	echo " [1] Boost"
	echo " [2] Options"
	echo " [B] Back"
	echo
	echo -n "> "
	read game_booster_opt
	case $game_booster_opt in
		1 ) catalyst_inject;;
		2 ) catalyst_time_cfg;;
		b|B ) body;;
		* ) checkers; catalyst_control;;
	esac
}

catalyst_inject(){
	clear
	echo "Please leave the terminal emulator running"
	echo "This will continue to run untill close the terminal"

	while true
	do
		sync; echo 3 > /proc/sys/vm/drop_caches
		sleep $catalyst_time
	done
}

catalyst_time_cfg(){
	clear
	echo "Current rate: $catalyst_time"
	echo "60 - Every minute - Default"
	echo "3600 - Every hour"
	echo
	echo "Please enter a rate in seconds:"
	echo -n "> "
	read catalyst_time_val
	setprop persist.hybrid.catalyst.time $catalyst_time_val
	clear
	echo "Time updated!"
	sleep 1
	
	catalyst_control
}

options(){
	clear
	echo "${yellow}Options$nc"
	echo " I|Install options"
	echo " S|Sensor fix"
	echo " B|Back"
	echo
	echo -n "> "
	read options_opt
	case $options_opt in
	 	i|I ) install_options;;
		s|S ) sensor_fix;;
	 	b|B ) body;;
		* ) checkers; options;;
	esac
}

install_options(){
	clear
	echo "${yellow}How to install tweaks?$nc"
	echo " T|Temporary installs"
	echo " P|Permanent installs"
	if [ "$perm" = "0" ] || [ "$perm" = "1" ]; then
	 	echo
	 	echo " B|Back"
	 	echo
	 	echo -n "> "
	 	read install_options_opt
	 	case $install_options_opt in
	 	 	t|T ) setprop persist.hybrid.perm 0; clear; echo "Done"; sleep 1; body;;
		 	p|P ) setprop persist.hybrid.perm 1; clear; echo "Done"; sleep 1; body;;
	 	 	b|B ) body;;
		 	* ) checkers; install_options;;
	 	esac
	else
	first_install
	fi
}

first_install(){
	echo
	echo "${cyan}You can change it in Options later$nc"
	echo
	echo -n "> "
	read first_install_opt
	case $first_install_opt in
		t|T ) setprop persist.hybrid.perm 0; clear; echo "Done"; sleep 1; body;;
		p|P ) setprop persist.hybrid.perm 1; clear; echo "Done"; sleep 1; body;;
		* ) checkers; install_options;;
	esac
}

sensor_fix(){
	clear
	#this is a fix for dirty flashers with bad sensors.
	echo "Wipe sensor data? [Y/N]"
	echo -n "> "
	read sensorfix_opt
	case $sensorfix_opt in
		y|Y ) rm -rf /data/misc/sensor; echo "done!"; body;;
		n|N ) body;;
		* ) checkers; options;;
	esac
}

about_info(){
	clear
	echo "${green}About:$nc"
	echo
	echo "Hybrid Version: $ver_revision"
	echo
	echo "${yellow}INFO$nc"
	echo "This script deals with many things apps normally do."
	echo "But this script is ${cyan}AWESOME!$nc because its < ${bld}1MB!$nc"
	echo
	echo "${yellow}CREDITS$nc"
	echo "DiamondBond : Script creator & maintainer"
	echo "Deic : Maintainer"
	echo "Hoholee12/Wedgess/Imbawind/Luca020400 : Code $yellow:)$nc"

	echo
	echo "${yellow}Links:$nc"
	echo " F|Forum"
	echo " S|Source"
	echo
	echo " B|Back"
	echo
	echo -n "> "
	read about_info_opt
	case $about_info_opt in
	 	f|F ) am start "http://forum.xda-developers.com/android/software-hacking/dev-hybridmod-t3135600" 1>/dev/null; about_info;;
	 	s|S ) am start "https://github.com/HybridMod" 1>/dev/null; about_info;;
	 	b|B ) body;;
	 	* ) checkers; about_info;;
	esac
}

custom_reboot(){
	clear
	echo "Rebooting in 3."
	sleep 1
	clear
	echo "Rebooting in 2.."
	sleep 1
	clear
	echo "Rebooting in 1..."
	sleep 1
	clear
	echo "Bam!"
	sleep 1
	sync
	reboot
}

safe_exit(){
	clear
	exit
}

if [[ "$1" == --debug ]]; then #type 'hybrid --debug' to trigger debug_shell().
	shift
	debug_shell
fi

clear

if [ "$perm" = "" ]; then
	install_options
elif [ "$catalyst_time" = "" ]; then
	setprop persist.hybrid.catalyst.time 60
fi

body
