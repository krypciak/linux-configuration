function rust_cmd(str)
    cmd(':autocmd FileType rust ' .. str)
end

cmd [[
    command! CargoBench call cargo#bench(<q-args>)
    command! CargoBuild call cargo#build(<q-args>)
    command! CargoCheck call cargo#check(<q-args>)
    command! CargoCheck call cargo#check(<q-args>)
    command! CargoClean call cargo#clean(<q-args>)
    command! CargoDoc call cargo#doc(<q-args>)
    command! CargoTest call cargo#test(<q-args>)
    command! CargoUpdate call cargo#update(<q-args>)
    command! CargoNew call cargo#new(<q-args>)
]]

function rust_run()
    cmd(":w")
    -- Get the first non-blank line
    local first_line = vim.fn.getline(1)
    local args = ''
    if first_line:find('//RUN_ARGS=', 1, true) then
        args = string.sub(first_line, 12)
    end
    local bul = 'call cargo#cmd(\'run -- ' .. args .. '\')'
    print(bul)
    cmd(bul)
    cmd("normal! G")
end

function rust_build()
    cmd(':w')
    cmd(':CargoBuild')
    cmd("normal! G")
end

rust_cmd(':inoremap <buffer> pri println!(')
