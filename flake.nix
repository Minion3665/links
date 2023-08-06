{
  description = "A flake to print out my socials when run";

  outputs = { self }: let
    pipe = x: fs: builtins.foldl' (val: f: f val) x fs;
    genAttrs = xs: f: pipe xs [
      (map (name: { inherit name; value = f name; }))
      builtins.listToAttrs
    ];
    forAllSystems = genAttrs [
      # Tier 1
      "x86_64-linux"
      # Tier 2
      "aarch64-linux"
      "x86_64-darwin"
      # Tier 3
      "armv6l-linux"
      "armv7l-linux"
      "i686-linux"
      "mipsel-linux"

      # Other platforms with sufficient support in stdenv which is not formally
      # mandated by their platform tier.
      "aarch64-darwin"
      "armv5tel-linux"
      "powerpc64le-linux"
      "riscv64-linux"
    ];  # List is from https://github.com/NixOS/nixpkgs/blob/master/lib/systems/flake-systems.nix
    echoScript = path: pipe path [
      builtins.readFile
      (builtins.replaceStrings ["\n" "\\" "\""] ["\\n" "\\\\" "\\\""])
      (textToEcho: ''
        echo -e "${textToEcho}"
      '')
    ];
  in {
    packages = forAllSystems (system: {
    	links = derivation {
	  inherit system;
	  name = "links";
	  builder = "/bin/sh";
	  args = [./builder.sh (echoScript ./links.txt)];
	};
        default = self.packages.${system}.links;
    });
  };
}
