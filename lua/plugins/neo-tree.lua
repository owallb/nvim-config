local function toggle_neo_tree()
    require("neo-tree.command").execute({
        action = "show",
        position = "left",
        toggle = true,
        reveal = true,
    })
end

---@type LazyPluginSpec
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    lazy = false,
    keys = {
        {
            "<leader>tt",
            toggle_neo_tree,
        },
    },
    ---@type neotree.Config?
    opts = {
        sources = {
            "filesystem",
            "git_status",
        },
        close_if_last_window = true,
        default_component_configs = {
            diagnostics = {
                symbols = {
                    hint = "H",
                    info = "I",
                    warn = "W",
                    error = "E",
                },
            },
            indent = {
                with_markers = false,
            },
            ---@diagnostic disable-next-line: missing-fields
            icon = {
                provider = function(icon, _, _)
                    icon.text = ""
                end,
            },
            modified = {
                symbol = "[+] ",
                highlight = "NeoTreeModified",
            },
            name = {
                use_git_status_colors = false,
                highlight_opened_files = true,
            },
            git_status = {
                symbols = {
                    added = "A",
                    deleted = "D",
                    modified = "M",
                    renamed = "R",
                    untracked = "?",
                    ignored = "",
                    unstaged = "",
                    staged = "+",
                    conflict = "!",
                },
            },
        },
        window = {
            mappings = {
                ["<Tab>"] = "open",
            },
        },
        filesystem = {
            check_gitignore_in_search = false,
            filtered_items = {
                show_hidden_count = false,
                hide_dotfiles = false,
                hide_gitignored = false,
                hide_by_name = { ".git" },
            },
            follow_current_file = {
                enabled = true,
            },
            hijack_netrw_behavior = "disabled",
        },
    },
    init = toggle_neo_tree,
}
