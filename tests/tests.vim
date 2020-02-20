function s:Test(testnum,subtest,pos,action)
    let test_file     = "test_" . a:testnum . ".hs"
    let actual_file   = "test_" . a:testnum .  "_actual_" . a:subtest . ".hs"
    let expected_file = "test_" . a:testnum .  "_expected_" . a:subtest . ".hs"
    execute ":edit" test_file
    call setpos('.',[0,a:pos.lnum,a:pos.cnum,0])
    execute ":norm" a:action
    execute "write!" actual_file
    return { 'expected' : expected_file, 'actual' : actual_file }
endfunction

let testfiles = s:Test('001','01',{'lnum':2,'cnum':1},'dad')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!

let testfiles = s:Test('001','01',{'lnum':2,'cnum':2},'dad')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!

let testfiles = s:Test('001','01',{'lnum':3,'cnum':5},'dad')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!

let testfiles = s:Test('001','02',{'lnum':2,'cnum':1},'did')
call assert_equalfile(testfiles.expected,testfiles.actual)
bwipeout!

echo v:errors
