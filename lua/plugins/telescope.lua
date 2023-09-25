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

-- https://github.com/nvim-telescope/telescope.nvim

local function setup()
    local builtin = require("telescope.builtin")

    vim.keymap.set(
        "n",
        "<leader>ff",
        function () builtin.find_files({ hidden = true, }) end
    )
    vim.keymap.set(
        "n",
        "<leader>fr",
        function () builtin.oldfiles({ hidden = true, }) end
    )
    vim.keymap.set(
        "n", "<leader>fg", function ()
            builtin.live_grep(
                {
                    additional_args = function (_)
                        return {
                            "--hidden",
                            "--iglob=!.venv",
                            "--iglob=!vendor",
                            "--iglob=!.git",
                        }
                    end,
                }
            )
        end
    )
    vim.keymap.set("n", "<leader>fb", builtin.buffers)
end

return setup
