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

local version = vim.version()

if version.major == 0 then
    if version.minor < 10 then
        error("Neovim version 0.10 or above is required with this configuration.")
    end
end

local utils = require("utils")

-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    if utils.os_name == "Linux" then
        utils.assert_any_available({ "curl", "wget", })
        utils.assert_available("unzip")
        utils.assert_available("gzip")
    elseif utils.os_name == "Windows_NT" then
        utils.assert_any_available({ "pwsh", "powershell", })
        utils.assert_any_available({ "7z", "peazip", "arc", "wzzip", "rar", })
    else
        error("OS not supported: " .. utils.os_name)
    end

    utils.assert_available("git")
    utils.assert_available("tar")

    local resp = vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }):wait()

    assert(resp.code == 0, "Failed to download lazy")
end
vim.opt.rtp:prepend(lazypath)
