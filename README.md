# System Reqiurements
These are the requirements to make use of this neovim configuration. Currently only supports GNU/Linux.
    
*Note: You may try using windows, but last time I checked there was a problem with the completion engine (nvim-cmp) that makes it impossible to traverse the drop-down list.*

- curl or wget
- unzip
- gzip
- git
- tar

## Language Server dependencies
Some language servers included in this config requires some additional software. Without these installed, you will get a warning and the servers will not be enabled. If you don't need them, and want to get rid of the warning, you may either remove them in `lua/lsp/servers/init.lua` or disable them in `lua/lsp/servers/<server>.lua`.

- **bashls**: npm, shellcheck
- **diagnosticls**: npm
