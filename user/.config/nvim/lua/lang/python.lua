function python_cmd(str)
    cmd(':autocmd FileType python ' .. str)
end

function python_run()
    cmd(":w")
    
    local path = vim.fn.expand('%:p')
    path = string.sub(path, 0, -4) .. '.arg'

    local argfile = io.open(path, "r")
    if argfile then 
        argfile.close()
        cmd(':term python % < ' .. path)
    else
        -- Get the first non-blank line
        local first_line = vim.fn.getline(1)
        local args = ''
        if first_line:find('# RUN_ARGS=', 1, true) then
            args = string.sub(first_line, 12)
        end
        local bul = ':term python %'
        --print(bul)
        cmd(bul)
    end
end

python_cmd(":noremap <buffer> <leader>f :BlackMacchiato<cr>")
