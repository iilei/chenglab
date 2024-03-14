{pkgs, ...}: {
  imports = [
    ./acme.nix
    ./cloudflared.nix
  ];

  nixarr = {
    enable = true;
    mediaDir = "/fun/media";
    stateDir = "/var/lib/nixarr";
    jellyfin.enable = true;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      intel-media-driver
      libvdpau-va-gl
      vaapiIntel
      vaapiVdpau
    ];
  };

  environment.systemPackages = with pkgs; [
    # To enable `intel_gpu_top`
    intel-gpu-tools
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "watch.chengeric.com" = {
        forceSSL = true;
        useACMEHost = "chengeric.com";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
        };
      };
    };
  };

  systemd.tmpfiles.rules = ["d /var/lib/nixarr 0755 root root"];

  fileSystems."/var/lib/nixarr" = {
    device = "/nix/persist/var/lib/nixarr";
    fsType = "none";
    options = ["bind"];
  };
}
