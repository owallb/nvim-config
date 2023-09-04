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

-- https://github.com/Yggdroot/indentLine

-- more options at https://www.jetbrains.com/lp/mono/
vim.g.indentLine_char = "▏"
-- Disable conceal for some syntax plugins
vim.g.vim_json_conceal = 0
vim.g.markdown_syntax_conceal = 0
vim.g.indentLine_fileTypeExclude = { "NvimTree", }
