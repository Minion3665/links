{
  description = "A flake to print out my socials when run";

  outputs = { self, nixpkgs }: let
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    echoScript = path: lib.pipe path [
      builtins.readFile
      (lib.replaceStrings ["\\" "\""] ["\\\\" "\\\""])
      (textToEcho: ''
        echo "${textToEcho}"
      '')
    ];
  in {
    packages = forAllSystems (system: {
    	links = nixpkgs.legacyPackages.${system}.writeShellScriptBin
	  "links"
	  (echoScript ./links.txt);
        default = self.packages.${system}.links;
    });
  };
}
