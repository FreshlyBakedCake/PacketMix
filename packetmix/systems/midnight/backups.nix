{
  programs.ssh.extraConfig = ''
    Host backups
      HostName u526469-sub2.your-storagebox.de
      User u526469-sub2
      IdentityFile /secrets/backups/id_ed25519
      Port 23
  '';

  programs.ssh.knownHosts."[u526469-sub2.your-storagebox.de]:23".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
}
