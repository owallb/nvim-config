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

-- https://github.com/iamcco/markdown-preview.nvim

vim.g.mkdp_filetypes = { "markdown", }
vim.g.mkdp_port = "9080"
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_open_ip = "192.168.2.22"
vim.g.mkdp_open_to_the_world = 1
