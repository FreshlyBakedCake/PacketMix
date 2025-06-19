{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
  };
  services.nextjs-ollama-llm-ui = {
    enable = true;
    port = 1144;
  };
}
