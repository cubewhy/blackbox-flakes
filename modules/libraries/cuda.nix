{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.libraries.cuda;
  cudaPkg = pkgs."cudaPackages_${cfg.version}";
in {
  options.blackbox.libraries.cuda = {
    enable = mkEnableOption "CUDA development environment";

    version = mkOption {
      type = types.str;
      default = "12";
      description = "CUDA Major version (e.g., '11', '12', '13'). Maps to pkgs.cudaPackages_<version>";
    };
  };

  config = mkIf cfg.enable {
    blackbox.packages = with pkgs; [
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
    ];

    blackbox.env = {
      CUDA_PATH = "${cudaPkg.cudatoolkit}";

      EXTRA_LDFLAGS = "-L/lib -L/run/opengl-driver/lib";
      EXTRA_CCFLAGS = "-I/usr/include";
    };

    blackbox.shellHook = ''
      export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:${makeLibraryPath [
        pkgs.ncurses5
        pkgs.stdenv.cc.cc.lib
      ]}:$LD_LIBRARY_PATH"

      if command -v nvcc > /dev/null; then
        nvcc --version | grep release
      else
        echo "⚠️ nvcc not found in PATH!"
      fi
    '';
  };
}
