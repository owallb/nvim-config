--[[
    Copyright 2023 Oscar Wallberg

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-- https://github.com/folke/noice.nvim

require("noice").setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    -- bottom_search = true, -- use a classic bottom cmdline for search
    -- command_palette = true, -- position the cmdline and popupmenu together
    -- long_message_to_split = true, -- long messages will be sent to a split
    -- inc_rename = false, -- enables an input dialog for inc-rename.nvim
    -- lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})
