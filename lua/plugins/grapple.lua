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

-- https://github.com/cbochs/grapple.nvim

local function setup()
    local grapple = require("grapple")
    grapple.setup()
    vim.keymap.set("n", "<leader>'", grapple.popup_tags)
    for i = 1, 9 do
        vim.keymap.set("n", "<leader>m" .. i, function ()
            grapple.tag({ key = "m" .. i, })
        end)
        vim.keymap.set("n", "<leader>" .. i, function ()
            grapple.select({ key = "m" .. i, })
        end)
    end
end

return setup
