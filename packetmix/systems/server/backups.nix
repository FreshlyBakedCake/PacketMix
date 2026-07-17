{ config, ... }:
{
  services.borgbackup.jobs.persist = {
    paths = "/persist/data";
    encryption = {
      mode = "repokey";
      passCommand = "cat /secrets/backups/repo-passphrase.txt";
    };
    repo = "ssh://backups/./borg";
    compression = "auto,zstd";
    startAt = "*-*-* 01:00:00 Etc/UTC";
    persistentTimer = true;
  };
}
