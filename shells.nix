pkgs:
with pkgs; {
  default = mkShellNoCC {
    buildInputs = [
      nixfmt-rfc-style
    ];
  };

  dotnet8 = mkShellNoCC {
    buildInputs = [
      dotnetCorePackages.sdk_8_0_3xx
      jdk11
      maven
    ];
  };

  java23 = mkShellNoCC {
    buildInputs = [
      jdk23
      maven
      gradle
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

  rust = mkShellNoCC {
    buildInputs = [
      rustc
      openssl
      pkg-config
      eza
      fd
      kaniVerifier
      llvmPackages.bintools
      lldb
      cargo-fuzz
      bpftrace
      perf
      inferno
      cargo-flamegraph
    ];
  };

  clojure =
    mkShellNoCC
    {
      buildInputs = [
        leiningen
        gnuplot
        graphviz
        jdk11
      ];
    };
}
