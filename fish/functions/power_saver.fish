function power_saver --description 'change cpu governor to powersave mode'
	set files /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
	for file in $files
		echo $file '->' (cat $file)
	end
	echo powersave | sudo tee $files
end
