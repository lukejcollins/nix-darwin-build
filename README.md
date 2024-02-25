[![nix-darwin](https://img.shields.io/badge/nix-darwin-blue.svg?logo=nixos)](https://github.com/LnL7/nix-darwin) [![macOS](https://img.shields.io/badge/-macOS-green.svg?logo=apple)](https://www.apple.com/macos/) 

# Deploying nix-darwin on a New Device

This guide will walk you through deploying your nix-darwin configuration on a new device. nix-darwin is a tool for managing your macOS configuration with nix.
<img width="1800" alt="image" src="https://github.com/lukejcollins/nix-darwin-build/assets/44213313/363d0b4e-c929-4d36-b237-d80f96ea488a">

## Prerequisites

Before you begin, make sure you have the following prerequisites:

1. A macOS device.
2. Nix for macOS installed.

## Step 1: Clone Your nix-darwin Repository

Clone your nix-darwin repository to your new device. You can use a command like this:

```bash
git clone https://github.com/lukejcollins/nix-darwin-build ~/git
```

## Step 2: Update Hostname and Username

Your nix-darwin configuration will contain references to hostnames and usernames specific to your device. You'll need to update the files to match your device. Here's where you should make the changes:

### `flake.nix`

In your `flake.nix`, look for the following lines:

```nix
darwinConfigurations."OVO-VHG17X6V24" = nix-darwin.lib.darwinSystem {
  # ...
  modules = [
    # ...
    {
      users.users."luke.collins".home = "/Users/luke.collins";
    }
    # ...
  ];
};
```

Replace `"OVO-VHG17X6V24"` with your your device's hostname, and `"luke.collins"` with your username.

Ensure that any paths or configurations specific to your previous device are updated to match the paths on your new device.

## Step 3: Deploy Your Configuration

Once you've updated your configuration files, you can deploy your nix-darwin configuration on the new device. Familiarise yourself on how to do this as per the [nix-darwin repo instructions](https://github.com/LnL7/nix-darwin).

## Step 4: Additional configuration and advice (optional)

* **Raycast:** macOS Spotlight cannot locate apps installed via nix-darwin. For this I prefer to use Raycast, which can locate these applications. Raycast is installed by the default configuration of this repo. For advice on how to replace macOS Spotlight with Raycast, follow the instructions [here](https://manual.raycast.com/hotkey).
*  **Menu Bar:** In order to stop the macOS menu bar from interfering with Simple Bar, you can follow the instructions [here](https://www.howtogeek.com/700398/how-to-automatically-hide-or-show-the-menu-bar-on-a-mac/) to set the menu bar to hide automatically. The menu bar can still be accessed by moving the cursor to the top of the screen.
*  **Yabai:** The configuration for yabai (tiling window manager) is defined in `/nix-darwin-build/dotfiles/yabai/yabairc`. This configuration is quite specific to my preferences, so make sure this configured to your preferences. You will at the very least update the config directory in `darwin-configuration.nix` to be specific to your system, which should just be a matter of updating the username.
```nix
# Enable yabai
yabai = {
  enable = true;
  package = pkgs.yabai;
  extraConfig = "/Users/lukecollins/.config/yabai/yabairc";
};
```
*  **Emacs Github Copilot:** I'm using a Github Copilot plugin for Emacs. Configuration and details for this can be found [here](https://github.com/copilot-emacs/copilot.el).
*  **Everything else:** There is plenty of extra configuration to do, so dig in and check all of the files in the repo. I will update this README as time goes on to highlight particular points of interest. Feel free to raise a PR or issue to flag anything you'd like added.

## Step 5: Enjoy Your nix-darwin Setup

Your nix-darwin configuration should now be applied to your new device. Enjoy the benefits of a declarative and reproducible macOS configuration!

For more information and advanced usage of nix-darwin, refer to the [official nix-darwin documentation](https://github.com/LnL7/nix-darwin).
