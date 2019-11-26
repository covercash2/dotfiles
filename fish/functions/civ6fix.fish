function civ6fix --description 'a fix for civ6 as of 02-2019'
	set --export LD_PRELOAD /usr/lib/libfreetype.so.6
	and steam-native
end
