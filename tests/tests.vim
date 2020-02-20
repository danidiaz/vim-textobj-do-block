function s:position(lnum,cnum)
    call setpos('.',[0,a:lnum,a:cnum,0])
endfunction

edit test_001.hs
call s:position(2,1)
execute ":norm dad"
write! test_001_actual_01.hs
call assert_equalfile('test_001_expected_01.hs','test_001_actual_01.hs')
bwipeout!

edit test_001.hs
call s:position(2,1)
execute ":norm did"
write! test_001_actual_02.hs
call assert_equalfile('test_001_expected_02.hs','test_001_actual_02.hs')
bwipeout!

echo v:errors
