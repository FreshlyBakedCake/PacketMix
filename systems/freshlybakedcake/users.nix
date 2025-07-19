# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT
{
  users.users.coded = {
    isNormalUser = true;
    description = "Samuel Shuert";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILrwKN4dJQ0BiLmjsA/66QHhu06+JyokWtHkLcjhWU79AAAABHNzaDo= coded@Portable5cNFC"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOMSUqXuH1bQZJc9rLV0H7/UY0c2BlkzAKWkwrXFWbQ7AAAABHNzaDo= coded@ShorthairNanoResident"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHgyfY0KnxIsw8h9/cmbZ8InRFMqOmWn94teVsAHMvNkAAAABHNzaDo= coded@OcicatNanoResident"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpBNIHk/kRhQL7Nl3Fd+UBVRoS2bTpbeerA//vwL2D4 coded@passwordKey"
    ];
  };

  users.users.minion = {
    isNormalUser = true;
    description = "Skyler Grey";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIteIdlZv52nUDxW2SUsoJ2NZi/w9j1NZwuHanQ/o/DuAAAAHnNzaDpjb2xsYWJvcmFfeXViaWtleV9yZXNpZGVudA== collabora_yubikey_resident"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJRzQbQjXFpHKtt8lpNKmoNx57+EJ/z3wnKOn3/LjM6cAAAAFXNzaDppeXViaWtleV9yZXNpZGVudA== iyubikey_resident"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOhzJ0p9bFRSURUjV05rrt5jCbxPXke7juNbEC9ZJXS/AAAAGXNzaDp0aW55X3l1YmlrZXlfcmVzaWRlbnQ= tiny_yubikey_resident"
    ];
  };

  users.users.pinea = {
    isNormalUser = true;
    description = "Pinea";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFXa8ow7H8XpTrwYI+oSgLFfb6YNZanwv/QCKvEKiERSAAAABHNzaDo= pinea-yubikey"
    ];
  };
}
