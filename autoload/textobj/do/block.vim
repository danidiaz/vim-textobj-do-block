
function textobj#do#block#TextObjectDoBlockA()
    return s:DoBlock({ do_pos, inner_pos -> do_pos })
endfunction

function textobj#do#block#TextObjectDoBlockI()
    return s:DoBlock({ do_pos, inner_pos -> inner_pos })
endfunction

function s:DoBlock(select_start_pos)
  let word_under_cursor = expand("<cword>")
  if word_under_cursor == "do"
      normal! w
  endif

  for i in range(v:count1)
      exec "normal! ?\\<do\\>\<cr>"
  endfor
  let do_pos = getpos('.')

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

" returns: cnum of the first non-blank character, 0 if no non-blank character is found
function s:FirstNonBlankLineNum(lnum,base_cnum)
    return match(getline(a:lnum), "\\v\\S",a:base_cnum - 1) + 1
endfu
