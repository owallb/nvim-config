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

local builtin = require('telescope.builtin')

vim.keymap.set(
    'n', '<leader>ff', function() builtin.find_files({ hidden = true }) end,
    { remap = false }
)
vim.keymap.set(
    'n', '<leader>fr', function() builtin.oldfiles({ hidden = true }) end,
    { remap = false }
)
vim.keymap.set(
    'n', '<leader>fg', function()
        builtin.live_grep(
            { additional_args = function(_) return { '--hidden' } end }
        )
    end, { remap = false }
)
vim.keymap.set(
    'n', '<leader>fb', function() builtin.buffers() end, { remap = false }
)

--[[ local telescope = require('telescope')

telescope.setup {
    extensions = {
        command_palette = {
            {
                'File',
                { 'entire selection (C-a)', ':call feedkeys("GVgg")' },
                { 'save current file (C-s)', ':w' },
                { 'save all files (C-A-s)', ':wa' },
                { 'quit (C-q)', ':qa' },
                {
                    'file browser (C-i)',
                    ':lua require\'telescope\'.extensions.file_browser.file_browser()',
                    1
                },
                {
                    'search word (A-w)',
                    ':lua require(\'telescope.builtin\').live_grep()',
                    1
                },
                {
                    'git files (A-f)',
                    ':lua require(\'telescope.builtin\').git_files()',
                    1
                },
                {
                    'files (C-f)',
                    ':lua require(\'telescope.builtin\').find_files()',
                    1
                }
            },
            {
                'Help',
                { 'tips', ':help tips' },
                { 'cheatsheet', ':help index' },
                { 'tutorial', ':help tutor' },
                { 'summary', ':help summary' },
                { 'quick reference', ':help quickref' },
                {
                    'search help(F1)',
                    ':lua require(\'telescope.builtin\').help_tags()',
                    1
                }
            },
            {
                'Vim',
                { 'reload vimrc', ':source $MYVIMRC' },
                { 'check health', ':checkhealth' },
                {
                    'jumps (Alt-j)',
                    ':lua require(\'telescope.builtin\').jumplist()'
                },
                { 'commands', ':lua require(\'telescope.builtin\').commands()' },
                {
                    'command history',
                    ':lua require(\'telescope.builtin\').command_history()'
                },
                {
                    'registers (A-e)',
                    ':lua require(\'telescope.builtin\').registers()'
                },
                {
                    'colorshceme',
                    ':lua require(\'telescope.builtin\').colorscheme()',
                    1
                },
                {
                    'vim options',
                    ':lua require(\'telescope.builtin\').vim_options()'
                },
                { 'keymaps', ':lua require(\'telescope.builtin\').keymaps()' },
                { 'buffers', ':Telescope buffers' },
                {
                    'search history (C-h)',
                    ':lua require(\'telescope.builtin\').search_history()'
                },
                { 'paste mode', ':set paste!' },
                { 'cursor line', ':set cursorline!' },
                { 'cursor column', ':set cursorcolumn!' },
                { 'spell checker', ':set spell!' },
                { 'relative number', ':set relativenumber!' },
                { 'search highlighting (F12)', ':set hlsearch!' }
            }
        }
    }
}

require('telescope').load_extension('command_palette') ]]
