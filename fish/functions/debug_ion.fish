function debug_ion --description "build and run ion debug"
	set ion_path ~/code/ion
	cd $ion_path
	cargo build
	and set exe_path $ion_path"/target/debug/ion"
	eval $exe_path
end
