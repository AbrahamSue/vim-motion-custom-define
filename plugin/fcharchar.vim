" fcharchar.vim - extended f motion
" Author:       Abraham Sue
" Version:      1.0
" GetLatestVimScripts: 0 1 :AutoInstall: fcharchar.vim
" Test write s<Char><Char> motion in simplest way
" [X]: 1. How to get current position in visual mode; use col("'>")
" TDB: 2. How to get real mode in function
" New feature: Add operator define support

if exists("g:loaded_fcharchar") || &cp || v:version < 700
  finish
endif
let g:loaded_fcharchar = 1

let s:motionsaved_exist=0
let s:motionsaved_mode=''
let s:motionsaved_dir=0
let s:motionsaved_count=1
let s:motionsaved_keys=''
let s:motion_last_run_timestamp=reltime()
let s:config = {
  \ 'dir': [
      \ [  1, 'f', 'l', 'stridx'  ],
      \ [ -1, 'F', 'h', 'strridx' ],
    \ ],
  \ 'mode' : { 'v': 'gv', 'V': 'gv',  '': 'gv', 'n': ' ', 'o': ' ' },
  \ 'posmark' : {'v': "'>", 'V': "'>",  '': "'>", 'n': ".", 'o': "." },
  \ 'postune' : {'v': 0, 'V': 0,  '': 0, 'n': 0, 'o': 1 },
  \}
fu! s:readchar(...)
  " echom "Calling readchar ".join(a:000,',')
  if ! a:0 | return getchar() | endif
  let l:max = a:1 | let l:ts0 = reltime() | let l:elapsed = 0
  while l:elapsed < l:max
    if getchar(1)|return getchar()|endif
    sleep 10m
    let l:elapsed = str2float(reltimestr(reltime(l:ts0)))
  endwhile
  return 27
endf
" str2float(reltimestr(reltime(reltime()))) =5.0e-6
fu! s:fmotion_rbs(mode, direction, count, ...)
  let l:elapsed = str2float(reltimestr(reltime(s:motion_last_run_timestamp)))
  if l:elapsed > s:fcharchar_timeout_repeat
    call s:fmotion(a:mode, a:direction, a:count)
  elseif xor(a:direction, s:motionsaved_dir)
    call s:replay(',')
  else
    call s:replay(';')
  endif
endf
fu! s:fmotion(mode, direction, count, ...)
  if !has_key(s:config.mode, a:mode) | return | endif
  let l:prefix = 'normal! ' . s:config.mode[a:mode]
  let [ l:delta, l:fc, l:mc, l:findex] = s:config.dir[!!a:direction]
  let l:posmark = s:config.posmark[a:mode]
  let l:postune = s:config.postune[a:mode]                      "position tune for omap, one character diff
  let l:postune_onechar = (a:direction)? 0:(l:postune)          "single character only need tune in forward direction
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

  let l:line = getline('.')
  let l:pp = l:pos + 2 * l:delta - 1
  if l:c1 == 0  | let l:c1 = s:readchar() | endif
  if l:c1 == 27 | return | else | let l:c1 = nr2char(l:c1) | endif

  if g:fcharchar_one_instance_go 
    " l:c1num = strlen(substitute(l:line, '[^'.l:c1.']', '', 'g'))
    let l:c1num = len( split( l:line, l:c1, 1 ) ) - 1
    if l:c1num == 1
      let l:idx = stridx( l:line, l:c1, 0 )
      if l:idx >= 0| execute l:prefix . (l:postune_onechar+1+l:idx) . '|' | return | endif
    endif
  endif

  if l:c2 == 0  | let l:c2 = s:readchar(s:fcharchar_timeout_2ndchar) | endif
  if l:c2 == 27 | execute l:prefix . (l:postune_onechar+a:count) . l:fc . l:c1 | return | endif
  let l:target = l:c1 . nr2char(l:c2)
  if a:0 == 0
    let s:motionsaved_exist=1
    let s:motionsaved_mode=a:mode
    let s:motionsaved_dir=a:direction
    let s:motionsaved_count=a:count
    let s:motionsaved_keys=l:target
  endif

  let l:i = 0
  while l:i < a:count
    let l:idx = function(l:findex)( l:line, l:target, l:pp )
    if l:idx < 0 | break | endif
    let l:i += 1
    let l:pp = l:idx + l:delta
  endwhile
  if l:idx >= 0
    let l:idx = ( l:idx - l:pos + l:postune ) * l:delta
    if l:idx > 0 | execute l:prefix . l:idx . l:mc | endif
  endif
  let s:motion_last_run_timestamp = reltime()

  "Feature: use the same f key to jump next, F jump prev
  " let l:c3 = s:readchar(l:timeout)
  " if l:c3 == char2nr(s:fcharchar_nr)
  "   s:replay(";")
  " elseif l:c3 == char2nr(s:fcharchar_nr2)
  "   s:replay(",")
  " endif
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
    call s:fmotion(s:motionsaved_mode, (a:action == ',')?(!s:motionsaved_dir):(s:motionsaved_dir), s:motionsaved_count, s:motionsaved_keys)
  else
     execute printf(":normal! %s", a:action)
  endif
