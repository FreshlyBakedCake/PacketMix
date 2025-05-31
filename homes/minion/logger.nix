{ attrToLog, ... }: {
  home.packages = builtins.trace attrToLog [];
}
