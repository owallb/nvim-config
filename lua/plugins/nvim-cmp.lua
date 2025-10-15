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
            build = (
                require("util").os_name ~= "Windows_NT"
                    and "make install_jsregexp"
                or nil
            ),
            version = "2.*",
            dependencies = { "rafamadriz/friendly-snippets" },
        },
        {
            "onsails/lspkind.nvim",
            config = function()
                require("lspkind").init()
            end,
        },
        "teramako/cmp-cmdline-prompt.nvim",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        ---@type cmp.ConfigSchema
        local opts = {
            -- enabled = function()
            --     return has_words_before()
            -- end,
            preselect = "None",
            completion = {
                autocomplete = { "InsertEnter", "TextChanged" },
                keyword_length = 1,
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            ---@diagnostic disable-next-line: missing-fields
            formatting = {
                format = function(entry, vim_item)
                    vim_item = lspkind.cmp_format({
                        mode = "symbol",
                        maxwidth = 50,
                        ellipsis_char = "...",
                        before = function(_, item)
                            item.dup = 0 -- remove duplicates, see nvim-cmp #511
                            return item
                        end,
                    })(entry, vim_item)

                    return vim_item
                end,
            },

            mapping = {
                ["<tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({
                            behavior = cmp.SelectBehavior.Select,
                        })
                    else
                        fallback()
                    end
                end),
                ["<S-tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item({
                            behavior = cmp.SelectBehavior.Select,
                        })
                    else
                        fallback()
                    end
                end),
                ["<C-n>"] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<C-p>"] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<CR>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and cmp.get_active_entry() then
                        cmp.confirm({
                            select = false,
                            behavior = cmp.ConfirmBehavior.Replace,
                        })
                    else
                        fallback()
                    end
                end),
                ["<C-y>"] = cmp.mapping.confirm({
                    select = true,
                    behavior = cmp.ConfirmBehavior.Replace,
                }),
                ["<C-x><C-o>"] = cmp.mapping.complete(),
                ["<C-l>"] = function(fallback)
                    if luasnip.locally_jumpable(1) then
                        luasnip.jump(1)
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
                { name = "luasnip" },
                { name = "orgmode" },
                { name = "path" },
            },
            window = {
                completion = cmp.config.window.bordered({
                    border = "none",
                    winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None",
                    zindex = 1001,
                    scrolloff = 0,
                    col_offset = 0,
                    side_padding = 1,
                    scrollbar = true,
                }),
                documentation = cmp.config.window.bordered({
                    border = "rounded",
                    winhighlight = "CursorLine:Visual,Search:None",
                    zindex = 1001,
                    max_height = 80,
                }),
            },
        }

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
                    option = { ignore_cmds = { "!" } },
                },
            }),
        })
        -- for cmdline `input()` prompt
        -- see: `:help getcmdtype()`
        cmp.setup.cmdline("@", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                {
                    name = "cmdline-prompt",
                    ---@type prompt.Option
                    option = {
                        kinds = {
                            file = cmp.lsp.CompletionItemKind.File,
                            dir = {
                                kind = cmp.lsp.CompletionItemKind.Folder,
                                hl_group = "CmpItemKindEnum",
                            },
                        },
                    },
                },
            }),
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    local item = entry.completion_item
                    if entry.source.name == "cmdline-prompt" then
                        vim_item.kind = cmp.lsp.CompletionItemKind[item.kind]
                        local kind =
                            lspkind.cmp_format({ mode = "symbol_text" })(
                                entry,
                                vim_item
                            )
                        local strings =
                            vim.split(kind.kind, "%s", { trimempty = true })
                        kind.kind = " " .. (strings[1] or "")
                        kind.menu = " ("
                            .. (item.data.completion_type or "")
                            .. ")"
                        kind.menu_hl_group = kind.kind_hl_group
                        return kind
                    else
                        return vim_item
                    end
                end,
            },
        })
    end,
}
