-- https://github.com/hrsh7th/nvim-cmp

local word_pattern = "[%w_.]"

local function has_words_before()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match(word_pattern) ~= nil
end

local function has_words_after()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col + 1, col + 1)
        :match(word_pattern) ~= nil
end

local function setup()
    local module_name = "plugins.config.cmp"
    local utils = require("utils")
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = utils.try_require("lspkind", module_name)

    local opt = {
        preselect = cmp.PreselectMode.None,
        completion = { keyword_length = 0, },
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
            ["<C-p>"] = cmp.mapping.select_prev_item({
                behavior = cmp.SelectBehavior.Select,
            }),
            ["<C-n>"] = cmp.mapping.select_next_item({
                behavior = cmp.SelectBehavior.Select,
            }),
            ["<C-y>"] = function (fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, })
                else
                    fallback()
                end
            end,
            ["<C-x><C-o>"] = cmp.mapping.complete(),
            ["<C-l>"] = function (fallback)
                if luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end,
            ["<C-h>"] = function (fallback)
                if luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end,
            ["<C-b>"] = function (fallback)
                if cmp.visible_docs() then
                    cmp.scroll_docs(-4)
                else
                    fallback()
                end
            end,
            ["<C-f>"] = function (fallback)
                if cmp.visible_docs() then
                    cmp.scroll_docs(4)
                else
                    fallback()
                end
            end,
        },
        sources = {
            { name = "nvim_lsp", },
            -- { name = "luasnip", },
            { name = "orgmode", },
            { name = "path", },
        },
    }

    utils.try_require("moonfly", module_name, function (_)
        local winhighlight = {
            winhighlight =
            "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel",
        }
        opt.window = {
            completion = cmp.config.window.bordered(winhighlight),
            documentation = cmp.config.window.bordered(winhighlight),
        }
    end)

    cmp.setup(opt)

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
end

return setup
