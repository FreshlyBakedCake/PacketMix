{ config, ... }: {
  config.lib.constants.undefined = config.lib.modules.when false {};
}
