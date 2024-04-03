{ lib, pkgs, modulesPath, inputs, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/79136d92-c8e9-4bb3-83f3-6c4cf33ace32";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7793-2667";
      fsType = "vfat";
    };
  };


  swapDevices = [{
    device = "/dev/disk/by-uuid/218337e4-3f20-46c2-8422-e81762af1d80";
  }];

  networking.useDHCP = true;
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-linux";
    overlays = [
      inputs.nix-minecraft.overlay
    ];
  };
  nix = {
    extraOptions = "experimental-features = nix-command flakes";

    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = [
      "xhci_pci"
      "virtio_pci"
      "virtio_scsi"
      "usbhid"
      "sr_mod"
    ];
  };

  time.timeZone = "Europe/Frankfurt";

  i18n.defaultLocale = "en_IE.UTF-8";

  environment.systemPackages = lib.attrValues {
    inherit (pkgs)
      neovim
      wget
      git;
  };

  services = {
    openssh.enable = true;
    minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers.vanilla = {
        enable = true;
        package = pkgs.vanillaServers.vanilla-1_20_4;
      };
    };
  };

  system.stateVersion = "23.11";
}
