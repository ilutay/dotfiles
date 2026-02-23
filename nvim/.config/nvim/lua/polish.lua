vim.cmd([[ 
" Move selected line vscode style
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" move to beginning/end of line
nnoremap B ^
nnoremap E $
]])
--
-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Force selection highlights after colorscheme loads
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#504945" })
    vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#504945", fg = "#ebdbb2", bold = true })
    vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#504945", fg = "#ebdbb2", bold = true })
    vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { bg = "#504945", fg = "#fe8019", bold = true })
    vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#fe8019", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })
    -- Tabline transparency with active tab highlighted
    vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#504945", fg = "#ebdbb2", bold = true })
    vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
  end,
})

-- Apply immediately on startup
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#504945" })
vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "#504945", fg = "#ebdbb2", bold = true })
vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#504945", fg = "#ebdbb2", bold = true })
vim.api.nvim_set_hl(0, "TelescopeSelectionCaret", { bg = "#504945", fg = "#fe8019", bold = true })
vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#fe8019", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FoldColumn", { bg = "NONE" })
-- Tabline transparency with active tab highlighted
vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#504945", fg = "#ebdbb2", bold = true })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })

-- Soft-wrap markdown for small screens (mosh/iPhone)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.textwidth = 0

    local opts = { buffer = true, silent = true }
    vim.keymap.set("n", "j", "gj", opts)
    vim.keymap.set("n", "k", "gk", opts)
  end,
})
