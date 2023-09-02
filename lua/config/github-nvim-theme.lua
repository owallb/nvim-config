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

require("github-theme").setup(
    {
        theme_style = "dimmed",
        transparent = false,
        hide_end_of_buffer = false,
        hide_inactive_statusline = false,
        dark_float = true,
        dev = false,

        -- styles
        comment_style = "italic",
        function_style = "NONE",
        keyword_style = "NONE",
        msg_area_style = "NONE",
        variable_style = "NONE",

        -- sidebars
        sidebars = {
            "qf",
            "vista_kind",
            "terminal",
            "packer",
            "aerial",
            "NvimTree",
        },

        -- Change the "hint" color to the "orange" color, and make the "error" color bright red
        -- colors = { hint = 'orange', error = '#ff0000' },

        -- Overwrite the highlight groups
        -- overrides = function(c)
        --     return {
        --         htmlTag = {
        --             fg = c.red,
        --             bg = '#282c34',
        --             sp = c.hint,
        --             style = 'underline'
        --         },
        --         DiagnosticHint = { link = 'LspDiagnosticsDefaultHint' },
        --         -- this will remove the highlight groups
        --         TSField = {}
        --     }
        -- end
    }
)
