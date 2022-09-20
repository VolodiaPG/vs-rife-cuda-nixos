{
  description = "VS-RIFE CUDA-accelerated with mpv";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, flake-utils, nixpkgs, mach-nix, ... }@inputs:
    let
      overlay = final: prev: {
        pytorch = prev.pytorch-bin;
        mpv-unwrapped = prev.mpv-unwrapped.override {
          vapoursynthSupport = true;
        };
        mpv = final.wrapMpv final.mpv-unwrapped { youtubeSupport = true; };
      };
    in
    {
      inherit overlay;
    } // flake-utils.lib.eachDefaultSystem (system: # leverage flake-utils
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
          overlays = [ overlay inputs.nur-xddxdd.overlay ];
        };
      in
      {
        devShell = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              cudaPackages_11_6.cudatoolkit
              python310.pkgs.pytorch-bin
              mpv
              vs-rife
            ];
            shellHook = ''
              export CUDA_PATH=${pkgs.cudaPackages_11_6.cudatoolkit}
              export PATH=$CUDA_PATH:$PATH
              export CUDA_HOME=${pkgs.cudaPackages_11_6.cudatoolkit}
              export LD_LIBRARY_PATH="${pkgs.cudaPackages_11_6.cudatoolkit}/lib"
            '';
          };
      });
}
