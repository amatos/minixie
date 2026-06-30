{
  modulesPath,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
  ];
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "minixie";
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.ragenix
    pkgs.vim
  ];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$oPxzAGGXHvqnKk9x$Y.baXB0nbtkJq252JfjK.bcQv0FhW2GzzCONu8/LNfVj266GnVKdevCBXvCOegIMtoRRwbhfbmRQIzjfifhEE/";
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      # change this to your ssh key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfxNl1S0Fvzh2aOAG6FuIwB96eqnUqY1nl2p2jSnTOD"
    ];
    hashedPassword = "$6$oPxzAGGXHvqnKk9x$Y.baXB0nbtkJq252JfjK.bcQv0FhW2GzzCONu8/LNfVj266GnVKdevCBXvCOegIMtoRRwbhfbmRQIzjfifhEE/";
  };

  system.stateVersion = "26.05";
}
