function js_cmd(str)
    cmd(':autocmd FileType javascript ' .. str)
end

js_cmd(':inoremap <buffer> conso console.log()<C-c>i')
