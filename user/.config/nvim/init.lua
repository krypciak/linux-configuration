-- vars
vim.o.clipboard = "unnamedplus"

vim.o.relativenumber = true
vim.wo.number = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.api.nvim_set_keymap("n", "<Space>", "", {})
vim.g.mapleader = " "

vim.o.undofile = true
vim.o.undodir = vim.fn.expand("$HOME/.cache/nvim/undo/")

vim.opt.rtp:append("/usr/share/vim/vimfiles")

vim.cmd([[
augroup remember_folds
  autocmd!
  autocmd BufWinLeave *.* mkview
  autocmd BufWinEnter *.* silent! loadview
augroup END
]])
vim.cmd([[set viewoptions-=curdir]])

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

vim.cmd([[
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
]])

-- Return to last edit position when opening files
vim.cmd([[
    autocmd BufReadPost *
         \ if line("'\"") > 0 && line("'\"") <= line("$") |
         \   exe "normal! g`\"" |
         \ endif
]])

-- Save opened folds
vim.cmd([[
    set viewoptions-=curdir
    set viewoptions-=options
    augroup remember_folds
        autocmd!
        autocmd BufWinLeave *.* if &ft !=# 'help' | mkview | endif
        autocmd BufWinEnter *.* if &ft !=# 'help' | silent! loadview | endif
    augroup END
]])

vim.cmd([[
" # Function to permanently delete views created by 'mkview'
function! MyDeleteView()
    let path = fnamemodify(bufname('%'),':p')
    " vim's odd =~ escaping for /
    let path = substitute(path, '=', '==', 'g')
    if empty($HOME)
    else
        let path = substitute(path, '^'.$HOME, '\~', '')
    endif
    let path = substitute(path, '/', '=+', 'g') . '='
    " view directory
    let path = &viewdir.'/'.path
    call delete(path)
    echo "Deleted: ".path
endfunction

" # Command Delview (and it's abbreviation 'delview')
command Delview call MyDeleteView()
" Lower-case user commands: http://vim.wikia.com/wiki/Replace_a_builtin_command_using_cabbrev
cabbrev delview <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'Delview' : 'delview')<CR>
]])

-- plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	"itchyny/lightline.vim",
	"nvim-telescope/telescope.nvim",
	"nvim-telescope/telescope-fzf-native.nvim",
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "typescript", "json", "bash" },
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
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	"tpope/vim-surround",
	"NMAC427/guess-indent.nvim",
	"kevinhwang91/promise-async",
	{
		"kevinhwang91/nvim-ufo",
		enabled = true,
		opts = {
			open_fold_hl_timeout = 0,
			close_fold_kinds_for_ft = { "imports", "comment" },
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = (" 󰁂 %d "):format(endLnum - lnum)
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
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end,
			preview = {
				win_config = {
					border = { "", " ", "", "", "", " ", "", "" },
					winhighlight = "Normal:Folded",
					winblend = 0,
				},
				mappings = {
					jumpTop = "[",
					jumpBot = "]",
				},
			},
			provider_selector = function(_, _, _)
				return { "treesitter", "indent" }
			end,
		},
		config = function(_, opts)
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
			vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", function() end)
			vim.keymap.set("n", "L", function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.fn.CocActionAsync("definitionHover")
				end
			end)
			require("ufo").setup(opts)
		end,
	},
	{
		"sanfusu/neovim-undotree",
		config = function(_, _)
			vim.keymap.set("", "<leader>u", ":UndotreeToggle<cr>")
		end,
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function(_, _)
			local harpoon = require("harpoon")
			harpoon:setup()

			-- basic telescope configuration
			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end

			vim.keymap.set("n", "<leader>fl", function()
				toggle_telescope(harpoon:list())
			end)
			vim.keymap.set("n", "<leader>fa", function()
				harpoon:list():append()
			end)

			vim.keymap.set("n", "<leader>fq", function()
				harpoon:list():select(1)
			end)
			vim.keymap.set("n", "<leader>fw", function()
				harpoon:list():select(2)
			end)
			vim.keymap.set("n", "<leader>fe", function()
				harpoon:list():select(3)
			end)
			vim.keymap.set("n", "<leader>fr", function()
				harpoon:list():select(4)
			end)
		end,
	},
	"nvim-tree/nvim-web-devicons",
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd", "prettier" },
				typescript = { "prettierd", "prettier" },
				sh = { "shfmt" },
			},
			notify_on_error = true,
			formatters = {
				shfmt = {
					command = "shfmt",
					prepend_args = { "-i", "4" },
				},
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			function Format()
				require("conform").format({ lsp_fallback = true })
			end
			vim.keymap.set("n", "\\f", Format)
		end,
	},
	{
		"neoclide/coc.nvim",
		build = "npm ci",
		config = function(_, _)
			vim.cmd([[
                inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
                inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
                inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"
            ]])

			vim.keymap.set("n", "[d", "<Plug>(coc-diagnostic-prev-error)")
			vim.keymap.set("n", "]d", "<Plug>(coc-diagnostic-next-error)")
			vim.keymap.set("n", "[f", "<Plug>(coc-diagnostic-prev)")
			vim.keymap.set("n", "]f", "<Plug>(coc-diagnostic-next)")

			vim.keymap.set("n", "<leader>gD", "<Plug>(coc-declaration)")
			vim.keymap.set("n", "<leader>gd", "<Plug>(coc-definition)")

			vim.keymap.set("n", "K", ':call CocActionAsync("doHover")<cr><C-L>')

			vim.keymap.set("n", "<leader>s", "<Plug>(coc-rename)")
			vim.keymap.set("n", "<leader>ca", "<Plug>(coc-codeaction)")
			vim.keymap.set("n", "<leader>gs", "<Plug>(coc-references)")
		end,
	},
	"preservim/vim-markdown",
	"gleam-lang/gleam.vim",
    'Hippo0o/context.vim',
}, {})

