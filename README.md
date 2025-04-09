My Neovim config.

## System Requirements
Only supports Linux, macOS and other BSD variants. Requires neovim v0.11.

Below is a list of dependencies and the respective plugins that require it.

| Dependency   | Plugins                                   |
| ------------ | ----------------------------------------- |
| git          | lazy, mason                               |
| C compiler   | treesitter, LuaSnip, telescope-fzf-native |
| make         | LuaSnip, telescope-fzf-native             |
| curl or wget | mason                                     |
| unzip        | mason                                     |
| GNU tar      | mason                                     |
| gzip         | mason                                     |

## Language servers
Language servers are installed automatically to the nvim data directory
(`:echo stdpath('data') .. '/mason'`) upon entering a buffer of related
filetype. Automatic installation can be turned off, see the end of this section.

Language server configurations are located at `lua/lsp/config/<server>.lua`. They can be disabled
by setting `enable = false`.

Some have additional dependencies. If any are missing, a warning is emitted and the server will
be disabled automatically. Each dependency is listed in the configuration file.

To disable automatic installation, remove the `mason` configuration.

## License
BSD-3-Clause, see [LICENSE](LICENSE) for more information.
