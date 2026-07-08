{ pkgs, lib, ... }:
let
  enableUnifiedFolders = pkgs.writeShellScript "thunderbird-unified-folders" ''
    set -eu
    url="chrome://messenger/content/messenger.xhtml"
    for store in "$HOME"/.thunderbird/*/xulstore.json; do
      [ -e "$store" ] || continue
      if ${pkgs.jq}/bin/jq -e --arg url "$url" \
        '(.[$url].folderTree.mode // "") | split(",") | index("smart")' \
        "$store" >/dev/null; then
        continue
      fi
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq --arg url "$url" \
        '.[$url].folderTree.mode = ("smart," + (.[$url].folderTree.mode // "all" | sub("^$"; "all")))' \
        "$store" >"$tmp"
      mv "$tmp" "$store"
      echo "Enabled Thunderbird unified folders in $store"
    done
  '';
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [ (import ./package.nix pkgs) ];

  home.activation.thunderbirdUnifiedFolders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${enableUnifiedFolders}
  '';
}
