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

require("nvim_comment").setup({
    -- Linters prefer comment and line to have a space in between markers
    marker_padding = true,
    -- should comment out empty or whitespace only lines
    comment_empty = true,
    -- Should key mappings be created
    create_mappings = true,
    -- Normal mode mapping left hand side
    -- line_mapping = "<leader>cc",
    -- Visual/Operator mapping left hand side
    -- operator_mapping = "<leader>c",
    -- Hook function to call before commenting takes place
    hook = nil,
})
vim.keymap.set("n", "<leader>c", ":CommentToggle<CR>")
vim.keymap.set("v", "<leader>c", ":'<, '>CommentToggle<CR>")
