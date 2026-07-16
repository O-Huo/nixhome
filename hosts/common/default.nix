{
  pkgs,
  inputs,
  withNvidia ? false,
  headless ? false,
  ...
}:
{
  imports = [
    (import ./headless.nix { inherit pkgs inputs; })
  ]
  ++ (
    if headless then
      [ ]
    else
      [ (import ./gui.nix { inherit pkgs inputs withNvidia; }) ]
  );
}
