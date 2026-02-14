{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.blackbox.libraries.graphics;

  graphicsLibs = with pkgs; [
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libxcb
    libxkbcommon
    wayland
    libGL
    vulkan-loader
  ];
in {
  options.blackbox.libraries.graphics = {
    enable = mkEnableOption "Graphics environment (Wayland, X11, Vulkan, OpenGL)";
  };

  config = mkIf cfg.enable {
    blackbox.libraries.shared = graphicsLibs;
  };
}
