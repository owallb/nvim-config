-- Tell neovim to prefer tmux as clipboard over xsel/xclip.
if vim.fn.getenv("TMUX") ~= vim.NIL then
    vim.fn.setenv("DISPLAY", vim.NIL)
end
