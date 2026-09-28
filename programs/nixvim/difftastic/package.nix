{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  vimUtils,
  vimPlugins,
}:
let
  version = "0.1.0-unstable-2026-07-09";
  src = fetchFromGitHub {
    owner = "clabby";
    repo = "difftastic.nvim";
    rev = "c39bbe1c60eec06ad7d141bd09bb910fac4d2436";
    hash = "sha256-x5rm54LdloowVFPtNGs/N6dAqcVe3tHH7eJjPvxdqzk=";
  };
  nativeLibrary = rustPlatform.buildRustPackage {
    pname = "difftastic-nvim-lib";
    inherit version src;
    cargoHash = "sha256-VSlFlLa4knQ7bH8yFHSKTTtt1cQ76dstlCdWBAtkf1I=";
    # Avoid CPU-specific builds; Neovim supplies LuaJIT symbols at load time.
    env.RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
  };
  ext = stdenv.hostPlatform.extensions.sharedLibrary;
in
vimUtils.buildVimPlugin {
  pname = "difftastic.nvim";
  inherit version src;
  dependencies = [ vimPlugins.nui-nvim ];
  # The upstream loader expects these paths and cannot create links in the Nix store.
  preInstall = ''
    mkdir -p target/release
    ln -s ${nativeLibrary}/lib/libdifftastic_nvim${ext} target/release/libdifftastic_nvim${ext}
    ln -s libdifftastic_nvim${ext} target/release/difftastic_nvim.so
  '';
  passthru = { inherit nativeLibrary; };
  meta = {
    description = "Structural diffs for Neovim with jj support";
    homepage = "https://github.com/clabby/difftastic.nvim";
    license = lib.licenses.mit;
  };
}
