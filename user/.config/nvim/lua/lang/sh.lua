function sh_run()
    cmd(":w")

    local path = vim.fn.expand('%:p')
    path = string.sub(path, 0, -4) .. '.arg'

    local argfile = io.open(path, "r")
    if argfile then 
        argfile.close()
        cmd(':term sh % < ' .. path)
    else
        -- Get the first non-blank line
        local first_line = vim.fn.getline(2)
        local args = ''
        if first_line:find('#RUN_ARGS=', 1, true) then
            args = string.sub(first_line, 11)
        end
        local bul = ':term sh % ' .. args
        cmd(bul)
    end
end
