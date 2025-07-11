-- https://github.com/nvim-telescope/telescope.nvim

---@type LazyPluginSpec
return {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {
                mappings = {
                    n = {
                        q = actions.close,
                        ["<C-c>"] = actions.close,
                        ["<C-l>"] = actions.select_default,
                    },
                },
                file_ignore_patterns = {
                    "^%.git/",
                }
            },
            extensions = {
                undo = {
                    mappings = {
                        i = {
                            ["<cr>"] = require("telescope-undo.actions").yank_deletions,
                            ["<C-cr>"] = false,
                            ["<C-r>"] = false,
                            ["<C-y>"] = require("telescope-undo.actions").yank_additions,
                        },
                        n = {
                            ["u"] = false,
                        },
                    },
                },
            },
            pickers = {
                oldfiles = {
                    initial_mode = "normal",
                },
                buffers = {
                    initial_mode = "normal",
                    mappings = {
                        n = {
                            ["<C-d>"] = actions.delete_buffer
                                + actions.move_to_top,
                        },
                        i = {
                            ["<C-d>"] = actions.delete_buffer
                                + actions.move_to_top,
                        },
                    },
                },
                diagnostics = {
                    initial_mode = "normal",
                },
                lsp_definitions = {
                    initial_mode = "normal",
                },
                lsp_type_definitions = {
                    initial_mode = "normal",
                },
                lsp_implementations = {
                    initial_mode = "normal",
                },
                lsp_references = {
                    initial_mode = "normal",
                },
                git_status = {
                    initial_mode = "normal",
                },
            },
        })

        vim.keymap.set("n", "<leader>ff", function()
            builtin.find_files({
                hidden = true,
                no_ignore = true,
                no_ignore_parent = true,
                previewer = false,
            })
        end)
        vim.keymap.set("n", "<leader>fr", function()
            builtin.oldfiles({
                only_cwd = true,
                hidden = true,
                previewer = false,
            })
        end)
        vim.keymap.set("n", "<leader>fg", function()
            builtin.live_grep({
                additional_args = function(_)
                    return {
                        "--hidden",
                        "--iglob=!.venv",
                        "--iglob=!vendor",
                        "--iglob=!.git",
                    }
                end,
                previewer = true,
            })
        end)
        vim.keymap.set("n", "<leader>fb", function()
            builtin.buffers({ previewer = false, sort_mru = true })
        end)
        vim.keymap.set("n", "<leader>fd", function()
            builtin.diagnostics({
                bufnr = 0,
            })
        end)

        telescope.load_extension("fzf")
        telescope.load_extension("notify")
        vim.keymap.set("n", "<leader>fn", telescope.extensions.notify.notify)

        telescope.load_extension("undo")
        vim.keymap.set("n", "<leader>fu", telescope.extensions.undo.undo)
    end,
}
