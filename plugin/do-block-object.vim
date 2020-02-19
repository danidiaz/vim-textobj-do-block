call textobj#user#plugin('doblock', {
\   'doblock': {
\     'select-a-function': 'DoBlockA',
\     'select-a': 'ad',
\   },
\ })

" https://devhints.io/vimscript
" https://developer.ibm.com/articles/l-vim-script-1/
" https://learnvimscriptthehardway.stevelosh.com/chapters/21.html

" https://vi.stackexchange.com/questions/18206/get-the-column-that-the-cursor-is-on-in-vimscript
" https://superuser.com/questions/723621/how-can-i-check-if-the-cursor-is-at-the-end-of-a-line

function! DoBlockA()
  " https://stackoverflow.com/questions/1115447/how-can-i-get-the-word-under-the-cursor-and-the-text-of-the-current-line-in-vim
  " https://stackoverflow.com/questions/23323747/vim-vimscript-get-exact-character-under-the-cursor
  let word_under_cursor = expand("<cword>")
  if word_under_cursor == "do"
      normal! w
  endif
  exec "normal! ?\\<do\\>\<cr>"
  let head_pos = getpos('.')
  " :help \_
  exec "normal! e/\\v\\_s+/e+1\<cr>"
  let middle_pos = getpos('.')
  let lnum = middle_pos[1]
  let base_col = middle_pos[2]
  let last_nonblank_lnum = lnum
  let open_brace_count = 0
  let close_brace_count = 0
  " https://stackoverflow.com/a/13372706/1364288
  while lnum <= line('$')
      if !s:IsLineNumEmpty(lnum)
          let first_nonblank_col = s:FirstNonBlankLineNum(lnum, lnum == head_pos[1] ? base_col : 1)
          if first_nonblank_col < base_col
               echom "found!" getline(lnum)
               echom "base_col" base_col
               echom "first_nonblank_col" first_nonblank_col
               echom [head_pos[0], last_nonblank_lnum,strlen(getline(last_nonblank_lnum))]
               return ['v', head_pos, [head_pos[0], last_nonblank_lnum, strlen(getline(last_nonblank_lnum))]] 
          else
               let current_line_col = first_nonblank_col - 1
               let current_line = getline(lnum) 
               while current_line_col != -1
                   let current_line_col = match(current_line,"\\v[()]",current_line_col)
                   if current_line_col != -1
                        if current_line[current_line_col] == '('
                            let open_brace_count += 1
                            let current_line_col += 1
                            echom "open (" open_brace_count
                        elseif current_line[current_line_col] == ')'
                            let close_brace_count += 1
                            if close_brace_count > open_brace_count
                               return ['v', head_pos, [head_pos[0], lnum, current_line_col]] 
                            endif
                            let current_line_col += 1
                            echom "close )" close_brace_count
                        endif
                   endif
               endwhile
               echom "foo"
          endif
          echo getline(lnum)
          echo "non-empty line"
          echo "first non blank col" first_nonblank_col
          let last_nonblank_lnum = lnum
      endif
      let lnum += 1
  endwhile
  return ['v', head_pos, [head_pos[0], last_nonblank_lnum, strlen(getline(last_nonblank_lnum))]] 
endfunction

" https://stackoverflow.com/questions/25438985/vimscript-regex-empty-line
function! s:IsLineNumEmpty(lnum)
    return match(getline(a:lnum), "\\v^\\s*$") != -1
endfu

" https://stackoverflow.com/questions/25438985/vimscript-regex-empty-line
" hide the line/buffer start column distinction under this function
function! s:FirstNonBlankLineNum(lnum,base_col)
    " docs lnum and col are the position in the buffer.  The first column is 1.
    return match(getline(a:lnum), "\\v\\S",a:base_col - 1) + 1
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
"
