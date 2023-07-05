function js_cmd(str)
    cmd(':autocmd FileType javascript ' .. str)
end

js_cmd(':inoremap <buffer> cons console.log()<C-c>i')
