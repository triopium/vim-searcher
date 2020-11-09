"FUNCTION GO TO LINE HELPER FOR SHOW RESULTS:
function! searcher#GetLine(worig,file,wscratch)
	""worig - original window number
	""wscratch - scratch buffer window number
	""Extract number from line
	let l:pattl=':\d\{-}:'
	let l:line=getline('.')
	let l:matchl=matchstr(l:line,l:pattl)
	let l:matchl=substitute(l:matchl,':','','')
	""Extract filename
	let l:pattf='^.\{-}:'
	let l:matchf=matchstr(l:line,l:pattf)
	let l:matchf=substitute(l:matchf,':$','','')
	""Go to original window number and open file containing searched string
	exe a:worig . "wincmd w"
	exe 'silent e' l:matchf
	exe l:matchl
	normal! zt
	exe a:wscratch . "wincmd w"
endfunction


function! searcher#GetLineSimple(worig,file,wscratch)
	let l:line=getline('.')
	""Go to original window number and open file containing searched string
	exe a:worig . "wincmd w"
	exe 'silent e' l:line
	normal! zt
endfunction

function! searcher#ShowResultsSimple(lst)
	let l:lenlst=len(a:lst)
	let l:lenlst = (l:lenlst>15) ? 15 : l:lenlst
	let l:bufnr=bufnr("%")
	let l:worig=winnr()
	silent call buffer#GoToScratch('searched',l:lenlst)
	let l:wscratch=winnr()
	normal! %d_
	0put = a:lst
	syn clear
	exe 'nnoremap <buffer> <silent> <cr> :echo searcher#GetLineSimple(' . l:worig  . ',' . l:bufnr . ',' . l:wscratch')<CR>'
endfunction

""SHOW RESULT IN SPLIT WINDOW BUFFER:
function! searcher#ShowResults(lst,concealfname,patt)
	"Prepare scratch buffer with matching files
	let l:lenlst=len(a:lst)
	let l:lenlst = (l:lenlst>15) ? 15 : l:lenlst
	let l:bufnr=bufnr("%")
	let l:worig=winnr()
	silent call buffer#GoToScratch('searched',l:lenlst)
	let l:wscratch=winnr()
	normal! %d_
	0put = a:lst
	"
	"HIGHLIGH RESULT"
	syn clear
	"Seached pattern
	let l:hname="searcherGrepDirHL3"
	let l:hicommand='highlight ' . l:hname . ' guifg=#C89600'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(a:patt)
	exe l:hicommand
	exe l:mcommand
	"File path
	let l:patt='^.\{-}\ze:'
	let l:hname="searcherGrepDirHL2"
	let l:hicommand='highlight ' . l:hname . ' guifg=#FF0090'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(l:patt) . ' conceal cchar=~'  
	exe l:hicommand
	exe l:mcommand
	setlocal conceallevel=3
	if a:concealfname ==? 'yes'
		setlocal concealcursor=nc
	endif
	"Line number
	let l:patt=':\d\{-}:'
	let l:hname="searcherGrepDirHL1"
	let l:hicommand='highlight ' . l:hname . ' guifg=#289600'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape(l:patt) 
	exe l:hicommand
	exe l:mcommand
	
	""Mappings
	exe 'nnoremap <buffer> <silent> <cr> :echo searcher#GetLine(' . l:worig  . ',' . l:bufnr . ',' . l:wscratch')<CR>'
	nnoremap c :call buffer#ConcealCursorToggle()<CR>
	1
endfunction

""GREP OPEN BUFFERS:
function! searcher#GrepBuffers(patt)
	let l:bufnames=buffer#BuffersGetListedNames()
	let l:dirs=join(l:bufnames,' ')
	let l:bashc='grep -nH -- ' . a:patt . ' ' . l:dirs
	let l:list=systemlist(l:bashc)
	let l:patt='^' . $HOME
	let l:list=array#ListSubstitute(l:list,l:patt,'~','g')
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
""echo searcher#GrepBuffers('func')
command! -nargs=1 SearcherGrepBuffers call searcher#GrepBuffers(<q-args>)
"
""GREP CURRENT BUFFER:
function! searcher#GrepBuffer(patt)
	let l:fname=expand('%:p')
	let l:bashc='grep -nH -- ' . a:patt . ' ' . l:fname
	let l:list=systemlist(l:bashc)
	let l:patt='^' . $HOME
	let l:list=array#ListSubstitute(l:list,l:patt,'~','g')
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
""echo searcher#GrepBuffer('func')
command! -nargs=1 SearcherGrepBuffer call searcher#GrepBuffer(<q-args>)

