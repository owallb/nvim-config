-- https://github.com/nvim-orgmode/orgmode

local function setup()
    local orgmode = require("orgmode")
    orgmode.setup({
        org_agenda_files = { "~/Documents/org/**/*", },
        org_default_notes_file = "~/Documents/org/notes.org",
        org_todo_keywords = {
            "TODO(t)",
            "ACTIVE(a)",
            "WAITING(w)",
            "|",
            "DONE(d)",
            "DISCARDED(c)",
        },
        org_todo_keyword_faces = {
            ACTIVE = ":foreground dodgerblue :weight bold",
            WAITING = ":foreground lightgoldenrod :weight bold",
            DISCARDED = ":foreground grey :weight bold",
        },
        win_split_mode = "float",
        win_border = "single",
        org_archive_location = "~/Documents/org/archive.org::",
        org_log_done = "note",
        org_log_into_drawer = "LOGBOOK",
        org_highlight_latex_and_related = "entities",
        org_agenda_span = "week",
        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,

    })
end

return setup
