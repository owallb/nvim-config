## Requirements:

### Python
- jedi-language-server (https://github.com/pappasam/jedi-language-server)
- diagnostic-languageserver (https://github.com/iamcco/diagnostic-languageserver)
- isort
- debugpy

### Lua
- Lua LSP (https://github.com/sumneko/lua-language-server)
- LuaFormatter (https://github.com/Koihik/LuaFormatter)

### Bash
- bash-language-server
- shellcheck
- shfmt

### XML
- lemminx LSP (https://github.com/eclipse/lemminx)

### Markdown
- yarn (for initial installing through packer)

### Rust
- rust-analyzer

### Go
- go
- gopls
- golangci-lint-langserver
- golangci-lint

### C/C++
- clangd
    NOTE: Clang >= 11 is recommended! See: https://github.com/neovim/nvim-lsp/issues/23
    The file `compile_commands.json` needs to be available for clangd to work properly.
    If using CMake, it can be generated automatically using the following:
    `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1`
    See here for more info: https://clangd.llvm.org/installation#compile_commandsjson
- clang-tidy
    Reads the `.clang-tidy` configuration file if available in root of project.
    To generate a configiration file, run the following:
    ```
    $ clang-tidy -checks='clang-analyzer-*,cppcoreguidelines-*,bugprone-*,modernize-*,performance-*,readability-*' -dum
p-config > .clang-tidy
    ```
    Modify the checks as desirable.
- clang-format
    Reads the `.clang-format` configuration file if available in root of project.
    

### CMake
- cmake
- cmake-language-server (https://github.com/regen100/cmake-language-server)

### Misc
- For clipboard support, one of the following:
  - |g:clipboard|
  - pbcopy, pbpaste (macOS)
  - wl-copy, wl-paste (if $WAYLAND_DISPLAY is set)
  - xclip (if $DISPLAY is set)
  - xsel (if $DISPLAY is set)
  - lemonade (for SSH) https://github.com/pocke/lemonade
  - doitclient (for SSH) http://www.chiark.greenend.org.uk/~sgtatham/doit/
  - win32yank (Windows)
- For emoji support on Arch, instsall noto-fonts-emoji.
- pynvim (python-neovim on fedora)
- groovy-language-server (https://github.com/prominic/groovy-language-server.git)


## Optional:
- fd https://github.com/sharkdp/fd
- ripgrep https://github.com/BurntSushi/ripgrep
