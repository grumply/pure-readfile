{ mkDerivation, base, pure-json, pure-lifted, pure-txt, text, stdenv }:
mkDerivation {
  pname = "pure-readfile";
  version = "0.7.0.0";
  src = ./.;
  libraryHaskellDepends = [ base pure-json pure-lifted pure-txt text ];
  homepage = "github.com/grumply/pure-readfile";
  license = stdenv.lib.licenses.bsd3;
}
