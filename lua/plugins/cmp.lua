-- https://github.com/hrsh7th/nvim-cmp

local word_pattern = "[%w_.]"

local function has_words_before()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
        and vim.api
               .nvim_buf_get_lines(0, line - 1, line, true)[1]
               :sub(col, col)
               :match(word_pattern)
        ~= nil
end

local function has_words_after()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
        and vim.api
               .nvim_buf_get_lines(0, line - 1, line, true)[1]
               :sub(col + 1, col + 1)
               :match(word_pattern)
        ~= nil
end

---@type LazyPluginSpec
return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        {
            "L3MON4D3/LuaSnip",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
            build = (require("utils").os_name ~= "Windows_NT" and "make install_jsregexp" or nil),
            version = "2.*",
        },
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local utils = require("utils")
        local lspkind = utils.try_require("lspkind")

        ---@type cmp.ConfigSchema
        local opts = {
            preselect = cmp.PreselectMode.None,
            completion = {
                autocomplete = { "InsertEnter", "TextChanged" },
                keyword_length = 1,
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            formatting = {
                format = function(entry, vim_item)
                    if lspkind then
                        vim_item = lspkind.cmp_format({
                            mode = "symbol",
                            maxwidth = 50,
                            ellipsis_char = "...",
                            before = function(_, item)
                                item.dup = 0  -- remove duplicates, see nvim-cmp #511
                                return item
                            end,
                        })(entry, vim_item)
                    end

                    return vim_item
                end,
            },

            mapping = {
                ["<Tab>"] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<S-tab>"] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<C-n>"] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<C-p>"] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<CR>"] = cmp.mapping.confirm({
                    select = true,
                    behavior = cmp.ConfirmBehavior.Replace,
                }),
                ["<C-y>"] = cmp.mapping.confirm({
                    select = true,
                    behavior = cmp.ConfirmBehavior.Replace,
                }),
                ["<C-x><C-o>"] = cmp.mapping.complete(),
                ["<C-l>"] = function(fallback)
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end,
                ["<C-h>"] = function(fallback)
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end,
            },
            sources = {
                { name = "nvim_lsp" },
                -- { name = "luasnip", },
                { name = "orgmode" },
                { name = "path" },
            },
        }

        if utils.try_require("moonfly") then
            local winhighlight = {
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel",
            }
            opts.window = {
                completion = cmp.config.window.bordered(winhighlight),
                documentation = cmp.config.window.bordered(winhighlight),
            }
        end

        cmp.setup(opts)
        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
        })
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({ { name = "path" } }, {
                {
                    name = "cmdline",
                    option = { ignore_cmds = { "Man", "!" } },
                },
            }),
        })
    end,
}
