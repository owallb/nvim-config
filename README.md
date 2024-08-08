My Neovim config.

# System Requirements
Only supports Linux, macOS and other BSD variants.
These are the general requirements to get started:

- Neovim (latest git master)
- git
- tar
- curl or wget
- unzip
- gzip

## Optional

The following are optional but provides additional features:

- make
- gcc and g++
- npm
- python3 with venv
- java runtime
- shellcheck
- php
- composer
- golang

The sections below describes this in more detail.

### Treesitter
Some parsers require tools for compilation, like `gcc` and/or `g++`. There are
far too many parsers for me to list (and keep track of) all their dependencies
here, but `gcc` and `g++` should cover a lot of them. You will generally
encounter an error that describes if something is missing upon opening specific
filetypes, because treesitter is configured to automatically install parsers
when needed.

### Language servers
Language servers are installed automatically to the nvim data directory
(`:echo stdpath('data') .. '/mason'`) upon entering a buffer of related
filetype. Automatic installation can be turned off, see the end of this section
for instructions.

Some language servers have additional dependencies. If they are missing a
warning will show up and the server will be disabled. Each dependency is listed
in the server configuration under `lua/lsp/config/<server>.lua`.

If you don't need some specific language server, you can disable them in
`lua/lsp/config/<server>.lua`.

To disable automatic installation of a selected language server, remove or
comment out the `mason` part of the configuration at `lua/lsp/config/<server>.lua`.

### Clipboard
see `:checkhealth` and `:h clipboard`.

# License
BSD-3-Clause, see [LICENSE](LICENSE) for more information.
