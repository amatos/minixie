# minixie

A minimal NixOS scaffold for deploying with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere).

## Prerequisites

- [Nix](https://nixos.org/download) with flakes enabled
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) installed
- A target machine booted into a NixOS installer or a system with SSH access and root privileges

## Usage

### 1. Update your SSH key

In `configuration.nix`, replace the example key under `users.users.root.openssh.authorizedKeys.keys` with your own public key.

### 2. Check the disk device

`disk-config.nix` targets `/dev/nvme0n1` by default. Update `disko.devices.disk.main.device` if your target machine uses a different disk (e.g. `/dev/sda`, `/dev/vda`).

### 3. Generate hardware config (optional)

If you want hardware-specific detection via nixos-facter, run this as part of the deploy command:

```bash
nixos-anywhere \
  --flake .#minixie \
  --generate-hardware-config nixos-facter facter.json \
  root@<target-ip>
```

Skip `--generate-hardware-config` if you're happy with the existing `facter.json` or don't need it.

### 4. Deploy

```bash
nixos-anywhere --flake .#minixie root@<target-ip>
```

If you don't have nixos-anywhere installed locally, run it directly via `nix run`:

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#minixie root@<target-ip>
```

With hardware config generation:

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#minixie \
  --generate-hardware-config nixos-facter facter.json \
  root@<target-ip>
```

This will partition the disk, install NixOS, and reboot the target machine.

### 5. Update flake lock

After cloning or adding new inputs (e.g. ragenix), update the lock file:

```bash
nix flake update
```

## Installed packages

- `curl`
- `git`
- `ragenix` — age-encrypted secrets management
- `vim`

## Secrets (ragenix)

This flake includes the [ragenix](https://github.com/yaxitech/ragenix) module. To manage secrets, create a `secrets.nix` file defining your secret paths and recipient keys, then encrypt secrets with:

```bash
ragenix -e secrets/mysecret.age
```

See the [ragenix docs](https://github.com/yaxitech/ragenix) for full usage.
