{ mkDerivation, base, ghcjs-base, pure-default, pure-lifted, pure-txt, stdenv }:
mkDerivation {
  pname = "pure-readfile";
  version = "0.7.0.0";
  src = ./.;
  libraryHaskellDepends = [ base ghcjs-base pure-default pure-lifted pure-txt ];
  homepage = "github.com/grumply/pure-readfile";
  license = stdenv.lib.licenses.bsd3;
}
