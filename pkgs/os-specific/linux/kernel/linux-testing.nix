{ stdenv, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:

with stdenv.lib;

buildLinux (args // rec {
  version = "5.5-rc4";
  extraMeta.branch = "5.5";

  # modDirVersion needs to be x.y.z, will always add .0
  modDirVersion = if (modDirVersionArg == null) then builtins.replaceStrings ["-"] [".0-"] version else modDirVersionArg;

  src = fetchurl {
    url = "https://git.kernel.org/torvalds/t/linux-${version}.tar.gz";
    sha256 = "4bfdffa214d656bc9e5a830700d3f79b8f0dd2551f43d0b84a42e8d6f0cffde3";
  };

  # Should the testing kernels ever be built on Hydra?
  extraMeta.hydraPlatforms = [];

} // (args.argsOverride or {}))
