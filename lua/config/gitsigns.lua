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

-- https://github.com/lewis6991/gitsigns.nvim

require("gitsigns").setup(
    {
        on_attach = function (bufnr)
            local gs = package.loaded.gitsigns
            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- map('n', ']c',
            --     function()
            --         gs.next_hunk{
            --             wrap=false,
            --             navigation_message=true,
            --             foldopen=true
            --         }
            --     end
            -- )
            -- map('n', '[c',
            --     function()
            --         gs.prev_hunk{
            --             wrap=false,
            --             navigation_message=true,
            --             foldopen=true
            --         }
            --     end
            -- )
            map("n", "<leader>gv", gs.select_hunk)
            -- map('n', '<C-j>', "&diff ? '<C-j>' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
            -- map('n', '<C-k>', "&diff ? '<C-k>' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})
            map({ "n", "v", }, "<leader>gr", ":Gitsigns reset_hunk<CR>") -- gs.reset_hunk() doesn't work with selected lines
            map("n", "<leader>g?", gs.preview_hunk)
            map("n", "<leader>gb", function ()
                gs.blame_line { full = true, }
            end)
            -- map('n', '<leader>gd', gs.diffthis)
        end,
        signs = {
            -- default
            -- untracked = { text = '┆' }
            untracked = { text = "│", },
        },
    }
)
