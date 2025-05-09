local version = vim.version()

if version.major == 0 then
    if version.minor < 11 then
        error("Neovim version 0.11 or above is required with this configuration.")
    end
end

local utils = require("ow.utils")

-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    utils.assert_installed("git")
    if not os.getenv("CC") then
        utils.assert_installed("cc")
    end
    utils.assert_installed("make")
    utils.assert_any_installed({ "curl", "wget", })
    utils.assert_installed("unzip")
    utils.assert_installed("tar")
    utils.assert_installed("gzip")

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
