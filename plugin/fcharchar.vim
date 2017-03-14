" fcharchar.vim - extended f motion
" Author:       Abraham Sue
" Version:      1.0
" GetLatestVimScripts: 0 1 :AutoInstall: fcharchar.vim
" Test write s<Char><Char> motion in simplest way
" [X]: 1. How to get current position in visual mode; use col("'>")
" TDB: 2. How to get real mode in function
" New feature: Add operator define support

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
"  echom l:delta .' '. l:fc .' '. l:mc .' '. l:findex . ' '. l:posmark . ' ' . l:prefix
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

" operator map feature " {{{1
" Self define operators helping functions, like y/d/c key
":h map-operator
"More details from http://learnvimscriptthehardway.stevelosh.com/chapters/33.html
function! OperatorGeneralMotion(motion_wise, ...)
  let sel_save = &selection | let &selection = "inclusive" | let reg_save = @@
"   echomsg "motion_wise = " . a:motion_wise
"   echomsg "a:0 = " . a:0
"   if a:0 | echomsg "a:0 is set" | endif
"   if a:0 > 0 | echomsg "a:1 = " . a:1 | endif
"   if a:0 > 1 | echomsg "a:2 = " . a:2 | endif
  " normal mode motion, motion_wise = char, a:0 = 0
  " visual mode v,      motion_wise = v,    a:0 = 1, a:1 = "Ack! %s"
  " visual mode V,      motion_wise = V,    a:0 = 1, a:1 = "Ack! %s"
  " visual mode <C-v>,  motion_wise = ,    a:0 = 1, a:1 = "Ack! %s"

  if a:0 | silent exe "normal! gvy" | let fmt = a:1
  elseif a:motion_wise == 'V' | silent exe "normal! '[V']y" | let fmt = a:1
  else | silent exe "normal! `[v`]y" | let fmt = g:operator#command
  endif

"  let l:safe_text = substitute(@@, " ", "\\ ", "g") | echom printf(fmt, l:safe_text) | execute printf(fmt, l:safe_text)
  execute printf(fmt, @@)
  let &selection = sel_save | let @@ = reg_save
endfunction
function! s:operator_param_motion(motion_wise, ...)
  let sel_save = &selection | let &selection = "inclusive" | let reg_save = @@
"   echomsg "motion_wise = " . a:motion_wise
"   echomsg "a:0 = " . a:0
"   if a:0 | echomsg "a:0 is set" | endif
"   if a:0 > 0 | echomsg "a:1 = " . a:1 | endif
"   if a:0 > 1 | echomsg "a:2 = " . a:2 | endif
  " normal mode motion, motion_wise = char, a:0 = 0
  " visual mode v,      motion_wise = v,    a:0 = 1, a:1 = "Ack! %s"
  " visual mode V,      motion_wise = V,    a:0 = 1, a:1 = "Ack! %s"
  " visual mode <C-v>,  motion_wise = ,    a:0 = 1, a:1 = "Ack! %s"

  if a:0 | silent exe "normal! gvy" | let l:cmd = a:1
  elseif a:motion_wise == 'V' | silent exe "normal! '[V']y" | let l:cmd = a:1
  else | silent exe "normal! `[v`]y" | let l:cmd = g:operator_commands
  endif

"  let l:safe_text = substitute(@@, " ", "\\ ", "g") | echom printf(fmt, l:safe_text) | execute printf(fmt, l:safe_text)
  " execute printf(fmt, @@)
  let l:cmd = substitute(l:cmd, "<bar>", "|", "g")
  let l:cmd = substitute(l:cmd, "<SEL>", escape(@@, '''\\"'), "g")
  execute l:cmd
  let &selection = sel_save | let @@ = reg_save
endfunction
function! s:operator_range_command(motion_wise, ...)
  if a:0 | silent exe "normal! gv<cr>" | let l:cmd = a:1
  elseif a:motion_wise == 'V' | silent exe "normal! '[V']<cr>" | let l:cmd = a:1
  else | silent exe "normal! `[v`]<cr>" | let l:cmd = g:operator_commands
  endif

  let l:cmd = substitute(l:cmd, "<bar>", "|", "g")
  let l:cmd = substitute(l:cmd, "<SEL>", escape(@@, '''\\"'), "g")
  execute "'[,']" l:cmd
endfunction
function! s:operator_define(keyseq, func_name, cmd)
  " echom printf(('nnoremap <script> <silent> %s :set opfunc=%s<cr>:let g:operator_commands=''%s''<cr>g@'),
  "   \              a:keyseq, a:func_name, a:000)
  let l:cmd = substitute(a:cmd, "|", "<bar>", "g")
  execute printf(('nnoremap <script> <silent> %s :set opfunc=%s<cr>:let g:operator_commands=''%s''<cr>g@'),
    \              a:keyseq, a:func_name, l:cmd)
  execute printf(('vnoremap <script> <silent> %s :<C-u>call %s(visualmode(), ''%s'')<cr>'),
    \              a:keyseq, a:func_name, l:cmd)
  execute printf('onoremap %s  g@', a:keyseq)
endfunction
" Some code as reference {{{3
"    nmap <silent> <Leader>b :set opfunc=GeneralMotion<cr>g@
"    vmap <silent> <Leader>b :<C-U>call GeneralMotion(visualmode(), 1)<cr>
"    function! GeneralMotion(type, sec)
"      let sel_save = &selection | let &selection = "inclusive" | let reg_save = @@
"
"      echom a:sec
"      if a:0  " Invoked from Visual mode, use gv command.
"        silent exe "normal! gvy"
"      elseif a:type == 'line'
"        silent exe "normal! '[V']y"
"      else
"        silent exe "normal! `[v`]y"
"      endif
"
"      let &selection = sel_save | let @@ = reg_save
"    endfunction
"    map <Leader>A <Plug>(operator-ack-motion)
"    call operator#user#define('ack-motion', 'AckMotion')
"    function! AckMotion(motion_wise)
"      let sel_save = &selection | let &selection = "inclusive" | let reg_save = @@
"
"      if a:0 | silent exe "normal! gvy"
"      elseif a:motion_wise == 'line' | silent exe "normal! '[V']y"
"      else | silent exe "normal! `[v`]y"
"      endif
"
"    "  echom shellescape(@@)
"    "  silent execute "grep! -R " . shellescape(@@) . " ."
"      silent execute "Ack! ". shellescape(@@)
"      let &selection = sel_save | let @@ = reg_save
"    endfunction
"}}}
"}}}
"}}}
function! s:operator_map(keyseq, ...)  "{{{2
  call s:operator_define(a:keyseq, '<SID>operator_param_motion', join(a:000))
endfunction
function! s:operator_range_command_map(keyseq, ...)  "{{{2
  call s:operator_define(a:keyseq, '<SID>operator_range_command', join(a:000))
  " return call('s:operator_define', [ a:keyseq, '<SID>operator_range_command' ] + a:000)
endfunction
function! s:operator_function_map(keyseq, ...)  "{{{2
  call s:operator_define(a:keyseq, '<SID>operator_range_command', join(a:000))
  " return call('s:operator_define', [ a:keyseq, '<SID>operator_param_motion' ] + a:000)
endfunction
"}}}

command! -nargs=+ -complete=command OperatorMap             call s:operator_map(<f-args>)
command! -nargs=+ -complete=command OperatorRangeCommandMap call s:operator_range_command_map(<f-args>)
command! -nargs=+ -complete=command OperatorFunctionMap     call s:operator_function_map(<f-args>)
"no need escape space, edit will take all string after it
" OperatorMap <Leader>o :edit <SEL>
" OperatorMap <Leader>h :help! <SEL> | echom "<SEL>"
" OperatorRangeCommandMap H s/ \\+/ /g
"OperatorFunctionMap <Leader>H MyFunction

" vimrc
" test space
" }}}
