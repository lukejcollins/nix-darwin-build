{ pkgs, lib, ... }:

let
  # Simple Bar Widget Installation Definition
  simpleBarWidget = pkgs.fetchFromGitHub {
    owner = "lukejcollins";
    repo = "simple-bar";
    rev = "b275b7499861590437faada2aff1a75e2a183945";
    sha256 = "sha256-IlURi4lcLUHdzH/N3wN06oFMGJstFSqDjgRHCp3h6WQ="; # Replace with the actual SHA
  };

  # Python Environment Definition
  myPythonEnv = pkgs.python3.withPackages (ps: with ps; [
    pynvim flake8 pylint black requests grip
  ]);
  
  # Powerlevel10k Installation Definition
  powerlevel10kSrc = builtins.fetchGit {
    url = "https://github.com/romkatv/powerlevel10k.git";
    rev = "017395a266aa15011c09e64e44a1c98ed91c478c";
  };

in
{
  home = {
    # Set the session variables
    sessionVariables = {
      # Set the default editor to vim
      EDITOR = "vim";
    };

    packages = with pkgs; [
      myPythonEnv
    ];

    # Set the default stateVersion to the latest version
    stateVersion = "23.11"; # Make sure this matches the Nixpkgs version you are using

    # Set the file locations for the configuration files
    file.".config/alacritty/alacritty.toml".source = ./dotfiles/alacritty/alacritty.toml;
    file.".config/yabai/yabairc".source = ./dotfiles/yabai/yabairc;
    file.".skhdrc".source = ./dotfiles/.skhdrc;
    file.".simplebarrc".source = ./dotfiles/.simplebarrc;
    file.".zshrc".source = ./dotfiles/.zshrc;
    file.".p10k.zsh".source = ./dotfiles/.p10k.zsh;
    file.".config/direnv/direnvrc".source = ./dotfiles/direnv/direnvrc;
    file.".config/zellij/config.kdl".source = ./dotfiles/zellij/config.kdl;
    file."Library/Application Support/Übersicht/widgets/simple-bar".source = simpleBarWidget;
    file."/powerlevel10k".source = powerlevel10kSrc;
  };
}
