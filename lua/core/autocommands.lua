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

local function term_close()
    -- Split previous buffer, switching to it
    vim.fn.execute("split " .. vim.fn.expand("#"))
    -- Close previous window (terminal)
    vim.fn.execute(vim.fn.winnr("#") .. "wincmd q") 
end
vim.api.nvim_create_autocmd("TermClose", {
    pattern = "term://*",
    callback = term_close
})

local function my_hl()
    -- example (default visual)
    --    highlight Visual guifg=NONE guibg=#264F78 gui=none
    -- highlight  DiffDelete guifg=#414141 guibg=#1E1E1E gui=none
    -- highlight  GitSignsChange guifg=#0C7D9D
    -- highlight IndentBlanklineContextChar guifg=#999999
    -- semshi (python highlights)
    -- highlight  semshiLocal           ctermfg=209 guifg=#ff875f
    -- highlight  semshiGlobal          guifg=#dcdcaa
    -- highlight  semshiImported        guifg=#4ec9b0
    -- highlight  semshiParameter       guifg=#9cdcfe
    -- highlight  semshiParameterUnused guifg=#72a1bb
    -- highlight  semshiFree            ctermfg=218 guifg=#ffafd7
    -- highlight  semshiBuiltin         ctermfg=207 guifg=#dcdcaa
    -- highlight  semshiAttribute       ctermfg=49  guifg=#00ffaf
    -- highlight  semshiSelf            ctermfg=249 guifg=#dcdcaa
    -- highlight  semshiUnresolved      ctermfg=226 guifg=#ffff00 cterm=underline gui=underline
    -- highlight  semshiSelected        ctermfg=231 guifg=#ffffff ctermbg=161 guibg=#d7005f
    -- highlight  semshiErrorSign       ctermfg=231 guifg=#ffffff ctermbg=160 guibg=#d70000
    -- highlight  semshiErrorChar       ctermfg=231 guifg=#ffffff ctermbg=160 guibg=#d70000
    -- sign define semshiError text=E> texthl=semshiErrorSign
end
vim.api.nvim_create_augroup("my_colors", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = my_hl,
    group = "my_colors"
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.expandtab = false
        vim.opt_local.listchars = 'tab:▏ '
        vim.opt_local.list = true
    end
})
