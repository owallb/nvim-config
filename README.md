My Neovim config.

If you are looking to get started with Neovim, I would instead recommend one of these projects:
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [LunarVim](https://www.lunarvim.org/)
- [NvChad](https://nvchad.com/)
- [LazyVim](https://www.lazyvim.org/)
- [AstroNvim](https://astronvim.com/)


# System Requirements
Only supports Linux, macOS and other BSD variants.
These are the general requirements to get started:

- Neovim (latest git master)
- git
- tar
- curl or wget
- unzip
- gzip

If you are coming from a previous neovim configuration, it's probably also a
good idea to delete your neovim data directory. To check where it is you can
run:
```sh
nvim --headless --clean -c 'echo stdpath("data") .. "\n"|q'
```

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
- A nerd font

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

### Nerd Font
It's recommended to use a [Nerd Font](https://www.nerdfonts.com/),
v3.0.0+, otherwise some icons might not load properly.

With some terminals it's possible to use a regular font and use the
"symbols only" nerd font as fallback for icons. In those cases it should be
enough to simply install the symbols-only nerd font and it should get picked up
automatically.

#### [Kitty](https://sw.kovidgoyal.net/kitty/)
[Kitty should pick up the fallback font automatically, and it also supports
mapping specific symbols to a font](https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font).

To map it explicitly you will probably need to change the `symbol_map` for v3 to the following:
```conf
U+23FB-U+23FE,U+2630,U+2665,U+26A1,U+276C-U+2771,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0C8,U+E0CA,U+E0CC-U+E0D2,U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AD,U+E700-U+E7C5,U+EA60-U+EA88,U+EA8A-U+EA8C,U+EA8F-U+EAC7,U+EAC9,U+EACC-U+EB09,U+EB0B-U+EB4E,U+EB50-U+EBEB,U+F000-U+F00E,U+F010-U+F01E,U+F021-U+F03E,U+F040-U+F04E,U+F050-U+F05E,U+F060-U+F06E,U+F070-U+F07E,U+F080-U+F08E,U+F090-U+F09E,U+F0A0-U+F0AE,U+F0B0-U+F0B2,U+F0C0-U+F0CE,U+F0D0-U+F0DE,U+F0E0-U+F0EE,U+F0F0-U+F0FE,U+F100-U+F10E,U+F110-U+F11E,U+F120-U+F12E,U+F130-U+F13E,U+F140-U+F14E,U+F150-U+F15E,U+F160-U+F16E,U+F170-U+F17E,U+F180-U+F18E,U+F190-U+F19E,U+F1A0-U+F1AE,U+F1B0-U+F1BE,U+F1C0-U+F1CE,U+F1D0-U+F1DE,U+F1E0-U+F1EE,U+F1F0-U+F1FE,U+F200-U+F20E,U+F210-U+F21E,U+F221-U+F23E,U+F240-U+F24E,U+F250-U+F25E,U+F260-U+F26E,U+F270-U+F27E,U+F280-U+F28E,U+F290-U+F29E,U+F2A0-U+F2AE,U+F2B0-U+F2BE,U+F2C0-U+F2CE,U+F2D0-U+F2DE,U+F2E0,U+F300-U+F32F,U+F400-U+F533,U+F0001-U+F1AF0 Symbols Nerd Font Mono
```

Alternatively generate it yourself with:
```sh
fc-query /path/to/your/font.ttf --format='%{charset}\n' | sed -r 's/([0-9a-f]+)/U+\U\1/g' | sed 's/ /,/g'
```

#### [Alacritty](https://alacritty.org/)
Alacritty should automatically pick it up from the symbols-only nerd font. But
as of writing it is not possible to configure explicitly.

#### [Wezterm](https://wezfurlong.org/wezterm/index.html)
Wezterm has [built-in fallback for nerd fonts symbols](https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html),
so there's no need to install it separately. It is also possible to configure
fallbacks manually.

### Clipboard
see `:checkhealth` and `:h clipboard`.

# License
BSD-3-Clause, see [LICENSE](LICENSE) for more information.
