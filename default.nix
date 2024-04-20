{
  lib,
  stdenvNoCC,
  gfortran13,
  blas,
  lapack,
  runCommandNoCC,
}:
let
  build =
    args:
    stdenvNoCC.mkDerivation (
      {
        version = "5.9";

        nativeBuildInputs = [ gfortran13 ];

        enableParallelBuilding = true;

        makefile = "makefile_Unix";
      }
      // args
    );
  library = build {
    pname = "slicot-reference-library";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./makefile_Unix
        ./make_Unix.inc
        ./src
        ./src_aux
      ];
    };

    buildFlags = [ "lib" ];

    installPhase = ''
      mkdir -p $out
      cp slicot.a $out/
      cp lpkaux.a $out/
    '';
  };
  examples = build {
    pname = "slicot-reference-examples";

    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./makefile_Unix
        ./make_Unix.inc
        ./examples
      ];
    };

    buildFlags = [ "example" ];

    patches = [
      ./lsame-fix.patch
      ./remove-all-bad-examples.patch
    ];

    installPhase = ''
      mkdir -p $out
      cp examples/*.exa $out/
    '';

    makeFlags = [
      "-e BLASLIB=${blas}/lib/libblas.so"
      "-e LAPACKLIB=${lapack}/lib/liblapack.so"
      "-e LPKAUXLIB=${library}/lpkaux.a"
      "-e SLICOTLIB=${library}/slicot.a"
    ];
  };
in
runCommandNoCC "slicot-reference"
  {
    outputs = [
      "out"
      "examples"
    ];

    meta = with lib; {
      description = "SLICOT - A Fortran subroutines library for systems and control";
      homepage = "https://github.com/SLICOT/SLICOT-Reference";
      license = licenses.bsd3;
      mainProgram = "slicot-reference";
      platforms = platforms.all;
    };
  }
  ''
    mkdir -p $out
    cp ${library}/slicot.a $out/
    cp ${library}/lpkaux.a $out/
    mkdir -p $examples
    cp ${examples}/*.exa $examples/
  ''
