
" fcharchar.vim - extended f motion
" Author:       Abraham Sue 
" Version:      1.0
" GetLatestVimScripts: 0 1 :AutoInstall: fcharchar.vim

if exists("g:loaded_fcharchar") || &cp || v:version < 700
	  finish
endif
let g:loaded_fcharchar = 1

" Test write s<Char><Char> motion in simplest way
" TBD: 1. How to get current position in visual mode; 2. How to get real mode in function
let g:MotionSSaved#exist=0
let g:MotionSSaved#mode=''
let g:MotionSSaved#dir=0
let g:MotionSSaved#count=1
fu! MotionS(mode, direction, count, ...)
  if     a:mode == 'v' || a:mode == 'V' || a:mode == ''|let l:prefix = 'normal! gv'
  elseif a:mode == 'n' || a:mode == 'o'                  |let l:prefix = 'normal! '
  else                                                   |return
  endif
  if a:direction == 0 | let l:delta = 1 | let l:fc = 'f' | let l:mc = 'l' | let Findex = function('stridx')
  else                | let l:delta =-1 | let l:fc = 'F' | let l:mc = 'h' | let Findex = function('strridx')
  endif
  let l:pos = col('.') - 1
  let l:c1 = 0
  let l:c2 = 0
  " let l:cpos = getcurpos()
  " echom 'fc=' . l:fc . ' count=' . a:count . ' mode=' . a:mode . ' visualmode=' . visualmode() .
  "             \' prefix=' .  l:prefix . ' pos=' . l:pos . ' virtcol=' . virtcol('.') . ' getcurpos=[' .  l:cpos[1] . ',' . l:cpos[2] . ']'
  if a:0 > 0 && strlen(a:1) > 0 | let l:c1 = strgetchar(a:1, 0) | endif
  if a:0 > 0 && strlen(a:1) > 1 | let l:c2 = strgetchar(a:1, 1) | endif
  if l:c1 == 0  | let l:c1 = getchar() | endif
  if l:c1 == 27 | return | endif
  if l:c2 == 0  | let l:c2 = getchar() | endif
  if l:c2 == 27 | execute l:prefix . a:count . l:fc . nr2char(l:c1) | return | endif
  let l:target = nr2char(l:c1) . nr2char(l:c2)
  if a:0 == 0
    let g:MotionSSaved#exist=1
    let g:MotionSSaved#mode=a:mode
    let g:MotionSSaved#dir=a:direction
    let g:MotionSSaved#count=a:count
    let g:MotionSSaved#keys=l:target
  endif

  let l:i = 0
  let l:pp = l:pos + l:delta - 1
  let l:line = getline('.')
  while l:i < a:count
    let l:idx = Findex( l:line, l:target, l:pp )
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
fu! RecordFT(action)
  let l:c1 = getchar() | if l:c1 == 27 |                                                   | return | endif
  let g:MotionSSaved#exist=0
  " let g:Saved0=a:count . a:action0 . nr2char(l:c1)
  " let g:Saved1=a:count . a:action1 . nr2char(l:c1)
  execute 'normal! ' . v:count1 . a:action . nr2char(l:c1)
endf
fu! MotionSReplay(action)
  if g:MotionSSaved#exist > 0
    let l:direction = g:MotionSSaved#dir
    if a:action == ',' | let l:direction = !l:direction | endif
"    echo 'l:direction=' . l:direction
    call MotionS(g:MotionSSaved#mode, l:direction, g:MotionSSaved#count, g:MotionSSaved#keys)
  else
     execute 'normal! ' . a:action
  endif
endf
nnoremap <silent> s :<C-u>call MotionS('n', 0, v:count1)<cr>
onoremap <silent> s :<C-u>call MotionS('o', 0, v:count1)<cr>
vnoremap <silent> s :<C-u>call MotionS(visualmode(), 0, v:count1)<cr>
nnoremap <silent> S :<C-u>call MotionS('n', 1, v:count1)<cr>
onoremap <silent> S :<C-u>call MotionS('o', 1, v:count1)<cr>
vnoremap <silent> S :<C-u>call MotionS(visualmode(), 1, v:count1)<cr>

nnoremap <silent> t :<C-u>call RecordFT('t')<cr>
nnoremap <silent> T :<C-u>call RecordFT('T')<cr>
nnoremap <silent> f :<C-u>call RecordFT('f')<cr>
nnoremap <silent> F :<C-u>call RecordFT('F')<cr>
nnoremap <silent> ; :<C-u>call MotionSReplay(';')<cr>
nnoremap <silent> , :<C-u>call MotionSReplay(',')<cr>

