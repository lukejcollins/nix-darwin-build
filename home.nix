{
  home = {
    sessionVariables = {
      EDITOR = "vim";
    };
    stateVersion = "23.11"; # Make sure this matches the Nixpkgs version you are using
    file.".config/yabai/yabairc".source = ./dotfiles/yabai/yabairc;
  };

  # Note: Zsh is not enabled here as it's managed by Nix Darwin instead
}
