function run_ion --description "build and run ion release"
	set ion_path ~/code/ion
	cd $ion_path
	cargo build --release
	set exe_path $ion_path"/target/release/ion"
	eval $exe_path
end
