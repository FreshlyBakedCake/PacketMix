# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  project,
  config,
  system,
  pkgs,
  ...
}:
{
  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.minion = {
    isNormalUser = true;
    description = "Skyler Grey";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };
  users.users.coded = {
    isNormalUser = true;
    description = "Samuel Shuert";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    git
    helix
    jujutsu
    chromium
    (pkgs.gtimelog.overrideAttrs (oldAttrs: {
      src = project.inputs.collabora-gtimelog.src;
      makeWrapperArgs = [
        "--set GIO_MODULE_DIR ${
          lib.makeSearchPathOutput "out" "lib/gio/modules" (
            with pkgs;
            [
              glib-networking
            ]
          )
        }"
        "--set GI_TYPELIB_PATH ${
          lib.makeSearchPathOutput "out" "lib/girepository-1.0" [
            gtk3
            libsoup_2_4
            glib
            pango
            harfbuzz
            gdk-pixbuf
            atk
            libsecret
          ]
        }"
      ];
      postInstall = ''
        install -Dm644 gtimelog.desktop $out/share/applications/gtimelog.desktop
        install -Dm644 src/gtimelog/gtimelog.png $out/share/icons/hicolor/48x48/apps/gtimelog.png
      '';
      buildInputs = oldAttrs.buildInputs ++ [ pkgs.glib-networking ];
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.gobject-introspection ];
    }))
    dogdns
    ghostty
    (project.inputs.npins.result { inherit pkgs system; })
    thunderbird
    difftastic
    meld
    wl-clipboard
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  services.tailscale.enable = true;
}
