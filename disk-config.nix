{ lib, ... }:
let
  facterData = lib.optionalAttrs (builtins.pathExists ./facter.json) (
    builtins.fromJSON (builtins.readFile ./facter.json)
  );
  memBytes =
    if facterData ? hardware && facterData.hardware ? memory then
      (builtins.head (builtins.head facterData.hardware.memory).resources).range
    else
      null;
  swapSize = if memBytes != null then "${toString (memBytes / (1024 * 1024 * 1024) + 2)}G" else "8G"; # fallback if facter.json is absent or lacks memory info
  firstDisk =
    if facterData ? hardware && facterData.hardware ? disk && facterData.hardware.disk != [ ] then
      builtins.head facterData.hardware.disk
    else
      null;
  diskDevice =
    if firstDisk != null && firstDisk ? unix_device_names && firstDisk.unix_device_names != [ ] then
      builtins.head firstDisk.unix_device_names
    else
      "/dev/sda"; # fallback if facter.json is absent or has no disk entries
in
{
  disko.devices = {
    disk = {
      main = {
        device = diskDevice;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [ "-n" "boot" ]; # disko doesn't expose `label` for vfat; -n is mkfs.vfat's label flag
              };
            };
            swap = {
              size = swapSize;
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
                extraArgs = [ "-L" "swap" ]; # disko doesn't expose `label` for swap; pass directly to mkswap
              };
            };
            nixos = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = [ "-L" "root" ]; # disko doesn't expose `label` for ext4; pass directly to mkfs
              };
            };
          };
        };
      };
    };
  };
}
