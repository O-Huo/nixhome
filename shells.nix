pkgs: with pkgs; {
  default = mkShellNoCC {
    buildInputs = [
      nixfmt
    ];
  };

  java21 = mkShellNoCC {
    buildInputs = [
      jdk21
    ];
  };

  java17 = mkShellNoCC {
    buildInputs = [
      jdk17
    ];
  };

  java11 = mkShellNoCC {
    buildInputs = [
      jdk11
      maven
      gradle
    ];
  };

  go = mkShellNoCC {
    buildInputs = [
      go
      gopls
    ];
  };

  yarn = mkShellNoCC {
    buildInputs = [
      nodejs
      yarn
    ];
  };

  rust = mkShell {
    buildInputs = [
      rustc
      openssl
      pkg-config
      eza
      fd
      llvmPackages.bintools
      lldb
      cargo-fuzz
      inferno
      cargo-flamegraph
      cargo
      protobuf
    ]
    ++ lib.optionals stdenv.isLinux [
      bpftrace
      perf
    ];
  };

  clojure = mkShellNoCC {
    buildInputs = [
      leiningen
      gnuplot
      graphviz
      jdk11
    ];
  };
}
