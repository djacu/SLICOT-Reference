{
  lib,
  stdenv,
  gfortran13,
  blas,
  lapack,
  runCommandNoCC,
}: let
  build = args:
    stdenv.mkDerivation (rec {
        version = "5.9";

        src = lib.fileset.toSource {
          root = ./.;
          fileset =
            lib.fileset.difference
            ./.
            (lib.fileset.unions [
              ./flake.nix
              ./flake.lock
              ./default.nix
            ]);
        };

        nativeBuildInputs = [
          gfortran13
        ];

        enableParallelBuilding = true;

        makefile = "makefile_Unix";
      }
      // args);
  library = build {
    pname = "slicot-reference-library";
    buildFlags = ["lib"];

    installPhase = ''
      mkdir -p $out
      cp slicot.a $out/
      cp lpkaux.a $out/
    '';
  };
  examples = build {
    pname = "slicot-reference-examples";
    buildFlags = ["example"];

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
  runCommandNoCC
  "slicot-reference"
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
