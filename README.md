# System Reqiurements
These are the requirements to make use of this neovim configuration. Currently only supports GNU/Linux.

- Neovim 0.10 or later
- curl or wget
- unzip
- gzip
- git
- tar
    
*Note: You may try using windows, but last time I checked there was a problem with the completion engine (nvim-cmp) that makes it impossible to traverse the drop-down list.*

## Optional

The following are optional but provides additional features.

### Language Server dependencies
Some language servers included in this config requires some additional software. Without these installed, you will get a warning and the servers will not be enabled. If you don't need them, and want to get rid of the warning, you may either remove them from `lua/lsp/servers/init.lua` or disable them in `lua/lsp/servers/<server>.lua`.

- **bashls**: npm, shellcheck
- **diagnosticls**: npm

### treesitter
The treesitter CLI executable might be needed for installing some parsers. You will encounter an error if you try to install one that requires it and you don't have treesitter CLI utility installed.

### Clipboard
see `:checkhealth` and `:h clipboard`.

# License
See the included [LICENSE](LICENSE) file.
