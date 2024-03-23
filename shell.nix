{
  system ? builtins.currentSystem,
  nixpkgs ?
    fetchTarball "https://github.com/NixOS/nixpkgs/archive/057f9aecfb71c4437d2b27d3323df7f93c010b7e.tar.gz"
}:

let

pkgs = import nixpkgs {

  inherit system;
  config = {};
  overlays = [ (import ./overlays.nix) ];

};

# Models are stored in $HOME/.ollama/models
# It doesn't seem this location can be changed currently
OLLAMA_MODELS = [
  "mistral:7b-instruct-v0.2-q6_K"
  "llama2:7b-chat-q4_0"
];

python = pkgs.python311.withPackages (python-pkgs: [
  python-pkgs.dspy-ai
  python-pkgs.numpy
  python-pkgs.pandas
  python-pkgs.usearch
]);

in

pkgs.mkShellNoCC {

  nativeBuildInputs = with pkgs; [
    bashInteractive
  ];

  buildInputs = [
    pkgs.ollama
    python
  ];

  shellHook = ''
    mkdir .nix-shell
    export NIX_SHELL_DIR=$PWD/.nix-shell

    ollama serve &
    OLLAMA_PID=$!

    trap \
      "
        kill $OLLAMA_PID
        cd $PWD
        rm -rf $NIX_SHELL_DIR
      " \
      EXIT

    # Wait for api calls to ollama to work
    ollama list
    while [ ! $? ]; do
        ollama list
    done

    AVAILABLE_MODELS=$(ollama list | tail +2 | cut -f 1)
    for model in ${builtins.toString OLLAMA_MODELS}; do
        if ! grep -c $model <<< "$AVAILABLE_MODELS"; then
            ollama pull $model
        fi
    done
  '';

  # Fix language/locale problems
  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
}
