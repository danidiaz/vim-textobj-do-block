edit test_001.hs
execute ":norm dad"
write! test_001_actual_01.hs
call assert_equalfile('test_001_expected_01.hs','test_001_actual_01.hs')
bwipeout!

echo v:errors
