command! -nargs=1 Silent
            \   execute 'silent !' . <q-args>
            \ | execute 'redraw!'

nnoremap <leader>s vit!mnolth client <CR><c-o>
nnoremap <silent> <leader>p :Silent echo 'lil("playtog")' \| mnolth client <CR>
nnoremap <silent> <leader>q :Silent echo 'lil("stop")' \| mnolth client <CR>
nnoremap <silent> <leader>r :Silent echo 'run()' \| mnolth client <CR>
nnoremap <silent> <leader>R :Silent echo 'altrun()' \| mnolth client <CR>
