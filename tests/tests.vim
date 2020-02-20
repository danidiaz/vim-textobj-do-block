function s:Test(testfiles,pos,action)
    execute ":edit" a:testfiles.input
    call setpos('.',[0,a:pos.lnum,a:pos.cnum,0])
    execute ":norm" a:action
    execute "write!" a:testfiles.actual
endfunction

" tip: use gf to move quickly to test files

" test basic stuff
let testfiles = {'input':'test_001.hs','expected':'test_001_01_expected.hs','actual':'test_001_01_actual.hs'}
call s:Test(testfiles,{'lnum':2,'cnum':1},'dad')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!
call s:Test(testfiles,{'lnum':2,'cnum':2},'dad')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!
call s:Test(testfiles,{'lnum':3,'cnum':5},'dad')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!

let testfiles = {'input':'test_001.hs','expected':'test_001_02_expected.hs','actual':'test_001_02_actual.hs'}
call s:Test(testfiles,{'lnum':2,'cnum':1},'did')                                                 
call assert_equalfile(testfiles.expected,testfiles.actual)                                       
bwipeout!                                                                                        
                                                                                                 
" test delimited with braces                                                                     
let testfiles = {'input':'test_002.hs','expected':'test_002_01_expected.hs','actual':'test_002_01_actual.hs'}
call s:Test(testfiles,{'lnum':2,'cnum':5},'dad')                                                 
call assert_equalfile(testfiles.expected,testfiles.actual)                                       
bwipeout!                                                                                        
                                                                                                 
let testfiles = {'input':'test_002.hs','expected':'test_002_02_expected.hs','actual':'test_002_02_actual.hs'}
call s:Test(testfiles,{'lnum':2,'cnum':5},'did')                                                 
call assert_equalfile(testfiles.expected,testfiles.actual)                                       
bwipeout!                                                                                        
                                                                                                 
" test spaces                                                                                    
let testfiles = {'input':'test_003.hs','expected':'test_003_01_expected.hs','actual':'test_003_01_actual.hs'}
call s:Test(testfiles,{'lnum':9,'cnum':6},'dad')                                                 
call assert_equalfile(testfiles.expected,testfiles.actual)                                       
bwipeout!                                                                                        
                                                                                                 
let testfiles = {'input':'test_003.hs','expected':'test_003_02_expected.hs','actual':'test_003_02_actual.hs'}
call s:Test(testfiles,{'lnum':9,'cnum':6},'did')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!

echo v:errors