endf
" define several global variables, to control this plugin's behavior
let g:fcharchar_visual = 1
" let g:fcharchar_repeat_by_self = 1

if !exists('g:fcharchar_key')
  let g:fcharchar_key = 'f'
endif
if !exists('g:fcharchar_key2')
  let g:fcharchar_key2 = toupper( g:fcharchar_key )
endif
" if !exists('g:fcharchar_position')
"   " 0, 1, 2, 0 X 1 X 2, X stands for character 012 stands for position
"   let g:fcharchar_position = 1
" endif
if !exists('g:fcharchar_one_instance_go')
  let g:fcharchar_one_instance_go = 0
endif
if !exists('g:fcharchar_timeout')
  let s:fcharchar_timeout_repeat  = 4.0
  let s:fcharchar_timeout_2ndchar = 2.0
elseif type(g:fcharchar_timeout) == 3
  let s:fcharchar_timeout_repeat  = g:fcharchar_timeout[0]
  let s:fcharchar_timeout_2ndchar = g:fcharchar_timeout[1]
elseif type(g:fcharchar_timeout) == 4
  let s:fcharchar_timeout_repeat  = g:fcharchar_timeout["repeat"]
  let s:fcharchar_timeout_2ndchar = g:fcharchar_timeout["2ndchar"]
" elseif type(g:fcharchar_timeout) == 5
"   let s:fcharchar_timeout_repeat  = g:fcharchar_timeout
"   let s:fcharchar_timeout_2ndchar = g:fcharchar_timeout
else
  let s:fcharchar_timeout_repeat  = g:fcharchar_timeout
  let s:fcharchar_timeout_2ndchar = g:fcharchar_timeout
endif

let s:fcharchar_nr=char2nr(g:fcharchar_key)
let s:fcharchar_nr2=char2nr(g:fcharchar_key2)

if tolower(g:fcharchar_key) != 'f'
  nnoremap <silent> f :<C-u>call <SID>record('f')<cr>
  nnoremap <silent> F :<C-u>call <SID>record('F')<cr>
endif
nnoremap <silent> t :<C-u>call <SID>record('t')<cr>
nnoremap <silent> T :<C-u>call <SID>record('T')<cr>
if exists('g:fcharchar_repeat_by_self') && g:fcharchar_repeat_by_self
  let s:motion__func_suffix = '_rbs'
  " disable these lines, as f<cr> will reduce response on f command
  " change to <cr>f/F/t/T
  execute 'noremap <silent> <cr>'.g:fcharchar_key. ' :<C-u>call <SID>replay(";")<cr>'
  execute 'noremap <silent> <cr>'.g:fcharchar_key2.' :<C-u>call <SID>replay(",")<cr>'
  noremap <silent> <cr>t :<C-u>call <SID>replay(";")<cr>'
  noremap <silent> <cr>T :<C-u>call <SID>replay(",")<cr>'
else
  let s:motion__func_suffix = ''

  nnoremap <silent> ; :<C-u>call <SID>replay(';')<cr>
  nnoremap <silent> , :<C-u>call <SID>replay(',')<cr>
endif

