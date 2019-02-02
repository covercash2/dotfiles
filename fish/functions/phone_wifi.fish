function phone_wifi --description 'turn on wifi from phone usb tether'
	set interface $argv
sudo ip link set $interface up
sudo dhcpcd $interface
end
