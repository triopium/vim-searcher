"FUNCTION GO TO LINE HELPER FOR SHOW RESULTS:
function! searcher#GetLine(worig,file,wscratch)
	let l:pattl=':\d\{-}:'
	let l:line=getline('.')
	let l:matchl=matchstr(l:line,l:pattl)
	let l:matchl=substitute(l:matchl,':','','')

	let l:pattf='^.\{-}:'
	let l:matchf=matchstr(l:line,l:pattf)
	let l:matchf=substitute(l:matchf,':$','','')
	exe a:worig . "wincmd w"
	exe 'silent e' l:matchf
	exe l:matchl
	exe a:wscratch . "wincmd w"
endfunction

""SHOW RESULT IN SPLIT WINDOW BUFFER:
function! searcher#ShowResults(lst,concealfname,patt)
	"Prepare scratch buffer
	let l:lenlst=len(a:lst)
	let l:lenlst = (l:lenlst>15) ? 15 : l:lenlst
	let l:bufnr=bufnr("%")
	let l:worig=winnr()
	silent call buffer#GoToScratch('searched',l:lenlst)
	let l:wscratch=winnr()
	set ma
	%d_
	0put = a:lst
	1
	set noma
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
endfunction

""GREP OPEN BUFFERS:
function! searcher#GrepBuffers(patt)
	let l:bufnames=buffer#BuffersGetListedNames()
	let l:dirs=join(l:bufnames,' ')
	let l:bashc='grep ' . a:patt . ' -nH ' . l:dirs
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
	let l:bashc='grep ' . a:patt . ' -nH ' . l:fname
	let l:list=systemlist(l:bashc)
	let l:patt='^' . $HOME
	let l:list=array#ListSubstitute(l:list,l:patt,'~','g')
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
""echo searcher#GrepBuffer('func')
command! -nargs=1 SearcherGrepBuffer call searcher#GrepBuffer(<q-args>)

""GREP SPECIFIED DIRECTORIES:
function! searcher#GrepDirs(patt,dirs)
	let l:bashc='find ' . a:dirs  . ' -type f -exec grep ' . a:patt . ' -nH -A 1 {} \;'
	let l:list=systemlist(l:bashc)
	call filter(l:list, 'v:val !~ "Binary file"')
	let l:patt='^' . $HOME
	let l:list=array#ListSubstitute(l:list,l:patt,'~','g')
	return l:list
endfunction

""GREP NOTES:
function! searcher#GrepNotes(patt)
	let l:dir=$HOME . '/Notes/'
	let l:list=searcher#GrepDirs(a:patt,l:dir)
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
command! -nargs=1 SearcherGrepNotes call searcher#GrepNotes(<q-args>)
""echo searcher#GrepNotes('func')

""GREP Scripts:
function! searcher#GrepScripts(patt)
	let l:dir=$HOME . '/Scripts/'
	let l:list=searcher#GrepDirs(a:patt,l:dir)
	call searcher#ShowResults(l:list,'yes',a:patt)
endfunction
command! -nargs=1 SearcherGrepScripts call searcher#GrepScripts(<q-args>)
""echo searcher#GrepScripts('func')
