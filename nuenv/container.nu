
def "con logs" [
	container_name: string,
] {
	podman container logs $container_name
}

def "con up" [
	extra_args: list = [],
] {
	podman-compose up -d ...extra_args
}
