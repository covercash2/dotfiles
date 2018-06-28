# Defined in /Users/chreeus/code/fish_project/project.fish @ line 44
function clean_run --description 'clean run performs all necessary actions to clean, build, and run the project'
	clean
    and configure
    and build
    and run
end
