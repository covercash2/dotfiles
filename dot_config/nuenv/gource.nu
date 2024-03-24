
# https://trac.ffmpeg.org/wiki/Encode/H.264
let presets = [
	"ultrafast", # large file sizes
	"medium",
	"veryslow",  # small file sizes
]

let output_extensions = [
	"avi",
	"mp4",
	"mkv",
]

def check_preset [
	preset: string
] {
	if not ($presets | any {|it| $it == $preset }) {
		error make { 
			msg: $"($preset) not found in ($presets)",
			label: {
				text: "preset passed here",
				span: (metadata $preset).span,
			}
		}
	}
}

def check_output [
	output-path: path
] {
	if not ($output_extensions | any {|it| $output | str ends-with $it }) {
		error make { 
			msg: $"($output) does not have an extension that matches ($output_extensions)",
			label: {
				text: "output passed here",
				span: (metadata $output).span,
			}
		}
	}
}

def "gource record" [
	output: path
	--preset: string = "veryslow"
	--quality: int = 8
] {
	check_preset $preset
	check_output $output

	let gource_args = [
		"-1280x720"
		"-o" "-"
	]

	let ffmpeg_args = ["-y" 
			"-r" "60" 
			"-f" "image2pipe" 
			"-vcodec" "ppm" 
			"-i" "-"
			"-vcodec" "libx264" 
			"-preset" $preset
			"-pix_fmt" "yuv420p" 
			"-crf" $quality
			"-threads" "0" 
			"-bf" "0",
			$output,
		]

	$ffmpeg_args | inspect

	run-external --redirect-stdout ...$gource_args |
		run-external "ffmpeg" ...$ffmpeg_args
}
