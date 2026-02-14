{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.blackbox;

  libs = cfg.libraries.shared;

  # this variable may make you confusing
  # please refer to modules/libraries/graphics.nix for more info
  graphicsEnabled = cfg.libraries.graphics.enable or false;
in {
  options.blackbox.libraries = {
    shared = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of shared libraries to automatically configure in LD_LIBRARY_PATH and LIBRARY_PATH.";
    };
  };

  config = mkIf (libs != []) {
    blackbox.packages = libs;

    blackbox.env = {
      LD_LIBRARY_PATH =
        (makeLibraryPath libs)
        + (optionalString graphicsEnabled ":/run/opengl-driver/lib:/run/wrappers/lib")
        + ":$LD_LIBRARY_PATH";

      LIBRARY_PATH = (makeLibraryPath libs) + ":$LIBRARY_PATH";
    };
  };
}
