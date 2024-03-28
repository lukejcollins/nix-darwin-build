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
    vim git gh alacritty wget docker nodejs python3 python3Packages.pip zellij pet
    shfmt postgresql docker-compose tailscale uebersicht gcc direnv neofetch colima
    raycast python3Packages.python-lsp-server rnix-lsp nodePackages.bash-language-server
    dockerfile-language-server-nodejs terraform-ls clippy awscli2 typst utm fzf spotify
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
        epkgs.doom-modeline epkgs.grip-mode epkgs.company epkgs.elfeed epkgs.elfeed-protocol
        epkgs.catppuccin-theme epkgs.codeium
      ];
    })
    # (vscode-with-extensions.override {
    #  vscodeExtensions = with vscode-extensions; [
    #    github.copilot
    #    github.copilot-chat
    #  ];
    #})
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
      extraConfig = "/Users/lukecollins/.config/yabai/yabairc";
    };

    # Enable skhd
    skhd = {
      enable = true;
      package = pkgs.skhd;
    };

    # Enable tailscale
    tailscale = {
      enable = true;
    };
  };

  # Enable wallpaper service
  launchd.user.agents = { 
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

  # System configuration
  system = {
    stateVersion = 4;
    defaults = {
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      dock = {
        wvous-tl-corner = 1; # Top left corner
        wvous-tr-corner = 1; # Top right corner
        wvous-bl-corner = 1; # Bottom left corner
        wvous-br-corner = 1; # Bottom right corner
        autohide = true;
        autohide-delay = 86400.0;
      };
    };
    activationScripts.extraActivation.text = ''
      softwareupdate --install-rosetta --agree-to-license
    '';
  };
}
