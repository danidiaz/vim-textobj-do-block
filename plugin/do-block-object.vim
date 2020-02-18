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
  let base_col = middle_pos[2]
  let last_nonblank_line = lnum
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
               echom [head_pos[0], last_nonblank_line,strlen(getline(last_nonblank_line))]
               return ['v', head_pos, [head_pos[0], last_nonblank_line, strlen(getline(last_nonblank_line))]] 
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
          let last_nonblank_line = lnum
      endif
      let lnum += 1
  endwhile
  return ['v', head_pos, [head_pos[0], last_nonblank_line, strlen(getline(last_nonblank_line))]] 
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

" correct do is not deleted if cursor is in the d


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