vim.o.background = "dark"
-- vim.cmd('set termguicolors')

-- Run/Compile keybinding
vim.keymap.set("n", "<leader>j", function()
	-- ftype = vim.bo.filetyp
	-- if ftype == 'rust' then rust_run()
	-- elseif ftype == 'python' then python_run()
	-- elseif ftype == 'sh' then sh_run()
	-- else print('Unsupported filetype: '.. ftype) end
end)

-- Build keybinding
vim.keymap.set("n", "<leader>k", function()
	-- ftype = vim.bo.filetype
	-- if ftype == 'rust' then rust_build()
	-- elseif ftype == 'c' then c_build()
	-- elseif ftype == 'cpp' then c_build()
	-- else print('Unsupported filetype: '.. ftype) end
end)

-- d stands for delete not cut
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "X", '"_X')
vim.keymap.set("n", "d", '"_d')
vim.keymap.set("n", "D", '"_D')
vim.keymap.set("v", "d", '"_d')
vim.keymap.set("n", "<leader>d", '"+d')
vim.keymap.set("n", "<leader>D", '"+D')
vim.keymap.set("v", "<leader>d", '"+d')
vim.keymap.set("v", "p", "pgvy")

vim.keymap.set("", "<leader>q", ":q<cr>")
vim.keymap.set("", "<leader>w", ":w<cr>")
vim.keymap.set("", "<leader>r", ":q!<cr>")
vim.keymap.set("", "<leader>e", ":wq<cr>")

vim.keymap.set("", "<esc>", "<nop>")
vim.keymap.set("i", "<esc>", "<nop>")
vim.keymap.set("v", ";;", "<esc>")
vim.keymap.set("i", ";l", "<esc>")

vim.keymap.set("n", "<leader>t", ":set wrap!<cr><C-L>")
vim.keymap.set("n", "<leader>l", ":noh<cr><C-L>")
vim.keymap.set("n", "<leader>a", "<cmd>Telescope git_files<cr>")
vim.keymap.set("n", "<leader>A", "<cmd>Telescope find_files<cr>")
vim.keymap.set("", "<leader>z", ":%y<cr>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "nzzzv")


-- python
vim.cmd(":autocmd FileType python :inoremap <buffer> this self")

-- rust
vim.cmd(":autocmd FileType rust :inoremap <buffer> pri println!(")

-- typescript

function ImpactClass()
	local name = vim.fn.input("Interface name: ")
	local extends = vim.fn.input("Extends: ")
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {
		"interface " .. name .. (extends ~= "" and " extends " .. extends or " ") .. "{",
		"}",
		"interface " .. name .. "Constructor extends ImpactClass<" .. name .. "> {",
		"new (): " .. name,
		"}",
		"var " .. name .. ": " .. name .. "Constructor",
	})
	Format()
end

vim.cmd(":autocmd FileType typescript command! ImpactClass lua ImpactClass()")

function TypedefsBeg()
	vim.cmd("normal G$o")
	vim.cmd("normal xxx")
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {
		"",
		"export {}",
		"",
		"declare global {",
		"namespace sc {}",
		"namespace ig {}",
		"}",
	})
	Format()
end

vim.cmd(":autocmd FileType typescript command! TypedefBeg lua TypedefsBeg()")

vim.cmd(":autocmd FileType typescript let @o='f:r=i ;l'")
vim.cmd(":autocmd FileType typescript let @p='^df.Ienum ;lf=xx100@o'")

-- javascript

vim.cmd(':autocmd FileType javascript lua vim.keymap.set("n", "<leader>m", "mn?ig.module<CR>:noh<CR>yi\\\'`n:echo @+<CR>")')

-- markdown
vim.cmd(":autocmd FileType markdown command! Preview :CocCommand markdown-preview-enhanced.openPreview")

vim.cmd(":autocmd FileType markdown command! Preview :CocCommand markdown-preview-enhanced.openPreview")

-- .json.patch
function JsonPatchFormat()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local text = table.concat(lines, "\n")
	local cmd = "echo '" .. text .. "' | prettier --parser json"
	local out = vim.fn.system(cmd)
	local linesMap = {}
	for line in out:gmatch("[^\r\n]+") do
		table.insert(linesMap, line)
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, linesMap)
end

function JsonPatch()
	vim.opt.filetype = "json"
	vim.keymap.set("n", "\\f", "<cmd>lua JsonPatchFormat()<cr>")
end

vim.cmd("autocmd BufRead *.json.patch lua JsonPatch()")
