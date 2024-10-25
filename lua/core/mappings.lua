--- Tab mappings ---
vim.keymap.set("n", "tn", vim.cmd.tabnew)
vim.keymap.set("n", "tq", vim.cmd.tabclose)
-- switch tabs with Ctrl+PgUp/Ctrl+PgDwn (default vim mapping)

--- Buffer mappings ---
-- Center cursorline
vim.keymap.set("n", "<leader><leader>", "zz")
-- Save buffer
vim.keymap.set("n", "<C-s>", function ()
    vim.cmd.write({ mods = { silent = true, }, })
end)
-- Cycle buffers
vim.keymap.set("n", "<C-End>", vim.cmd.bnext)
vim.keymap.set("n", "<C-Home>", vim.cmd.bprev)

--- Navigation ---
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- nnoremap <expr> j v:count ? 'j' : 'gj'
-- nnoremap <expr> k v:count ? 'k' : 'gk'

--- General mappings ---
-- yank/put using named register
vim.keymap.set({ "n", "x", }, "<leader>y", '"+y')
vim.keymap.set({ "n", "x", }, "<leader>p", '"+p')
vim.keymap.set({ "n", "x", }, "<leader>P", '"+P')
vim.keymap.set({ "n", "x", }, "<leader>+", function ()
    vim.fn.setreg("+", vim.fn.getreg('"'))
end)

-- Allow exiting insert mode in terminal by hitting <ESC>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Use :diffput/get instead of normal one to allow staging visual selection
vim.keymap.set("n", "<leader>dp", vim.cmd.diffput)
vim.keymap.set("x", "<leader>dp", ":diffput<CR>")
vim.keymap.set("n", "<leader>do", vim.cmd.diffget)
vim.keymap.set("x", "<leader>do", ":diffget<CR>")
vim.keymap.set({ "n", "i", }, "<C-e>",
    function ()
        if vim.fn.pumvisible() ~= 0 then
            return "<cmd>pclose<cr>"
        end

        for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).relative ~= "" then
                return "<cmd>fclose<cr>"
            end
        end

        return "<C-e>"
    end,
    { expr = true, }
)

-- Allow (de)indenting without deselecting
vim.keymap.set({"x"}, "<", "<gv")
vim.keymap.set({"x"}, ">", ">gv")

-- Remove default mappings
vim.keymap.set("", "<C-LeftMouse>", "")
vim.keymap.set({ "n", }, "K", "")

-- Remove right-click menu items
vim.cmd.aunmenu({ "PopUp.-1-", })
vim.cmd.aunmenu({ "PopUp.How-to\\ disable\\ mouse", })

-- Insert-mode Emacs bindings
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-a>', '<C-o>^')
vim.keymap.set('i', '<C-e>', '<C-o>$')
vim.keymap.set('i', '<C-k>', '<C-o>C')
vim.keymap.set('i', '<C-d>', '<C-o>x')
vim.keymap.set('i', '<M-f>', '<C-o>w')
vim.keymap.set('i', '<M-b>', '<C-o>b')
vim.keymap.set('i', '<M-d>', '<C-o>dw')
vim.keymap.set('i', '<M-BS>', '<C-o>db')

-- Command-mode Emacs bindings
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
-- vim.keymap.set('c', '<C-k>', '???')
vim.keymap.set('c', '<C-d>', '<Delete>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<M-f>', '<C-Right>')
vim.keymap.set('c', '<M-b>', '<C-Left>')
vim.keymap.set('c', '<M-d>', '<C-Right><C-w>')
vim.keymap.set('c', '<M-BS>', '<C-w>')

-- Default bindings that are good to know:
-- insert mode:
--  <C-T>           - indent, see :h i_CTRL-T
--  <C-D>           - un-indent, see :h i_CTRL-D
-- normal mode:
--  <count?><C-E>   - scroll window down <count> lines, see :h CTRL-E
--  <count?><C-Y>   - scroll window up <count> lines, see :h CTRL-Y
--  <C-A>           - Increment
--  <C-X>           - Decrement
--  <C-w>H          - Move window to the left
--  <C-w>J          - Move window down
--  <C-w>K          - Move window up
--  <C-w>L          - Move window to the right
-- commands:
--  :make           - execute makeprg with given args
--  :copen          - open quickfix list
--  :cdo {cmd}      - execute {cmd} in each valid entry in the quickfix list.
--                    works like this:
--                      :cfirst
--                      :{cmd}
--                      :cnext
--                      :{cmd}
--                      etc.
--  :cn             - go to the next error in quickfix list that includes a file name
--  :cp             - go to the previous error in quickfix list that includes a file name
--  :cc [num]       - go to the specified error in quickfix list
--  @:              - repeat last command
--  :s/foo/bar/     - substitute the first match of foo with bar in the current line
--  :s/foo/bar/g    - same as above but for all matches in the current line
--  :%s/foo/bar/g   - same as above, but for all lines in buffer
--  :%s/foo/bar/gc  - same as above but asking for confirmation on each match
--  :lua << EOF     - run a lua snippet using lua-heredoc syntax
--  local tbl = {1, 2, 3}
--  for k, v in ipairs(tbl) do
--    print(v)
--  end
--  EOF
--  :diffsplit <other-file> - open diff split
