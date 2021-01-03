{ lib, fetchurl, appimageTools, pkgs }:

let
  pname = "cryptomator";
  version = "1.5.11";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/cryptomator/cryptomator/releases/download/${version}/cryptomator-${version}-x86_64.AppImage";
    name="${pname}-${version}.AppImage";
    sha256 = "985aef3f3b71c970ae04950670b80a494649b83ee2e82a6aa9f68787459f44dd";
  };

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };
in appimageTools.wrapType2 {
  inherit name src;

  multiPkgs = null; # no 32bit needed
  extraPkgs = pkgs: appimageTools.defaultFhsEnvArgs.multiPkgs pkgs ++ [ pkgs.bash pkgs.fuse ];

  extraInstallCommands = ''
    ln -s $out/bin/${name} $out/bin/${pname}
    function install_file {
      local directory=`dirname $1 | sed 's@${appimageContents}/@@g'`
      local filename=`basename $1`
      mkdir -p $out/$directory
      install -m 444 -D $1 $out/$directory/$basename
    }
    export -f install_file
    find ${appimageContents}/usr/share -type f | xargs -I{} bash -c 'install_file {}'
    
  '';

  meta = with lib; {
    description = "Free Cloud Encryption for Dropbox & Co";
    homepage = "https://cryptomator.org/";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
