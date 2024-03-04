-- https://github.com/nvim-telescope/telescope.nvim

local function setup()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")

    telescope.setup({
        pickers = {
            oldfiles = {
                initial_mode = "normal",
            },
            buffers = {
                initial_mode = "normal",
                mappings = {
                    i = {
                        ["<C-d>"] = actions.delete_buffer + actions.move_to_top,
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
        },
    })

    vim.keymap.set(
        "n",
        "<leader>ff",
        function ()
            builtin.find_files({
                hidden = true,
                no_ignore = true,
                no_ignore_parent = true,
                previewer = false,
            })
        end
    )
    vim.keymap.set(
        "n",
        "<leader>fr",
        function ()
            builtin.oldfiles({
                only_cwd = true,
                hidden = true,
                previewer = false,
            })
        end
    )
    vim.keymap.set(
        "n", "<leader>fg", function ()
            builtin.live_grep({
                additional_args = function (_)
                    return {
                        "--hidden",
                        "--iglob=!.venv",
                        "--iglob=!vendor",
                        "--iglob=!.git",
                    }
                end,
                previewer = false,
            })
        end
    )
    vim.keymap.set(
        "n",
        "<leader>fb",
        function ()
            builtin.buffers({ previewer = false, })
        end
    )

    telescope.load_extension("fzf")
end

return setup
