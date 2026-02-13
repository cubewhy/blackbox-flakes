{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.libraries.cuda;
  cudaPkg = pkgs."cudaPackages_${cfg.version}";
  linuxPkgs = pkgs.linuxPackages or pkgs.linuxPackages_latest;
in {
  options.blackbox.libraries.cuda = {
    enable = mkEnableOption "CUDA development environment";

    version = mkOption {
      type = types.str;
      default = "12";
      description = "CUDA Major version (e.g., '11', '12', '13'). Maps to pkgs.cudaPackages_<version>";
    };

    withDrivers = mkOption {
      type = types.bool;
      default = true;
      description = "Include nvidia_x11 drivers in LD_LIBRARY_PATH (Warning: can cause version mismatch on non-NixOS)";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages = with pkgs;
      [
        git
        gitRepo
        gnupg
        autoconf
        curl
        procps
        gnumake
        util-linux
        m4
        gperf
        unzip

        cudaPkg.cudatoolkit

        libGLU
        libGL
        freeglut
        libXi
        libXmu
        libXext
        libX11
        libXv
        libXrandr

        zlib
        ncurses5
        stdenv.cc
        binutils
      ]
      ++ optionals cfg.withDrivers [
        linuxPkgs.nvidia_x11
      ];

    blackbox.env = {
      CUDA_PATH = "${cudaPkg.cudatoolkit}";

      EXTRA_LDFLAGS = "-L/lib -L${linuxPkgs.nvidia_x11}/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
    };

    blackbox.shellHook = ''
      export LD_LIBRARY_PATH="${makeLibraryPath [
        linuxPkgs.nvidia_x11
        pkgs.ncurses5
        pkgs.stdenv.cc.cc.lib
      ]}:/run/opengl-driver/lib:$LD_LIBRARY_PATH"

      if command -v nvcc > /dev/null; then
        nvcc --version | grep release
      else
        echo "⚠️  nvcc not found in PATH!"
      fi
    '';
  };
}
