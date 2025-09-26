---@class ow.dap.hover.content.Capture
---@field start_col integer
---@field end_col integer
---@field text string
---@field group string
---@field priority integer

---@class ow.dap.hover.Highlight
---@field group string
---@field start_row integer 0-indexed
---@field start_col integer 0-indexed
---@field end_row integer 0-indexed
---@field end_col integer 0-indexed

---@class ow.dap.hover.Content
---@field text string
---@field highlights ow.dap.hover.Highlight[]
---@field _current_row integer
---@field _current_col integer
local Content = {}
Content.__index = Content

---@return ow.dap.hover.Content
function Content.new()
    return setmetatable({
        text = "",
        highlights = {},
        _current_row = 0,
        _current_col = 0,
    }, Content)
end

---@return integer
function Content:current_line()
    return self._current_row + 1
end

---@param text string May not contain line breaks
---@param highlight_group? string
function Content:add(text, highlight_group)
    local start_row = self._current_row
    local start_col = self._current_col
    local end_row = self._current_row
    local end_col = start_col + #text

    self.text = self.text .. text
    self._current_col = end_col

    if highlight_group then
        table.insert(self.highlights, {
            group = highlight_group,
            start_row = start_row,
            start_col = start_col,
            end_row = end_row,
            end_col = end_col,
        })
    end
end

---@param text string May not contain line breaks
---@param lang string
function Content:add_with_treesitter(text, lang)
    local start_row = self._current_row
    local start_col = self._current_col

    self:add(text)

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

    for id, node in query:iter_captures(tree:root(), text, 0, -1) do
        local capture_name = query.captures[id]
        local start_row_rel, start_col_rel, end_row_rel, end_col_rel =
            node:range()

        local abs_start_row = start_row + start_row_rel
        local abs_end_row = start_row + end_row_rel
        local abs_start_col = start_col + start_col_rel
        local abs_end_col = start_col + end_col_rel

        table.insert(self.highlights, {
            group = "@" .. capture_name,
            start_row = abs_start_row,
            start_col = abs_start_col,
            end_row = abs_end_row,
            end_col = abs_end_col,
        })
    end
end

function Content:newline()
    self:add("\n")
    self._current_col = 0
    self._current_row = self._current_row + 1
end

---@return string[]
function Content:get_lines()
    return vim.split(self.text, "\n", { trimempty = true })
end

---@param ns_id integer
---@param buf integer
---@param row_offset integer 0-indexed
function Content:apply_highlights(ns_id, buf, row_offset)
    for _, highlight in ipairs(self.highlights) do
        vim.hl.range(
            buf,
            ns_id,
            highlight.group,
            { row_offset + highlight.start_row, highlight.start_col },
            { row_offset + highlight.end_row, highlight.end_col }
        )
    end
end

return Content
