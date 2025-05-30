{ config, lib, ... }:
let
  cfg = config.stylix.targets.wpaperd;
in
{
  options.stylix.targets.wpaperd = {
    enable = config.lib.stylix.mkEnableTarget "wpaperd" (
      config.stylix.image != null
    );
  };

  config = lib.mkIf (config.stylix.enable && cfg.enable) (
    let
      inherit (config.stylix) imageScalingMode;

      # wpaperd doesn't have any mode close to the described behavior of center
      modeMap = {
        "stretch" = "stretch";
        # wpaperd's center mode is closest to the described behavior of fill
        "fill" = "center";
        "fit" = "fit";
        "tile" = "tile";
      };

      modeAttrs =
        if builtins.hasAttr imageScalingMode modeMap then
          { mode = modeMap.${imageScalingMode}; }
        else
          lib.info "stylix: wpaperd: unsupported image scaling mode: ${imageScalingMode}"
            { };
    in
    {
      services.wpaperd.settings.any = {
        path = "${config.stylix.image}";
      } // modeAttrs;
    }
  );
}
