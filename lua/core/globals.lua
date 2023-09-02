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

vim.g.is_win = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
vim.g.is_linux = vim.fn.has("unix") == 1 and vim.fn.has("win64") ~= 1
vim.g.is_mac = vim.fn.has("macunix") == 1

if vim.fn.executable("python3") then
    if vim.g.is_win then
        vim.g.python3_host_prog = string.gsub(vim.fn.exepath("python3"), ".exe$", "")
    elseif vim.g.is_linux or vim.g.is_mac then
        vim.g.python3_host_prog = vim.fn.exepath("python3")
    end
else
    error("Python 3 executable not found! You must install Python 3 and set its PATH correctly!")
end

vim.g.mapleader = " "
vim.g.vimsyn_embed = "1"
vim.fn.execute("language en_US.utf-8")
