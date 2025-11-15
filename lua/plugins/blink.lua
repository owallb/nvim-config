---@type LazyPluginSpec
return {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    -- use a release tag to download pre-built binaries
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        },
        completion = {
            documentation = {
                auto_show = true,
                window = {
                    border = "rounded",
                    winhighlight = "",
                },
            },
            ghost_text = {
                enabled = true,
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = false,
                },
            },
            menu = {
                draw = {
                    align_to = "simple_label",
                    columns = {
                        { "simple_label" },
                        { "kind_icon", "label_description", gap = 1 },
                    },
                    components = {
                        simple_label = {
                            width = { fill = true, max = 60 },
                            text = function(ctx)
                                return ctx.label
                            end,
                            highlight = function(ctx)
                                local highlights = {
                                    {
                                        0,
                                        #ctx.label,
                                        group = ctx.deprecated
                                        and "BlinkCmpLabelDeprecated"
                                        or "BlinkCmpLabel",
                                    },
                                }
                                for _, idx in ipairs(ctx.label_matched_indices) do
                                    table.insert(highlights, {
                                        idx,
                                        idx + 1,
                                        group = "BlinkCmpLabelMatch",
                                    })
                                end

                                return highlights
                            end,
                        },
                    },
                },
            },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
        },
        signature = {
            enabled = true,
            window = {
                border = "rounded",
                winhighlight = "",
                show_documentation = false,
            },
        },
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = {
                "lsp",
                "path",
                "snippets",
            },
        },
        keymap = {
            preset = "none",
            ["<Tab>"] = { "insert_next", "fallback" },
            ["<S-Tab>"] = { "insert_prev", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        },
    },
    opts_extend = { "sources.default" },
}
