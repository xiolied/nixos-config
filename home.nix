{
  config,
  pkgs,
  inputs,
  ...
}: 
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in 

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  home.username = "oli";
  home.homeDirectory = "/home/oli";
  home.stateVersion = "26.05";

  services.swayosd.enable = true;

  #Symmlinks
  home.file.".config/sway".source = ./home-manager-dotfiles/sway;
  home.file.".config/swayosd".source = ./home-manager-dotfiles/swayosd;
  home.file.".config/waybar".source = ./home-manager-dotfiles/waybar;
  home.file.".config/clangd".source = ./home-manager-dotfiles/clangd;
  home.file.".config/scripts".source = ./home-manager-dotfiles/scripts;
  home.file.".config/rofi/themes".source = ./home-manager-dotfiles/rofi/themes;
  home.file.".config/dunst".source = ./home-manager-dotfiles/dunst;

  programs.fish = {
    enable = true;
    shellAliases = {
      skl = "appimage-run /home/oli/Games/SKLauncher/SKLauncher.AppImage";
      sn = "sudo -E nvim";
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw";
      st = "~/nixos-config/home-manager-dotfiles/scripts/sysstat.sh";
    };
    interactiveShellInit = "set fish_greeting ''";

    functions = {
      fish_prompt = {
        body = ''
          set -l dir (pwd | sed "s|$HOME|~|")
          set -l git_info ""
          if command -q git
            set -l branch (git branch --show-current 2>/dev/null)
            if test -n "$branch"
              set -l dirty ""
              git diff --quiet 2>/dev/null; or set dirty "*"
              set git_info " "(set_color --italics brblack)"#$branch$dirty"(set_color normal)
            end
          end
          echo -n "in "(set_color green)$dir(set_color normal)$git_info"  "
        '';
      };
    };
  };

  # fonts
fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font Mono"
        "JetBrainsMono NFM"              
        "Noto Sans Bengali"
      ];
      sansSerif = [
        "JetBrainsMono Nerd Font Mono"
        "JetBrainsMono NFM"
        "Noto Sans Bengali"
      ];
      serif = [
        "JetBrainsMono Nerd Font Mono"
        "JetBrainsMono NFM"
        "Noto Serif Bengali"
      ];
    };
  };


  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=14";
        pad = "5x0 center";
        resize-by-cells = "no";
      };
      colors-dark = {
        alpha = 0.90;
        background = "0a0808";
        foreground = "b4ae9e";
      };
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;

    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };

    gtk.enable = true;
    sway.enable = true;
  };

  xfconf.enable = true;
  xfconf.settings = {
    thunar = {
      "last-show-hidden" = true;
      "last-sort-folders-first" = true;
      "misc-full-directory-path" = true;
    };
  };

    programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
    theme = spicePkgs.themes.turntable;
  };

  home.packages = with pkgs; [
    bat
  ];
}
