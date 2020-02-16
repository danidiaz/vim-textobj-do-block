call textobj#user#plugin('doblock', {
\   'doblock': {
\     'select-a-function': 'DoBlockA',
\     'select-a': 'ad',
\   },
\ })

" https://devhints.io/vimscript
" https://developer.ibm.com/articles/l-vim-script-1/
" https://learnvimscriptthehardway.stevelosh.com/chapters/21.html

" todo: handle dos in the same line
" todo: handle paretheses
"
" next step: use match() to find col of first non-blank in line
" next step: use match() to find if there are parentheses in line
" the level of parentheres should be a global setting...
function! DoBlockA()
  exec "normal! be?\\<do\\>\<cr>"
  let head_pos = getpos('.')
  " :help \_
  exec "normal! e/\\v\\_s+/e+1\<cr>"
  let middle_pos = getpos('.')
  let lnum = middle_pos[1]
  let col = middle_pos[2]
  " https://stackoverflow.com/a/13372706/1364288
  while lnum <= line('$')
      if s:IsLineNumEmpty(lnum)
          echo getline(lnum)
          echo "empty line"
      else
          echo getline(lnum)
          echo "non-empty line"
      endif
      let lnum = lnum + 1
  endwhile
  let tail_pos = getpos('.')
  return ['v', head_pos, tail_pos]
endfunction

" https://stackoverflow.com/questions/25438985/vimscript-regex-empty-line
function! s:IsLineNumEmpty(lnum)
    echo "the index" a:lnum match(getline(a:lnum), "\\v^\\s*$")
    return match(getline(a:lnum), "\\v^\\s*$") != -1
endfu

"
"   normal! ^
"   let head_pos = getpos('.')
"   normal! g_
"   let tail_pos = getpos('.')
"   let non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
"   return
"   \ non_blank_char_exists_p
"   \ ? ['v', head_pos, tail_pos]
"   \ : 0
" endfunction
