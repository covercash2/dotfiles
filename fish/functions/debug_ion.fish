function debug_ion --description "build and run ion debug version"
	cd ~/code/ion
	cargo build
	eval ~/code/ion/target/debug/ion
end

