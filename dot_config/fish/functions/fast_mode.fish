function fast_mode --description 'change cpu governor to performance mode'
	set files /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	for file in $files
		echo $file '->' (cat $file)
	end
	echo performance | sudo tee $file
end
