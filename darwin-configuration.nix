{ config, pkgs, ... }:

let
  # Use uebersicht for desktop widgets
  uebersicht = pkgs.stdenv.mkDerivation {
    name = "uebersicht-1.6.82";
    buildInputs = [ pkgs.unzip pkgs.glibcLocales ];
    src = pkgs.fetchurl {
      url = "https://tracesof.net/uebersicht/releases/Uebersicht-1.6.82.app.zip";
      sha256 = "sha256-OdteCr8D9jkJklEclGwZuXqJ+E6+KshyGev5If/7lys=";
    };

    unpackPhase = ''
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8
      unzip $src
    '';

    installPhase = ''
      mkdir -p $out/Applications
      cp -R "Übersicht.app" $out/Applications/
    '';
  };
  
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Install packages
  environment.systemPackages = with pkgs; [
    vim git gh alacritty wget docker nodejs python3 python3Packages.pip vscode
    shfmt postgresql docker-compose tailscale uebersicht gcc direnv neofetch colima
    raycast python3Packages.python-lsp-server rnix-lsp nodePackages.bash-language-server
    dockerfile-language-server-nodejs terraform-ls
    # Install emacs with packages
    (emacsWithPackagesFromUsePackage {
      config = ./emacs/init.el;
      defaultInitFile = true;
      alwaysEnsure = true;
      alwaysTangle = true;
      package = pkgs.emacs29-macport;
      extraEmacsPackages = epkgs: [
        epkgs.use-package epkgs.terraform-mode epkgs.flycheck epkgs.flycheck-inline
        epkgs.dockerfile-mode epkgs.nix-mode epkgs.treemacs epkgs.markdown-mode
        epkgs.treemacs-all-the-icons epkgs.modus-themes epkgs.helm epkgs.vterm
        epkgs.markdown-mode epkgs.grip-mode epkgs.dash epkgs.s epkgs.editorconfig
        epkgs.autothemer epkgs.rust-mode epkgs.lsp-mode epkgs.modus-themes
        epkgs.dashboard epkgs.direnv epkgs.projectile epkgs.nerd-icons
        epkgs.doom-modeline epkgs.grip-mode epkgs.company
      ];
    })
  ];
 
  # Install fonts
  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.nerdfonts ];
  };

  # Add emacs overlay
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/d194712b55853051456bc47f39facc39d03cbc40.tar.gz";
      sha256 = "sha256:08akyd7lvjrdl23vxnn9ql9snbn25g91pd4hn3f150m79p23lrrs";
    }))
  ];

  # Services configuration
  services = {
    # Enable nix-daemon
    nix-daemon = {
      enable = true;
    };

    # Enable yabai
    yabai = {
      enable = true;
      package = pkgs.yabai;
      extraConfig = "/Users/luke.collins/.config/yabai/yabairc";
    };

    # Enable skhd
    skhd = {
      enable = true;
      package = pkgs.skhd;
    };
  };

  # Enable wallpaper service
  launchd.user.agents = { 
    wallpaper = {
      script = ''
        /usr/bin/osascript /etc/set-wallpaper.scpt
      '';
      serviceConfig = {
        StartInterval = 60;
        RunAtLoad = true;
        KeepAlive = false;
      };
    };

    # Enable Übersicht service
    ubersicht = {
      serviceConfig = {
	      Program = "/Applications/Nix Apps/Übersicht.app/Contents/MacOS/Übersicht"; 
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };

  # Enable Zsh
  programs.zsh.enable = true;

  # Move files into place
  environment.etc."set-wallpaper.scpt".source = ./applescript/set-wallpaper.scpt;

  # System configuration
  system = {
    stateVersion = 4;
    defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
    activationScripts.extraActivation.text = ''
      softwareupdate --install-rosetta --agree-to-license
    '';
  };
}
