{
  description = "Neovim configuration with LSP, DAP, and formatters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ft42.url = "github:oery/42.nix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        norminette = inputs.ft42.packages.${system}.norminette;
        c_formatter_42 = inputs.ft42.packages.${system}.c_formatter_42;
        codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;
      in {
        devShells.default = pkgs.mkShell {
          name = "neovim";

          packages = with pkgs; [
            inputs.neovim-nightly.packages.${system}.neovim

            # Rust
            rust-analyzer
            codelldb

            # Lua
            lua-language-server

            # C/C++
            clang-tools
            codelldb
            norminette
            c_formatter_42

            # Web/Node
            nodejs_20
            typescript
            typescript-language-server
            vscode-langservers-extracted
            tailwindcss-language-server

            # Common
            bear

            # Python
            (python311.withPackages (ps: [
              ps.ruff
              ps.debugpy
              ps.python-lsp-server
              ps.python-lsp-ruff
            ]))
          ];
        };
      }
    );
}
