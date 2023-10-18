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

-- https://github.com/hrsh7th/nvim-cmp

local function has_words_before()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match("%s") == nil
end

local function setup()
    local module_name = "plugins.config.cmp"
    local utils = require("utils")
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    local lspkind
    utils.try_require("lspkind", module_name, function (module)
        lspkind = module
    end)

    cmp.setup({
        enabled = function ()
            -- disable completion in comments
            local context = require "cmp.config.context"
            -- keep command mode completion enabled when cursor is in a comment
            if vim.api.nvim_get_mode().mode == "c" then
                return true
            else
                return not context.in_treesitter_capture("comment") and
                    not context.in_syntax_group("Comment")
            end
        end,
        preselect = cmp.PreselectMode.None,
        completion = { keyword_length = 3, },
        snippet = {
            expand = function (args)
                luasnip.lsp_expand(args.body)
            end,
        },
        formatting = {
            format = function (entry, vim_item)
                if lspkind then
                    vim_item = lspkind.cmp_format({
                        mode = "symbol",
                        maxwidth = 50,
                        ellipsis_char = "...",
                        before = function (_, item)
                            item.dup = 0 -- remove duplicates, see nvim-cmp #511
                            return item
                        end,
                    })(entry, vim_item)
                end

                return vim_item
            end,
        },
        experimental = { ghost_text = true, },
        mapping = {
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<CR>"] = cmp.mapping(
                function (fallback)
                    if cmp.visible() and cmp.get_selected_entry() then
                        cmp.confirm(
                            {
                                behavior = cmp.ConfirmBehavior.Replace,
                                select = true,
                            }
                        )
                    else
                        fallback()
                    end
                end, { "i", "s", }
            ),
            ["<Tab>"] = cmp.mapping(
                function (fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s", }
            ),
            ["<S-Tab>"] = cmp.mapping(
                function (fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s", }
            ),
        },
        sources = {
            { name = "nvim_lsp", },
            { name = "luasnip", },
            { name = "nvim_lua", },
            { name = "orgmode", },
            { name = "path", },
            -- { name = 'buffer' },
        },
    })

    cmp.setup.cmdline(
        "/",
        {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer", }, },
        }
    )

    cmp.setup.cmdline(
        ":",
        {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources(
                { { name = "path", }, },
                { {
                    name = "cmdline",
                    option = { ignore_cmds = { "Man", "!", }, },
                }, }
            ),
        }
    )

    utils.try_require(
        "nvim-autopairs.completion.cmp",
        module_name,
        function (cmp_autopairs)
            cmp.event:on(
                "confirm_done",
                cmp_autopairs.on_confirm_done()
            )
        end
    )
end

return setup
