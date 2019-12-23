let
  pkgs = import <nixpkgs> {};
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "b12e8296a736725690ba73831cc987ce1c016275";
  }) {
    config = import ~/.config/nixpkgs/config.nix;
  };  

  ipython = jupyter.kernels.iPythonWith {
    name = "torch-and-stuff";
    packages = p: with p; [ pytorch torchsummary ];

    python3 = let
      packageOverrides = self: super: {

        pytorch = super.pytorch.overridePythonAttrs (old: rec {
          version = "1.3.1";
          PYTORCH_BUILD_VERSION = version;
          src = pkgs.fetchFromGitHub {
            owner  = "pytorch";
            repo   = "pytorch";
            rev    = "v${version}";
            fetchSubmodules = true;
            sha256 = "07ga9806c5q02hsdybwdw9nc0r1a8dinwjakyg6wlrccclc027lq";
          };
        });

        torchsummary = self.buildPythonPackage rec {
          pname = "torchsummary";
          version = "1.5.1";

          buildInputs = [ self.pytorch ];

          src = self.fetchPypi {
            inherit pname version;
            sha256 = "14054f9cxijbl4s131lxdfm2db941br04q3lbkwzf31fwa4zc6wq";
          };

          meta = {
            homepage = "https://github.com/sksq96/pytorch-summary";
            description = "Model summary in PyTorch similar to `model.summary()` in Keras";
          };
        };

      };
    in pkgs.python37.override { inherit packageOverrides; };
  };

  jupyterEnvironment = jupyter.jupyterlabWith {
    kernels = [ ipython ];
  };
in
  jupyterEnvironment.env