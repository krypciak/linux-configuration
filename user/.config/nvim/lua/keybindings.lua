function map(mode, combo, mapping, opts)
    local options = {noremap = true}
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, combo, mapping, options)
end


local to_dvorak = ':set langmap=\'q,\\\\,w,.e,pr,yt,fy,gu,ci,ro,lp,/[,=],aa,os,ed,uf,ig,dh,hj,tk,nl,s\\\\;,-\',\\\\;z,qx,jc,kv,xb,bn,mm,w\\\\,,v.,z/,[-,]=,\\\"Q,<W,>E,PR,YT,FY,GU,CI,RO,LP,?{,+},AA,OS,ED,UF,IG,DH,HJ,TK,NL,S:,_\\\",:Z,QX,JC,KV,XB,BN,MM,W<,V>,Z?<cr>'

--map('', '<leader>kl', to_dvorak, { noremap = true })

function os.capture(cmd)
    local handle = assert(io.popen(cmd, "r"))
    local output = assert(handle:read("*a"))
    handle:close()
    return output
end


local layout = 'qwerty'

local layout_file = io.open('/tmp/keyboard_layout', 'r')
if layout_file ~= nil then
    layout = layout_file:read()
    io.close(layout_file)
end
if not layout then layout = 'qwerty' end

if string.find(layout, "dvorak") then
    cmd(to_dvorak)
end



-- NvimTree keybindings
map('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true })

-- Run/Compile keybinding
map('n', '<leader>j', '', { noremap = true, callback = function()
        ftype = vim.bo.filetype
        if ftype == 'rust' then rust_run()
        elseif ftype == 'python' then python_run()
        elseif ftype == 'sh' then sh_run()
        else print('Unsupported filetype: '.. ftype) end
   end })


-- Build keybinding
map('n', '<leader>k', '', { noremap = true, callback = function()
        ftype = vim.bo.filetype
        if ftype == 'rust' then rust_build()
        elseif ftype == 'c' then c_build()
        elseif ftype == 'cpp' then c_build()
        else print('Unsupported filetype: '.. ftype) end
   end })


-- d stands for delete not cut
map('n', 'x', '"_x', { noremap = true })
map('n', 'X', '"_X', { noremap = true })
map('n', 'd', '"_d', { noremap = true })
map('n', 'D', '"_D', { noremap = true })
map('v', 'd', '"_d', { noremap = true })


map('n', '<leader>d', '"+d', { noremap = true })
map('n', '<leader>D', '"+D', { noremap = true })
map('v', '<leader>d', '"+d', { noremap = true })

map('',  '<leader>q', ':q<cr>', { noremap = true })
map('',  '<leader>w', ':w<cr>', { noremap = true })
map('',  '<leader>r', ':q!<cr>', { noremap = true })
map('',  '<leader>e', ':wq<cr>', { noremap = true })


-- Set jk to <esc>
map('', '<esc>', '<nop>', { noremap = true })
map('i', '<esc>', '<nop>', { noremap = true })

if string.find(layout, "qwerty") then
    map('', ';;', '<esc>', { noremap = true})
    map('i', ';l', '<esc>', { noremap = true})
elseif string.find(layout, "dvorak") then
    map('', 'sl', '<esc>', { noremap = true})
    map('i', 'sl', '<esc>', { noremap = true})
end



local foldcolumn = 0;
cmd(':set foldcolumn=' .. foldcolumn)
map('n', '<leader>n', '', { noremap = true, callback = function() 
        foldcolumn = foldcolumn + 1
        if foldcolumn > 4 then foldcolumn = 0 end
        cmd(':set foldcolumn='..foldcolumn)
    end,})

map('n', '<leader>t', ':set wrap!<cr>', { noremap = true })

map('n', '<leader>l', ':noh<cr>', { noremap = true })

map('n', '<leader>a', '<cmd>Telescope find_files<cr>')
--'nnoremap <leader>ff <cmd>Telescope find_files<cr>'
--nnoremap <leader>fg <cmd>Telescope live_grep<cr>
--nnoremap <leader>fb <cmd>Telescope buffers<cr>
--nnoremap <leader>fh <cmd>Telescope help_tags<cr>

map('', '<leader>z', ':%y<cr>')

require("lspconf")

require("lang/python")
require("lang/rust")
require("lang/c")
require("lang/sh")
require("lang/js")
