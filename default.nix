{ mkDerivation, base, pure-json, pure-lifted, pure-txt, text, hashable, stdenv }:
mkDerivation {
  pname = "pure-readfile";
  version = "0.8.0.0";
  src = ./.;
  libraryHaskellDepends = [ base pure-json pure-lifted pure-txt text hashable ];
  homepage = "github.com/grumply/pure-readfile";
  license = stdenv.lib.licenses.bsd3;
}
