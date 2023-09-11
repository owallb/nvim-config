# System Reqiurements
These are the requirements to make use of this neovim configuration.

- Neovim 0.10 or later
- git
- tar

## Platform specific requirements

Windows:
- powershell
- One of the following executables needs to be available:
    - 7z
    - peazip
    - arc
    - wzszip
    - rar

Linux, macOS and other BSD variants:
- curl or wget
- unzip
- gzip

## Optional

The following are optional but provides additional features:

- make
- gcc and g++
- npm
- python3 with venv
- java JDK
- shellcheck
- jsregexp

The sections below describes this in more detail.

### Treesitter
Some parsers require tools for compilation, like `gcc` and/or `g++`. There are far too many parsers for me to list (and keep track of) all their dependencies here, but `gcc` and `g++` should cover a lot of them. You will generally encounter an error that describes if something is missing upon opening specific filetypes, because treesitter is configured to automatically install parsers when needed.

### LuaSnip
`jsregexp` is required in order to perform some [transformations](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_variable-transforms). See [here](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#transformations) for more information. 

You will need to manually install `jsregexp` on windows, while it's installed automatically on other platforms using `make` and `gcc`.

### Language servers
Language servers are installed automatically to the nvim data directory (`:echo stdpath('data') .. '/mason'`). The following are some noted requirements for the installations themselves:

- **diagnostic-languageserver**: npm
- **bash-language-server**: npm
- **cmake-language-server**: python3 with venv
- **jedi-language-server**: python3 with venv
- **groovy-language-server**: java

Some servers have additional runtime dependencies:

- **bash-language-server**: shellcheck (optional, used for linting)

If you don't need some specific language server, and want to get rid of any warning messages, you may either remove them from the top of `lua/lsp/init.lua` or disable them in `lua/lsp/config/<server>.lua`.

### Clipboard
see `:checkhealth` and `:h clipboard`.

# License
See the included [LICENSE](LICENSE) file.
