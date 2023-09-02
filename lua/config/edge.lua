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

vim.g.edge_style = "default"
vim.g.edge_disable_italic_comment = 0
vim.g.edge_enable_italic = 0
vim.g.edge_cursor = "auto"
vim.g.edge_transparent_background = 0
vim.g.edge_menu_selection_background = "blue"
vim.g.edge_spell_foreground = "none"
vim.g.edge_show_eob = 1
vim.g.edge_diagnostic_text_highlight = 0
vim.g.edge_diagnostic_line_highlight = 1
vim.g.edge_diagnostic_virtual_text = "grey"
vim.g.edge_current_word = "grey background"
vim.g.edge_disable_terminal_colors = 0
vim.g.edge_lightline_disable_bold = 0
vim.g.edge_better_performance = 1

vim.fn.execute("colorscheme edge")
