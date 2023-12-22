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

-- https://github.com/is0n/fm-nvim

local function setup()
    local fm = require("fm-nvim")

    fm.setup({
        -- UI Options
        ui = {
            float = {
                -- Floating window border (see ':h nvim_open_win')
                border = "single",
            },
        },

        -- Terminal commands used w/ file manager (have to be in your $PATH)
        cmds = {
            nnn_cmd = "n",
        },
    })

    vim.keymap.set(
        "n",
        "<leader>fe",
        function()
            local file = vim.fn.expand("%:p")
            if file ~= "" then
                vim.cmd.Lf(file)
            else
                vim.cmd.Lf()
            end
        end
    )
end

return setup
