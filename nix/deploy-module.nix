# From https://github.com/serokell/deploy-rs/pull/269
# SPDX-FileCopyrightText: 2024 Sefa Eyeoglu <contact@scrumplex.net>
# SPDX-License-Identifier: MPL-2.0
{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  genericSettings = {
    options = {
      activationTimeout = mkOption {
        default = null;
        type = with types; nullOr int;
      };
      autoRollback = mkOption {
        default = null;
        type = with types; nullOr bool;
      };
      confirmTimeout = mkOption {
        default = null;
        type = with types; nullOr int;
      };
      fastConnection = mkOption {
        default = null;
        type = with types; nullOr bool;
      };
      interactiveSudo = mkOption {
        default = null;
        type = with types; nullOr bool;
      };
      magicRollback = mkOption {
        default = null;
        type = with types; nullOr bool;
      };
      remoteBuild = mkOption {
        default = null;
        type = with types; nullOr bool;
      };
      sshOpts = mkOption {
        default = [ ];
        type = with types; listOf str;
      };
      sshUser = mkOption {
        default = null;
        type = with types; nullOr str;
      };
      sudo = mkOption {
        default = null;
        type = with types; nullOr str;
      };
      tempPath = mkOption {
        default = null;
        type = with types; nullOr str;
      };
      user = mkOption {
        default = null;
        type = with types; nullOr str;
      };
    };
  };
  nodeModule = types.submoduleWith {
    modules = [
      genericSettings
      nodeSettings
    ];
  };
  nodeSettings = {
    options = {
      hostname = mkOption {
        type = types.str;
      };
      profiles = mkOption {
        type = types.attrsOf profileModule;
      };
      profilesOrder = mkOption {
        default = [ ];
        type = with types; listOf str;
      };
    };
  };
  nodesSettings = {
    options.nodes = mkOption {
      type = types.attrsOf nodeModule;
    };
  };
  profileModule = types.submoduleWith {
    modules = [
      genericSettings
      profileSettings
    ];
  };
  profileSettings = {
    options = {
      path = mkOption {
        type = types.package;
      };
      profilePath = mkOption {
        default = null;
        type = with types; nullOr str;
      };
    };
  };
  rootModule = types.submoduleWith {
    modules = [
      genericSettings
      nodesSettings
    ];
  };
in
{
  config.perSystem = {
    # TODO: For some reason this fails, fix it.
    # checks = lib.mkIf (deploy-rs.lib ? ${system}) (deploy-rs.lib.${system}.deployChecks cfg);
  };

  options.flake.deploy = mkOption {
    type = rootModule;
  };
}
