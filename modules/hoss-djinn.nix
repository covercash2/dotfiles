# djinn language model server, running on the gpu.
# options: https://github.com/covercash2/djinn#nixos

{ ... }:

{
  services.djinn = {
    enable = true;
    # ollama already owns 11434. 9000 doesn't collide with anything else on
    # hoss (checked) and is djinn's own test-fixture example port.
    # reverse-proxied at https://djinn.hoss.chrash.net — see modules/hoss.nix.
    port = 9000;
    cuda.enable = true;
  };
}
