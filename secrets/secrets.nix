# Recipients for agenix secrets. Edit a secret with:
#   cd secrets && EDITOR=vim nix run github:ryantm/agenix -- -e <name>.age
let
  aoli = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADuUNeWGvQM3BX7q79a6vN8kY/BQlSrYsVznpIgfRhn aoli@Aos-MacBook-Pro";
  # Dedicated encryption key at /etc/agenix/key on jex, not its SSH host key.
  jex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC+NIVbLzhFouubkigNSRHIwmoX9ZzTVgiReP9DNvsd agenix-jex";
in
{
  "govee2mqtt.env.age".publicKeys = [
    aoli
    jex
  ];
}
