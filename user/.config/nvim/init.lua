-- vars
vim.o.clipboard = 'unnamedplus'

vim.o.relativenumber = true
vim.wo.number = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.api.nvim_set_keymap('n', '<Space>', '', {})
vim.g.mapleader = ' '

vim.o.undofile = true
vim.o.undodir = vim.fn.expand('$HOME/.cache/nvim/undo/')

vim.opt.rtp:append('/usr/share/vim/vimfiles')

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
    set viewoptions-=options
    augroup remember_folds
        autocmd!
        autocmd BufWinLeave *.* if &ft !=# 'help' | mkview | endif
        autocmd BufWinEnter *.* if &ft !=# 'help' | silent! loadview | endif
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
    'NMAC427/guess-indent.nvim',
    'kevinhwang91/promise-async',
    'kevinhwang91/nvim-ufo',
    'sanfusu/neovim-undotree',
    { "ThePrimeagen/harpoon", branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" } },
    'nvim-tree/nvim-web-devicons',
    'ThePrimeagen/vim-be-good',

    { 'neoclide/coc.nvim',    build = 'npm ci' },
    'preservim/vim-markdown',
    'coc-prettier',
    'gleam-lang/gleam.vim',
}, {})

vim.o.background = 'dark'
-- vim.cmd('set termguicolors')

require 'nvim-treesitter.configs'.setup {
    ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'typescript', 'json', 'bash' },
    sync_install = false,
    markid = { enable = true },
    auto_install = true,

    highlight = {
        enable = true,

        disable = function(_, buf)
            local max_filesize = 3 * 1024 * 1024 -- 10 MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,
        additional_vim_regex_highlighting = false,
    },
}


-- ufo
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
vim.keymap.set('n', 'L', function()
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if not winid then
        vim.fn.CocActionAsync('definitionHover')
    end
end)

require('ufo').setup({
    open_fold_hl_timeout = 0,
    close_fold_kinds = { 'imports', 'comment' },
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
                table.insert(newVirtText, chunk)
            else
                chunkText = truncate(chunkText, targetWidth - curWidth)
                local hlGroup = chunk[2]
                table.insert(newVirtText, { chunkText, hlGroup })
                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                -- str width returned from truncate() may less than 2nd argument, need padding
                if curWidth + chunkWidth < targetWidth then
                    suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                end
                break
            end
            curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
    end,
    preview = {
        win_config = {
            border = { '', ' ', '', '', '', ' ', '', '' },
            winhighlight = 'Normal:Folded',
            winblend = 0
        },
        mappings = {
            jumpTop = '[',
            jumpBot = ']'
        }
    },
    provider_selector = function(_, _, _)
        return { 'treesitter', 'indent' }
    end
})


-- coc.nvim
vim.cmd [[
    inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
    inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
    inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
]]

-- keybindings
local function map(mode, combo, mapping, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, combo, mapping, options)
end


-- NvimTree keybindings
map('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })


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
map('v', 'p', 'pgvy')

-- quick file save/quit
map('', '<leader>q', ':q<cr>')
map('', '<leader>w', ':w<cr>')
map('', '<leader>r', ':q!<cr>')
map('', '<leader>e', ':wq<cr>')

-- set jk to <esc>
map('', '<esc>', '<nop>')
map('i', '<esc>', '<nop>')
map('v', ';;', '<esc>')
map('i', ';l', '<esc>')

map('n', '<leader>t', ':set wrap!<cr><C-L>', { noremap = true, silent = false })
map('n', '<leader>l', ':noh<cr><C-L>', { noremap = true, silent = false })
map('n', '<leader>a', '<cmd>Telescope git_files<cr>')
map('n', '<leader>A', '<cmd>Telescope find_files<cr>')
map('', '<leader>z', ':%y<cr>', { noremap = true, silent = false })
map('', '<leader>u', ':UndotreeToggle<cr>')

map('n', '[d', '<Plug>(coc-diagnostic-prev-error)')
map('n', ']d', '<Plug>(coc-diagnostic-next-error)')
map('n', '[f', '<Plug>(coc-diagnostic-prev)')
map('n', ']f', '<Plug>(coc-diagnostic-next)')

map('n', '<leader>gD', '<Plug>(coc-declaration)')
map('n', '<leader>gd', '<Plug>(coc-definition)')

map('n', 'K', ':call CocActionAsync("doHover")<cr><C-L>')

map('n', '<leader>s', '<Plug>(coc-rename)')
map('n', '<leader>ca', '<Plug>(coc-codeaction)')
map('n', '<leader>gs', '<Plug>(coc-references)')
map('n', '\\f', '<Plug>(coc-format)')

map('n', '<leader>u', '', {
    noremap = true,
    callback = function()
        vim.cmd [[
        normal! zR
        UfoDetach
        UfoAttach
        normal! zM
    ]]
    end
})

map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'nzzzv')

-- harpoon
local harpoon = require('harpoon')
harpoon:setup()

-- basic telescope configuration
local conf = require('telescope.config').values
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require('telescope.pickers').new({}, {
        prompt_title = 'Harpoon',
        finder = require('telescope.finders').new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
    }):find()
end

map('n', '<leader>fl', '', {
    noremap = true,
    callback = function()
        toggle_telescope(harpoon:list())
    end,
})
map('n', '<leader>fa', '', { noremap = true, callback = function() harpoon:list():append() end })

map('n', '<leader>fq', '', { noremap = true, callback = function() harpoon:list():select(1) end })
map('n', '<leader>fw', '', { noremap = true, callback = function() harpoon:list():select(2) end })
map('n', '<leader>fe', '', { noremap = true, callback = function() harpoon:list():select(3) end })
map('n', '<leader>fr', '', { noremap = true, callback = function() harpoon:list():select(4) end })


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

vim.cmd(":autocmd FileType typescript let @o='f:r=i ;l'")
vim.cmd(":autocmd FileType typescript let @p='^df.Ienum ;lf=xx100@o'")

-- markdown
vim.cmd(':autocmd FileType markdown command! Preview :CocCommand markdown-preview-enhanced.openPreview')

vim.cmd(':autocmd FileType markdown command! Preview :CocCommand markdown-preview-enhanced.openPreview')

-- .json.patch
function JsonPatchFormat()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local text = table.concat(lines, '\n')
    local cmd = 'echo \'' .. text .. '\' | prettier --parser json'
    local out = vim.fn.system(cmd)
    local linesMap = {}
    for line in out:gmatch("[^\r\n]+") do
        table.insert(linesMap, line)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, linesMap)
end

function JsonPatch()
    vim.opt.filetype = 'json'
    map('n', '\\f', '<cmd>lua JsonPatchFormat()<cr>')
end

vim.cmd('autocmd BufRead *.json.patch lua JsonPatch()')