""GREP SPECIFIED DIRECTORIES:
function! searcher#GrepDir(dir,patt)
	"if grep does not suport recursive
	"let l:bashc='find ' . a:dir  . ' -type f -exec grep -A 0 -nH -- ' . a:patt . ' {} \;'
	let l:bashc='grep -A 0 -rnH -- ' . a:patt . ' ' . a:dir
	let l:list=systemlist(l:bashc)
	call filter(l:list, 'v:val !~ "Binary file"')
	let l:patt='^' . $HOME
	let l:list=array#ListSubstitute(l:list,l:patt,'~','g')
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
command! -nargs=* SearcherGrepDir call searcher#GrepDir(<f-args>)

""GREP NOTES:
function! searcher#GrepNotes(patt)
	let l:dir=$HOME . '/Notes/'
	"if grep does not suport recursive
	"let l:bashc='find ' . l:dir . ' -type f -exec grep -A 0 -nH -- ' . a:patt . ' {} \;'
	let l:bashc='grep -A 0 -rnH -- ' . a:patt . ' ' . l:dir
	let l:list=systemlist(l:bashc)
	call filter(l:list, 'v:val !~ "Binary file"')
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
command! -nargs=1 SearcherGrepNotes call searcher#GrepNotes(<q-args>)
""echo searcher#GrepNotes('func')

""GREP Scripts:
"SLOW ON LARGE FILES
function! searcher#GrepScripts(patt)
	let l:dir=$HOME . '/Scripts/'
	let l:bashc='grep -A 0 -rnHl -- ' . a:patt . ' ' . l:dir
	echo l:bashc
	let l:list=systemlist(l:bashc)
	call filter(l:list, 'v:val !~ "Binary file"')
	"call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
"command! -nargs=1 SearcherGrepScripts call searcher#GrepScripts(<q-args>)
""echo searcher#GrepScripts('func')

functio! searcher#GrepFiles(dir,patt)
	let l:bashc='grep -A 0 -rl -- ' . a:patt . ' ' . a:dir
	let l:list=systemlist(l:bashc)
	echo l:list
	call filter(l:list, 'v:val !~ "Binary file"')
	call searcher#ShowResultsSimple(l:list)
endfunction
command! -nargs=* SearcherGrepFiles call searcher#GrepFiles(<f-args>)

functio! searcher#GrepFileNames(dir,patt)
	"let l:bashc='grep -A 0 -rl -- ' . a:patt . ' ' . a:dir
	let l:bashc='find ' . a:dir . ' -type f ' . ' | grep ' . a:patt
	let l:list=systemlist(l:bashc)
	call filter(l:list, 'v:val !~ "Binary file"')
	call searcher#ShowResultsSimple(l:list)
endfunction
command! -nargs=* SearcherGrepFileNames call searcher#GrepFileNames(<f-args>)

""FIND FILES:
function! searcher#FindFiles(...)
	let l:dir=$HOME . '/Notes/'
	"path switch
	let l:p=0 
	let l:pa=""
	"string switch
	let l:s=0
	let l:str=""
	for l:i in a:000
		"" Get switches
		if l:i=="+s"
			let l:s=1
			continue
		endif
		if l:i=="-s"
			let l:s=-1
			continue
		endif
		if l:i=="+p"
			let l:p=1
			continue
		endif
		if l:i=="-p"
			let l:p=-1
			continue
		endif
		
		"" Construct command according to switches values
		if l:p==1
			let l:pa.=" -path *" . l:i . "*"
		endif
		if l:p==-1
			let l:pa.=" ! -path *" . l:i . "*"
		endif
		if l:s==1
			let l:str.=" -iname *" . l:i . "*"
		endif
		if l:s==-1
			let l:str.=" ! -iname *" . l:i . "*"
		endif

	endfor
	let l:stra='\( ' . l:str . ' \)'
	"let l:bashc='find . -type f ' . l:stra . " " . l:pa
	let l:bashc='find ' . l:dir . ' -type f ' . l:stra . " " . l:pa
	echo l:bashc
	
	""Display results
	let l:list=systemlist(l:bashc)
	call filter(l:list, 'v:val !~ "Binary file"')
	let l:patt='^' . $HOME
	let l:list=array#ListSubstitute(l:list,l:patt,'~','g')
	call searcher#ShowResults(l:list,'yes',l:patt)
endfunction
command! -nargs=+ FF  call searcher#FindFiles(<f-args>)

