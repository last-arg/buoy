with import <nixpkgs> {}; {
  buoy = stdenv.mkDerivation rec {
    name = "buoy";
    hardeningDisable = [ "all" ];
    buildInputs = [
      zig-master
      xorg.libX11
      xorg.libXrandr
      xorg.xrandr
      xorg.randrproto
      autorandr
      xorg.libXinerama
    ];
    # NOTE: There is also a config file called '.fakexinerama' in
    # user's home folder. The file defines screen areas
    # LD_PRELOAD = "${libfakeXinerama}/lib/libfakeXinerama.so.1.0";
  };
}
