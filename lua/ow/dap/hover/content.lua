-- Highlighted text content builder for DAP tree display
local log = require("ow.log")
---@class ow.dap.hover.content.Capture
---@field start_col integer
---@field end_col integer
---@field text string
---@field group string
---@field priority integer

---@class ow.dap.hover.Highlight
---@field group string Highlight group name
---@field start_col integer Start column (0-indexed)
---@field end_col integer End column (0-indexed)

---@class ow.dap.hover.Content
---@field text string The complete text content
---@field highlights ow.dap.hover.Highlight[] List of highlights to apply
---@field _current_col integer Current column position (for building)
local Content = {}
Content.__index = Content

---Create new highlighted content
---@return ow.dap.hover.Content
function Content.new()
    return setmetatable({
        text = "",
        highlights = {},
        _current_col = 0,
    }, Content)
end

---Add text with optional highlighting
---@param text string Text to add
---@param highlight_group? string Optional highlight group
function Content:add(text, highlight_group)
    local start_col = self._current_col
    local end_col = start_col + #text

    self.text = self.text .. text
    self._current_col = end_col

    if highlight_group then
        table.insert(self.highlights, {
            group = highlight_group,
            start_col = start_col,
            end_col = end_col,
        })
    end
end

---Add text with tree-sitter syntax highlighting
---@param text string The text to highlight
---@param lang string Language for tree-sitter
function Content:add_with_treesitter(text, lang)
    local start_col = self._current_col

    -- First, just add the text normally
    self:add(text)

    -- Then apply tree-sitter highlights on top
    local ok, parser = pcall(vim.treesitter.get_string_parser, text, lang)
    if not ok or not parser then
        return
    end

    local tree = parser:parse()[1]
    if not tree then
        return
    end

    local query = vim.treesitter.query.get(lang, "highlights")
    if not query then
        return
    end

    -- Add highlights for all captures (overlapping is fine)
    for id, node in query:iter_captures(tree:root(), text, 0, -1) do
        local capture_name = query.captures[id]
        local start_row, start_col_rel, end_row, end_col_rel = node:range()

        -- TODO: keep track of text as lines instead, so we can handle multiline
        --       highlights
        if start_row == end_row then -- Single line only
            -- Convert to absolute column positions
            local abs_start_col = start_col + start_col_rel
            local abs_end_col = start_col + end_col_rel

            -- Add the highlight
            table.insert(self.highlights, {
                group = "@" .. capture_name,
                start_col = abs_start_col,
                end_col = abs_end_col,
            })
        end
    end
end

---Add a newline and reset column tracking
function Content:newline()
    self:add("\n")
    self._current_col = 0
end

---Get the lines as a table
---@return string[]
function Content:get_lines()
    return vim.split(self.text, "\n", { trimempty = true })
end

---Apply highlights to a buffer
---@param ns_id integer
---@param buf integer Buffer handle
---@param line_offset? integer Line offset to apply highlights at (default 0)
function Content:apply_highlights(ns_id, buf, line_offset)
    line_offset = line_offset or 0
    local lines = self:get_lines()
    local current_line = 0
    local line_start_col = 0

    for _, highlight in ipairs(self.highlights) do
        -- Find which line this highlight belongs to
        while
            current_line < #lines - 1
            and highlight.start_col
                >= line_start_col + #lines[current_line + 1] + 1
        do
            line_start_col = line_start_col + #lines[current_line + 1] + 1 -- +1 for newline
            current_line = current_line + 1
        end

        -- Calculate column positions relative to line start
        local start_col = highlight.start_col - line_start_col
        local end_col = highlight.end_col - line_start_col

        -- Apply highlight
        vim.hl.range(
            buf,
            ns_id,
            highlight.group,
            { line_offset + current_line, start_col },
            { line_offset + current_line, end_col }
        )
    end
end

return Content
