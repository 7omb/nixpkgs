{ lib
, buildPythonPackage
, cmake
, fetchFromGitHub
, gitUpdater
, ninja
, pathspec
, pyproject-metadata
, pythonOlder
, scikit-build-core

, config
, cudaSupport ? config.cudaSupport
, cudaPackages ? { }

, diskcache
, numpy
, typing-extensions
}:

buildPythonPackage rec {
  pname = "llama-cpp-python";
  version = "0.2.21";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "abetlen";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-8QfdCJs9V2Jc6ihxIvIjXjVSc9HE/XcHjrBJokuKcZI=";
    fetchSubmodules = true;
  };

  dontUseCmakeConfigure = true;
  SKBUILD_CMAKE_ARGS = lib.strings.concatStringsSep ";" (
    lib.optionals cudaSupport [ "-DLLAMA_CUBLAS=on" ]
  );

  nativeBuildInputs = [
    cmake
    ninja
    pathspec
    pyproject-metadata
    scikit-build-core
  ];

  buildInputs = (
    lib.optionals cudaSupport [ cudaPackages.cudatoolkit ]
  );

  propagatedBuildInputs = [
    diskcache
    numpy
    typing-extensions
  ];

  pythonImportsCheck = [ "llama_cpp" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "A Python wrapper for llama.cpp";
    homepage = "https://github.com/abetlen/llama-cpp-python";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
