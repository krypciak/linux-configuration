local o = vim.o
local g = vim.g

-- Share system clipboard with vim clipboard
cmd('set clipboard+=unnamedplus')

g.clipboard = {
    copy = {
        ['+'] = 'copy',
        ['*'] = 'copy',
    },
    paste = {
        ['+'] = 'pst',
        ['*'] = 'pst',
    },
    cache_enabled = 1,
}

o.relativenumber = true
vim.wo.number = true
o.wrap = false
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.foldmethod = 'indent'


cmd [[
    let mapleader=" "

    set undofile
    set undodir=~/.cache/nvim/undo/
]]

cmd [[
    :highlight Folded ctermbg=237
    :highlight Pmenu ctermbg=233 ctermfg=254
    
    :highlight PmenuSel ctermbg=238 ctermfg=255
]]

-- Return to last edit position when opening files
cmd [[
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
]]


cmd [[
set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine ctermbg=235
]]

cmd [[
set ff=unix
set redrawtime=0
]]
