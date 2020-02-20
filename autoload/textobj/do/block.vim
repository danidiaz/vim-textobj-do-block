" https://devhints.io/vimscript
" https://developer.ibm.com/articles/l-vim-script-1/
" https://learnvimscriptthehardway.stevelosh.com/chapters/21.html

" https://vi.stackexchange.com/questions/18206/get-the-column-that-the-cursor-is-on-in-vimscript
" https://superuser.com/questions/723621/how-can-i-check-if-the-cursor-is-at-the-end-of-a-line

function textobj#do#block#TextObjectDoBlockA()
    return s:DoBlock({ do_pos, inner_pos -> do_pos })
endfunction

function textobj#do#block#TextObjectDoBlockI()
    return s:DoBlock({ do_pos, inner_pos -> inner_pos })
endfunction

function s:DoBlock(select_start_pos)
  " https://stackoverflow.com/questions/1115447/how-can-i-get-the-word-under-the-cursor-and-the-text-of-the-current-line-in-vim
  " https://stackoverflow.com/questions/23323747/vim-vimscript-get-exact-character-under-the-cursor
  let word_under_cursor = expand("<cword>")
  if word_under_cursor == "do"
      normal! w
  endif

  for i in range(v:count1)
      exec "normal! ?\\<do\\>\<cr>"
  endfor
  let do_pos = getpos('.')

  " :help \_
  exec "normal! e/\\v\\_s+/e+1\<cr>"
  let inner_pos = getpos('.')

  let start_pos = a:select_start_pos(do_pos,inner_pos)

  let IntervalEndingAt = 
        \ { lnum_end, cnum_end -> ['v', start_pos, [start_pos[0], lnum_end, cnum_end]] }

  let IntervalEndingAtFullLine = 
        \ { lnum_end -> IntervalEndingAt(lnum_end,col([lnum_end,'$'])-1) }

  let lnum = inner_pos[1]
  let base_cnum = inner_pos[2]
  let last_nonblank_lnum = lnum
  let counter = s:BraceCounter()
  " https://stackoverflow.com/a/13372706/1364288
  while lnum <= line('$')
      let first_nonblank_cnum = 
            \ s:FirstNonBlankLineNum(lnum, lnum == do_pos[1] ? base_cnum : 1)
      if first_nonblank_cnum == 0
           let lnum += 1
      elseif first_nonblank_cnum < base_cnum
           return IntervalEndingAtFullLine(last_nonblank_lnum)
      else
           let before_brace = counter.count(lnum,first_nonblank_cnum)
           if before_brace != -1
                return IntervalEndingAt(lnum, before_brace)
           endif
           let last_nonblank_lnum = lnum
           let lnum += 1
      endif
  endwhile
  return IntervalEndingAtFullLine(last_nonblank_lnum)
endfunction

function s:BraceCounter()
    return { 'balance' : 0, 'count' : function("s:CountBraces") }
endfunction

function s:CountBraces(lnum,first_nonblank_cnum) dict
   let current_line = getline(a:lnum) 
   let current_col_index = a:first_nonblank_cnum - 1
   while v:true
       let current_col_index = 
              \ match(current_line,"\\v[()]",current_col_index)
       if current_col_index == -1
           return current_col_index
       else
           if current_line[current_col_index] == '('
               let self.balance = self.balance + 1
               let current_col_index += 1
           elseif current_line[current_col_index] == ')'
               let self.balance = self.balance - 1
               if self.balance < 0
                  return current_col_index
               endif
               let current_col_index += 1
           endif
       endif
   endwhile
endfunction


" https://stackoverflow.com/questions/25438985/vimscript-regex-empty-line
" hide the line/buffer start column distinction under this function
" returns: cnum of the first non-blank character, 0 if no non-blank character is found
function s:FirstNonBlankLineNum(lnum,base_cnum)
    " docs lnum and col are the position in the buffer.  The first column is 1.
    return match(getline(a:lnum), "\\v\\S",a:base_cnum - 1) + 1
endfu
