
" fcharchar.vim - extended f motion
" Author:       Abraham Sue 
" Version:      1.0
" GetLatestVimScripts: 0 1 :AutoInstall: fcharchar.vim
" Test write s<Char><Char> motion in simplest way
" TBD: 1. How to get current position in visual mode; 2. How to get real mode in function

if exists("s:loaded_fcharchar") || &cp || v:version < 700
	  finish
endif
let g:loaded_fcharchar = 1

let s:motionsaved_exist=0
let s:motionsaved_mode=''
let s:motionsaved_dir=0
let s:motionsaved_count=1
let s:config = {
  \ 'dir': [ 
      \ [  1, 'f', 'l', 'stridx'  ],
      \ [ -1, 'F', 'h', 'strridx' ],
    \ ],
  \ 'mode' : { 'v': 'gv', 'V': 'gv',  '': 'gv', 'n': ' ', 'o': ' ' },
  \ 'posmark' : {'v': "'>", 'V': "'>",  '': "'>", 'n': ".", 'o': "." } 
  \}
" fu! GetPosV() | execute 'normal! ' | let l:pos = col('.') - 1 | execute 'normal! gv' | return l:pos | endf
fu! s:readchar(...)
  if ! a:0 | return getchar() | endif
  let l:max = a:1 | let l:ts0 = reltime() | let l:elapsed = 0
  while l:elapsed < l:max
    if getchar(1)|return getchar()|endif
    sleep 50 m
    let l:elapsed = str2float(reltimestr(reltime(l:ts0)))
  endwhile
  return 27
endf
fu! s:motion(mode, direction, count, ...)
  if !has_key(s:config.mode, a:mode) | return | endif
  let l:prefix = 'normal! ' . s:config.mode[a:mode]
  let [ l:delta, l:fc, l:mc, l:findex] = s:config.dir[!!a:direction]
  let l:posmark = s:config.posmark[a:mode]
  let l:pos = col(l:posmark) - 1
  let l:c1 = 0
  let l:c2 = 0
"   let l:cpos = getcurpos()
"    echom 'delta=' . l:delta . 'fc=' . l:fc . ' mc=' . l:mc . ' findex=' . l:findex . ' posmark=' . l:posmark . 
"      \' count=' . a:count . ' mode=' . a:mode .
"      \' visualmode=' . visualmode() . ' prefix=' .  l:prefix .
"      \' pos=' . l:pos . ' virtcol=' . virtcol('.') . ' getcurpos=[' .  l:cpos[1] . ',' . l:cpos[2] . 'lmode()]'
  echom l:delta .' '. l:fc .' '. l:mc .' '. l:findex . ' '. l:posmark . ' ' . l:prefix
  if a:0 > 0 
    let l:la = strlen(a:1)
    if l:la > 0 | let l:c1 = char2nr(strpart(a:1, 0, 1)) | endif
    if l:la > 1 | let l:c2 = char2nr(strpart(a:1, 1, 1)) | endif
"    echom 'dir=' . a:direction . ' a:1=' . a:1 . ' a:0=' . a:0 . ' l:c1=' . l:c1 . ' l:c2=' . l:c2
  endif	  
  let l:timeout = exists("g:fcharchar_timeout")?(g:fcharchar_timeout):1
  if l:c1 == 0  | let l:c1 = s:readchar() | endif
  if l:c1 == 27 | return | endif
  if l:c2 == 0  | let l:c2 = s:readchar(l:timeout) | endif
  if l:c2 == 27 | execute l:prefix . a:count . l:fc . nr2char(l:c1) | return | endif
  let l:target = nr2char(l:c1) . nr2char(l:c2)
  if a:0 == 0
    let s:motionsaved_exist=1
    let s:motionsaved_mode=a:mode
    let s:motionsaved_dir=a:direction
    let s:motionsaved_count=a:count
    let s:motionsaved_keys=l:target
  endif

  let l:i = 0
  let l:pp = l:pos + l:delta - 1
  let l:line = getline('.')
  while l:i < a:count
    let l:idx = function(l:findex)( l:line, l:target, l:pp )
    if l:idx < 0 | break | endif
    let l:i += 1
    let l:pp = l:idx + l:delta
  endwhile
  if l:idx >= 0
    let l:idx = ( l:idx - l:pos ) * l:delta + l:delta
    if l:idx > 0 | execute l:prefix . l:idx . l:mc | endif
    " if l:idx > l:pos
    "   let l:idx -= l:pos
    "   let l:idx += 1
    "   execute l:prefix . l:idx . l:mc
    " elseif l:idx < l:pos
    "   let l:pos -= l:idx
    "   let l:pos -= 1
    "   execute l:prefix . l:pos . l:mc
    " endif
  endif

  return
endf
fu! s:record(action)
  let l:c1 = getchar() | if l:c1 == 27 |                                                   | return | endif
  let s:motionsaved_exist=0
  " let s:Saved0=a:count . a:action0 . nr2char(l:c1)
  " let s:Saved1=a:count . a:action1 . nr2char(l:c1)
  execute 'normal! ' . v:count1 . a:action . nr2char(l:c1)
endf
fu! s:replay(action)
  if s:motionsaved_exist > 0
    call s:motion(s:motionsaved_mode, (a:action == ',')?(!s:motionsaved_dir):(s:motionsaved_dir), s:motionsaved_count, s:motionsaved_keys)
  else
     execute 'normal! ' . a:action
  endif
endf
nnoremap <silent> s :<C-u>call <SID>motion('n', 0, v:count1)<cr>
onoremap <silent> s :<C-u>call <SID>motion('o', 0, v:count1)<cr>
vnoremap <silent> s :<C-u>call <SID>motion(visualmode(), 0, v:count1)<cr>
nnoremap <silent> S :<C-u>call <SID>motion('n', 1, v:count1)<cr>
onoremap <silent> S :<C-u>call <SID>motion('o', 1, v:count1)<cr>
vnoremap <silent> S :<C-u>call <SID>motion(visualmode(), 1, v:count1)<cr>


nnoremap <silent> t :<C-u>call <SID>record('t')<cr>
nnoremap <silent> T :<C-u>call <SID>record('T')<cr>
nnoremap <silent> f :<C-u>call <SID>record('f')<cr>
nnoremap <silent> F :<C-u>call <SID>record('F')<cr>
nnoremap <silent> ; :<C-u>call <SID>replay(';')<cr>
nnoremap <silent> , :<C-u>call <SID>replay(',')<cr>

