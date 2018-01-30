function debug_ion --description "build and run ion debug version"
	cd ~/code/ion
	cargo build; and eval ~/code/ion/target/debug/ion
end