execute 'nnoremap <silent> '.g:fcharchar_key.'  :<C-u>call <SID>fmotion'.s:motion__func_suffix.'("n", 0, v:count1)<cr>'
execute 'onoremap <silent> '.g:fcharchar_key.'  :<C-u>call <SID>fmotion'.s:motion__func_suffix.'("o", 0, v:count1)<cr>'
execute 'vnoremap <silent> '.g:fcharchar_key.'  :<C-u>call <SID>fmotion'.s:motion__func_suffix.'(visualmode(), 0, v:count1)<cr>'
execute 'nnoremap <silent> '.g:fcharchar_key2.' :<C-u>call <SID>fmotion'.s:motion__func_suffix.'("n", 1, v:count1)<cr>'
execute 'onoremap <silent> '.g:fcharchar_key2.' :<C-u>call <SID>fmotion'.s:motion__func_suffix.'("o", 1, v:count1)<cr>'
execute 'vnoremap <silent> '.g:fcharchar_key2.' :<C-u>call <SID>fmotion'.s:motion__func_suffix.'(visualmode(), 1, v:count1)<cr>'





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
function! s:escape_cmd(icount, iregister, icmd, isel)
  " escape ' " firstly, and then escape \\ including the previous escape
  " generated \\
  let l:sel = escape(escape(a:isel, '''"'), '\\')
  let l:sel = substitute(l:sel, "\_n", "\_.", "g")
  let l:cmd = substitute(a:icmd, "<cr-q>", "<cr>", "g")
  let l:cmd = substitute(l:cmd, "<bar>", "|", "g")
  let l:cmd = substitute(l:cmd, "<count>", a:icount?a:icount:"", "g")
  let l:cmd = substitute(l:cmd, "<register>", a:iregister, "g")
  let l:cmd = substitute(l:cmd, "<SEL>", l:sel, "g")
  let l:cmd = substitute(l:cmd, "<SEL-q>", "'".l:sel."'", "g")
  let l:cmd = substitute(l:cmd, "<q>", "'", "g")
  let l:cmd = substitute(l:cmd, "<qq>", '"', "g")
  let l:cmd = substitute(l:cmd, "<bs>",  '\\', "g")
  let l:cmd = substitute(l:cmd, "<bs1>", '\\', "g")
  let l:cmd = substitute(l:cmd, "<bs2>", '\\\\', "g")
  " echom 'icount=' . a:icount . ' iregister=' . a:iregister . ' icmd=' . a:icmd . ' isel=' . a:isel. ' l:sel=' .l:sel. ' l:cmd=' .l:cmd
  return l:cmd
endfunction
function! s:operator_param_motion(...)
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

  let l:errmsg = "ERR10099: operator_param_montion called with 0 parameter. Should 1 or more"
  if    !a:0           | echom l:errmsg              | return
  elseif a:1 == 'char' | silent exe "normal! `[v`]y" | let [l:count, l:register, l:cmd] = g:operator_commands
  elseif a:1 == 'V'    | silent exe "normal! '[V']y" | let [l:count, l:register, l:cmd] = a:000[1:]
  else                 | silent exe "normal! gvy"    | let [l:count, l:register, l:cmd] = a:000[1:]
  endif
  " execute s:escape_cmd(l:count, l:register, l:cmd, @@)
  let g:operator_last_cmd = s:escape_cmd(l:count, l:register, l:cmd, @@)
  execute g:operator_last_cmd
  echom g:operator_last_cmd
  let &selection = sel_save | let @@ = reg_save
endfunction
function! s:operator_range_command(...)
  let l:errmsg = "ERR10099: operator_range_montion called with 0 parameter. Should 1 or more"
  if    !a:0           | echom l:errmsg              | return
  elseif a:1 == 'char' | let l:range = "'[,']"       | let [l:count, l:register, l:cmd] = g:operator_commands
  else                 | let l:range = "'<,'>"       | let [l:count, l:register, l:cmd] = a:000[1:]
  endif
  echom   l:range . s:escape_cmd(l:count, l:register, l:cmd, "")
  execute l:range . s:escape_cmd(l:count, l:register, l:cmd, "")
endfunction
function! s:operator_define(keyseq, func_name, cmd)
  " echom printf(('nnoremap <script> <silent> %s :set opfunc=%s<cr>:let g:operator_commands=''%s''<cr>g@'),
  "   \              a:keyseq, a:func_name, a:000)
  let l:cmd = substitute(a:cmd, "|", "<bar>", "g")
  execute printf(('nnoremap <script> <silent> %s :<C-u>let g:operator_commands=[v:count,v:register,''%s'']<cr>:set opfunc=%s<cr>g@'),
    \              a:keyseq, l:cmd, a:func_name)
  execute printf(('vnoremap <script> <silent> %s :<C-u>call %s(visualmode(), v:count,v:register, ''%s'')<cr>'),
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

command! -bang -nargs=+ -complete=command OperatorMap             call s:operator_map(<f-args>)
command! -bang -nargs=+ -complete=command OperatorRangeCommandMap call s:operator_range_command_map(<f-args>)
command! -bang -nargs=+ -complete=command OperatorFunctionMap     call s:operator_function_map(<f-args>)
"no need escape space, edit will take all string after it
" OperatorMap <Leader>o :edit <SEL>
" OperatorMap <Leader>h :help! <SEL> | echom "<SEL>"
" OperatorRangeCommandMap H s/ \\+/ /g
"OperatorFunctionMap <Leader>H MyFunction

" vimrc
" test space
" }}}
