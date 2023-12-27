-- vars
vim.o.clipboard = 'unnamedplus'
vim.g.clipboard = {
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

vim.o.relativenumber = true
vim.wo.number = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.foldmethod = 'syntax'

vim.api.nvim_set_keymap('n', '<Space>', '', {})
vim.g.mapleader = ' '

vim.o.undofile = true
vim.o.undodir = vim.fn.expand('$HOME/.cache/nvim/undo/')

vim.cmd [[
    :highlight Folded ctermbg=237
    :highlight Pmenu ctermbg=233 ctermfg=254

    :highlight PmenuSel ctermbg=238 ctermfg=255

    set cursorline
    hi cursorline cterm=none term=none
    autocmd WinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
    highlight CursorLine ctermbg=235

    set ff=unix
    set redrawtime=0
]]

-- Return to last edit position when opening files
vim.cmd [[
    autocmd BufReadPost *
         \ if line("'\"") > 0 && line("'\"") <= line("$") |
         \   exe "normal! g`\"" |
         \ endif
]]

-- Save opened folds
vim.cmd [[
    augroup remember_folds
      autocmd!
      autocmd BufWinLeave * mkview
      autocmd BufWinEnter * silent! loadview
    augroup END
]]

-- plugins
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
    'itchyny/lightline.vim',
    'nvim-telescope/telescope.nvim',
    'nvim-telescope/telescope-fzf-native.nvim',
    'nvim-treesitter/nvim-treesitter',
    'tpope/vim-surround',
    'andweeb/presence.nvim',
    'NMAC427/guess-indent.nvim',
    'Mofiqul/vscode.nvim',

    { 'neoclide/coc.nvim', build = 'npm ci' },
    'xiyaowong/coc-sumneko-lua',
    'preservim/vim-markdown',
}, {})

-- coc.nvim
vim.cmd [[
    inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
    inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
    inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
]]

-- keybindings
local function map(mode, combo, mapping, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, combo, mapping, options)
end


-- NvimTree keybindings
map('n', '<C-n>', ':NvimTreeToggle<CR>')


-- Run/Compile keybinding
map('n', '<leader>j', '', {
    noremap = true,
    callback = function()
        -- ftype = vim.bo.filetype
        -- if ftype == 'rust' then rust_run()
        -- elseif ftype == 'python' then python_run()
        -- elseif ftype == 'sh' then sh_run()
        -- else print('Unsupported filetype: '.. ftype) end
    end
})


-- Build keybinding
map('n', '<leader>k', '', {
    noremap = true,
    callback = function()
        -- ftype = vim.bo.filetype
        -- if ftype == 'rust' then rust_build()
        -- elseif ftype == 'c' then c_build()
        -- elseif ftype == 'cpp' then c_build()
        -- else print('Unsupported filetype: '.. ftype) end
    end
})


-- d stands for delete not cut
map('n', 'x', '"_x')
map('n', 'X', '"_X')
map('n', 'd', '"_d')
map('n', 'D', '"_D')
map('v', 'd', '"_d')
map('n', '<leader>d', '"+d')
map('n', '<leader>D', '"+D')
map('v', '<leader>d', '"+d')

-- quick file save/quit
map('', '<leader>q', ':q<cr>')
map('', '<leader>w', ':w<cr>')
map('', '<leader>r', ':q!<cr>')
map('', '<leader>e', ':wq<cr>')

-- set jk to <esc>
map('', '<esc>', '<nop>')
map('i', '<esc>', '<nop>')
map('', ';;', '<esc>')
map('i', ';l', '<esc>')

map('n', '<leader>t', ':set wrap!<cr><C-L>')
map('n', '<leader>l', ':noh<cr><C-L>')
map('n', '<leader>a', '<cmd>Telescope find_files<cr>')
map('', '<leader>z', ':%y<cr>')

map('n', '[d', '<Plug>(coc-diagnostic-prev-error)')
map('n', ']d', '<Plug>(coc-diagnostic-next-error)')
map('n', '[f', '<Plug>(coc-diagnostic-prev)')
map('n', ']f', '<Plug>(coc-diagnostic-next)')

map('n', '<leader>gD', '<Plug>(coc-declaration)')
map('n', '<leader>gd', '<Plug>(coc-definition)')

map('n', 'K', ':call CocActionAsync("doHover")<cr><C-L>')

map('n', '<leader>s', '<Plug>(coc-rename)')
map('n', '<leader>ca', '<Plug>(coc-codeaction)')
map('n', '<leader>gr', '<Plug>(coc-references)')
map('n', '\\f', '<Plug>(coc-format)')

-- python
vim.cmd(':autocmd FileType python :inoremap <buffer> this self')

-- rust
vim.cmd(':autocmd FileType rust :inoremap <buffer> pri println!(')

-- typescript

function ImpactClass()
    local name = vim.fn.input("Interface name: ")
    local extends = vim.fn.input("Extends: ")
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {
        'interface ' .. name .. (extends ~= '' and ' extends ' .. extends or ' ') .. '{', '}',
        'interface ' .. name .. 'Constructor extends ImpactClass<' .. name .. '> {',
        'new (): ' .. name,
        '}',
        'var ' .. name .. ': ' .. name .. 'Constructor',
    })
    vim.lsp.buf.format()
end

vim.cmd(':autocmd FileType typescript command! ImpactClass lua ImpactClass()')

function TypedefsBeg()
    vim.cmd('normal G$o')
    vim.cmd('normal xxx')
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {
        '',
        'export {}',
        '',
        'declare global {',
        'namespace sc {}',
        'namespace ig {}',
        '}'
    })
    vim.lsp.buf.format()
end

vim.cmd(':autocmd FileType typescript command! TypedefBeg lua TypedefsBeg()')

-- markdown
vim.cmd(':autocmd FileType markdown command! Preview :CocCommand markdown-preview-enhanced.openPreview')

local c = require('vscode.colors').get_colors()
require('vscode').setup({
    transparent = true,

    italic_comments = true,

    disable_nvimtree_bg = true,

    group_overrides = {
        Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
    }
})
require('vscode').load()
