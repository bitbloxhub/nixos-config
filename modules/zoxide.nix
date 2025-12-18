{
  self,
  ...
}:
{
  flake.modules.generic.default = {
    options.my.programs.zoxide = {
      enable = self.lib.mkDisableOption "Zoxide";
      enableNushellIntegration = self.lib.mkDisableOption "Zoxide Nushell integration";
    };
  };

  flake.modules.homeManager.default =
    {
      config,
      ...
    }:
    {
      programs.zoxide = {
        inherit (config.my.programs.zoxide) enable;
        inherit (config.my.programs.zoxide) enableNushellIntegration;
      };
    };
}
