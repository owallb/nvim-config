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

    local lspkind
    utils.try_require("lspkind", module_name, function (module)
        lspkind = module
    end)

    local opt = {
        enabled = function ()
            local context = require "cmp.config.context"
            if vim.api.nvim_get_mode().mode == "c" then
                -- keep command mode completion enabled
                return true
            elseif context.in_treesitter_capture("comment") or
                context.in_syntax_group("Comment") then
                -- disable completion in comments
                return false
            else
                -- enable only if cursor is at the end of a word
                return has_words_before() and not has_words_after()
            end
        end,
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
                    if cmp.visible() and not has_words_after() then
                        cmp.select_next_item()
                        -- elseif luasnip.expand_or_jumpable() then
                        --     luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { "i", "s", }
            ),
            ["<S-Tab>"] = cmp.mapping(
                function (fallback)
                    if cmp.visible() and not has_words_after() then
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
            -- { name = "luasnip", },
            { name = "nvim_lua", },
            { name = "orgmode", },
            { name = "path", },
            -- { name = 'buffer' },
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
