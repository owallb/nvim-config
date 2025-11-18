-- https://github.com/nvim-telescope/telescope.nvim

---@type LazyPluginSpec
return {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        "rcarriga/nvim-notify",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")
        local utils = require("telescope.utils")

        telescope.setup({
            defaults = {
                mappings = {
                    n = {
                        q = actions.close,
                        ["<C-c>"] = actions.close,
                        ["<C-l>"] = actions.select_default,
                        ["<C-u>"] = actions.results_scrolling_up,
                        ["<C-d>"] = actions.results_scrolling_down,
                    },
                },
                file_ignore_patterns = {
                    "^%.git/",
                },
                layout_config = {
                    height = 30,
                    width = 80,
                    scroll_speed = 3,
                },
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
                            ["<C-x>"] = actions.delete_buffer,
                        },
                    },
                },
                live_grep = {
                    layout_config = {
                        width = 160,
                        preview_width = 80,
                    },
                },
                highlights = {
                    layout_config = {
                        width = 160,
                        preview_width = 80,
                    },
                },
                diagnostics = {
                    initial_mode = "normal",
                    layout_config = {
                        width = 160,
                        preview_width = 80,
                    },
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
                    layout_config = {
                        width = 160,
                        preview_width = 80,
                    },
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
        vim.keymap.set("n", "<leader>fG", function()
            builtin.live_grep({
                additional_args = function(_)
                    return {
                        "--hidden",
                        "--iglob=!.venv",
                        "--iglob=!vendor",
                        "--iglob=!.git",
                    }
                end,
                cwd = utils.buffer_dir(),
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
        vim.keymap.set("n", "<leader>fn", function()
            telescope.extensions.notify.notify({
                initial_mode = "normal",
                layout_config = {
                    width = 160,
                    preview_width = 80,
                },
            })
        end)

        telescope.load_extension("undo")
        vim.keymap.set("n", "<leader>fu", function()
            telescope.extensions.undo.undo({
                initial_mode = "normal",
                layout_config = {
                    width = 160,
                    preview_width = 80,
                },
            })
        end)
    end,
}
