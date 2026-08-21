{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.oli = import ./home.nix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-btw";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  services.cloudflare-warp.enable = true;

  time.timeZone = "Asia/Dhaka";

  security.pam.services.gtklock = {};

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 32767;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users.oli = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  services.tumbler.enable = true;

  programs.xfconf.enable = true;
  services.gvfs.enable = true;

  services.displayManager.ly.enable = true;

  programs.fish.enable = true;
  users.users.oli.shell = pkgs.fish;
  services.upower.enable = true;

  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse
    fuse3
    alsa-lib
    libX11
    glib
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
  ];

  environment.variables = {
    C_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
    CPLUS_INCLUDE_PATH = "${pkgs.glibc.dev}/include";
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  system.stateVersion = "26.05";
}
