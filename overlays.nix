final: prev: {

  python311 = prev.python311.override {
    packageOverrides = pyfinal: pyprev: {

      # 2.14.5 has a bug where it can't actually load datasets
      datasets = pyprev.datasets.overridePythonAttrs (old: rec {
        pname = "datasets";
        version = "2.14.6";

        src = final.fetchFromGitHub {
          owner = "huggingface";
          repo = pname;
          rev = "refs/tags/${version}";
          hash = "sha256-AncyuDiBNPVleSVsxwsJ27SJzXsvQYAVq8DOOG40rP4=";
        };
      });

      pydantic-core = pyprev.pydantic-core.overridePythonAttrs (old: rec {
        pname = "pydantic-core";
        version = "2.14.5";

        src = final.fetchFromGitHub {
          owner = "pydantic";
          repo = "pydantic-core";
          rev = "refs/tags/v${version}";
          hash = "sha256-UguZpA3KEutOgIavjx8Ie//0qJq+4FTZNQTwb/ZIgb8=";
        };

        cargoDeps = final.rustPlatform.fetchCargoTarball {
          inherit src;
          name = "${pname}-${version}";
          hash = "sha256-mMgw922QjHmk0yimXfolLNiYZntTsGydQywe7PTNnwc=";
        };
      });

      pydantic-settings = pyprev.pydantic-settings.overridePythonAttrs(old: rec {
        pname = "pydantic-settings";
        version = "2.1.0";
        format = "pyproject";

        src = final.fetchFromGitHub {
          owner = "pydantic";
          repo = "pydantic-settings";
          rev = "v${version}";
          hash = "sha256-3V6daCibvVr8RKo2o+vHC++QgIYKAOyRg11ATrCzM5Y=";
        };

        nativeBuildInputs = [
          pyfinal.hatchling
        ];

        propagatedBuildInputs = with pyfinal; [
          pydantic
          python-dotenv
        ];

        pythonImportsCheck = [ "pydantic_settings" ];

        nativeCheckInputs = with pyfinal; [
          pytestCheckHook
          pytest-examples
          pytest-mock
        ];

        preCheck = ''
          export HOME=$TMPDIR
        '';

        disabledTestPaths = [
          "tests/test_docs.py"
        ];
      });

      # dspy-ai requires 2.5.0 exactly
      pydantic = pyprev.pydantic.overridePythonAttrs (old: rec {
        pname = "pydantic";
        version = "2.5.0";
        pyproject = true;
        format = null;
        disabled = pyprev.pythonOlder "3.7";

        src = final.fetchFromGitHub {
          owner = "pydantic";
          repo = "pydantic";
          rev = "refs/tags/v${version}";
          hash = "sha256-D0gYcyrKVVDhBgV9sCVTkGq/kFmIoT9l0i5bRM1qxzM=";
        };

        buildPhase = ''
          ls -lsah
          python -m hatchling build
          mkdir -p site
        '';

        buildInputs = final.lib.optionals (pyprev.pythonOlder "3.9") [
          pyfinal.libxcrypt
        ];

        nativeBuildInputs = [
          pyfinal.hatch-fancy-pypi-readme
          pyfinal.hatchling
        ];

        propagatedBuildInputs = [
          pyfinal.annotated-types
          pyfinal.pydantic-core
          pyfinal.typing-extensions
        ];

        passthru.optional-dependencies = {
          email = [
            pyfinal.email-validator
          ];
        };

        nativeCheckInputs = [
          pyfinal.cloudpickle
          pyfinal.dirty-equals
          pyfinal.faker
          pyfinal.pytest-mock
          pyfinal.pytestCheckHook
        ] ++ final.lib.flatten (final.lib.attrValues passthru.optional-dependencies);

        preCheck = ''
          export HOME=$(mktemp -d)
          substituteInPlace pyproject.toml \
          --replace "'--benchmark-columns', 'min,mean,stddev,outliers,rounds,iterations'," "" \
          --replace "'--benchmark-group-by', 'group'," "" \
          --replace "'--benchmark-warmup', 'on'," "" \
          --replace "'--benchmark-disable'," ""
        '';

        disabledTestPaths = [
          "tests/benchmarks"

          # avoid cyclic dependency
          "tests/test_docs.py"
        ];

        pythonImportsCheck = [ "pydantic" ];
      });

      "dspy-ai" = pyprev.buildPythonPackage rec {
          name = "dspy-ai";
          version = "2.3.6";
          pname = "${name}-${version}";
          format = "pyproject";

          src = prev.fetchgit {
            inherit name;
            url = "https://github.com/stanfordnlp/dspy";
            rev = "8517db6b156c818fac6cffe2d78d8317489d1c79";
            hash = "sha256-2uNpxWi1Gqs/h6FH6Y0v4y3vzv8vad49Le0ulsyE0aE=";
          };

          nativeBuildInputs = [
            pyfinal.setuptools
          ];

          propagatedBuildInputs = with final.python311Packages; [
            backoff
            joblib
            tqdm
            regex
            openai
            pandas
            ujson
            datasets
            requests
            pydantic
            pydantic-core
            pydantic-settings
          ];

          nativeCheckInputs = [ ];

          disabledTestPaths = [ ];
      };

      usearch = pyprev.buildPythonPackage rec {
          name = "usearch";
          version = "2.9.2";
          pname = "${name}-${version}";
          format = "pyproject";

          src = prev.fetchgit {
            inherit name;
            url = "https://github.com/unum-cloud/usearch";
            rev = "f79d8180122c717203b74f7a7473964c413cb5c1";
            hash = "sha256-oiinKXpoyKAQD22FfT6qZMCw4oMzIfDfeXK9C3VuplY=";
          };

          nativeBuildInputs = with final; [
            clipp
            final.which
            final.cmake
          ];

          buildInputs = [];

          propagatedBuildInputs = [
            final.sqlite
            pyfinal.numpy
            pyfinal.pybind11
            pyfinal.setuptools
            pyfinal.tqdm
            pyfinal.wheel
          ];

          patches = [
            # We provide this :)
            ./remove-cmake.patch
          ];

          cmakeFlags = [
            "-DFETCHCONTENT_SOURCE_DIR_CLIPP=${final.clipp}"
          ];

          dontUseCmakeConfigure = true;
      };

    };
  };

  # For Usearch
  clipp = prev.fetchFromGitHub {
    owner = "muellan";
    repo = "clipp";
    rev = "4cda95d8c1536c3778773a4468a350a7ea8bcd3f";
    hash = "sha256-upyT07UR7eeDFjHHbz49bBSCEFXhiUwe25/nKdQCCGc=";
  };

}
