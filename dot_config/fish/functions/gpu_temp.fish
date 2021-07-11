function gpu_temp --description 'get nvidia gpu temperature'
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
end
