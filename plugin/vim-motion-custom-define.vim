
" vim: ts=4 sw=4 sts=4 fdm=marker et :
" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" Functions, helper {{{1
" Self define operators helping functions, like y/d/c key {{{2
":h map-operator
"More details from http://learnvimscriptthehardway.stevelosh.com/chapters/33.html
function! operator#general#motion(motion_wise, ...)
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
function! operator#define(keyseq, cmd, ...)
  if 0 < a:0  | let additional_settings = '\|' . join(a:000)
  else        | let additional_settings = ''
  endif

  execute printf(('nnoremap <script> <silent> %s ' .
    \               ':let g:operator#command="%s"<cr>' .
    \               ':set opfunc=operator#general#motion<cr>' .
    \               '%s' .
    \               'g@'),
    \              a:keyseq,
    \              a:cmd,
    \              additional_settings)
    "\               ':<C-u>let g:operator#command="%s"<cr>%s' .
  execute printf(('vnoremap <script> <silent> %s ' .
    \               ':<C-u>call OperatorGeneralMotion(visualmode(), "%s")<cr>' .
    \               ' '),
    \              a:keyseq,
    \              a:cmd,
    \              )
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

call OperatorDefine('<Leader>A',  'call AckAdanced(\"Ack\", \"%s\")')
call OperatorDefine('<Leader>ala',  'call AckAdanced(\"LAck\", \"%s\")')
call OperatorDefine('<Leader>aa',  'call AckAdanced(\"AckAdd\", \"%s\")')
call OperatorDefine('<Leader>alaa',  'call AckAdanced(\"LAckAdd\", \"%s\")')
call OperatorDefine('<Leader>ah', 'AckHelp! -Q \"%s\"')
call OperatorDefine('<Leader>alh', 'LAckHelp! -Q \"%s\"')
call OperatorDefine('<Leader>aw', 'AckWindow! -Q \"s\"')
call OperatorDefine('<Leader>alw', 'LAckWindow! -Q \"s\"')
call OperatorDefine('<Leader>as', 'AckFromSearch! -Q \"%s\"')
function! AckAdanced(action, kw)
"    :Ack! -Q a:kw <C-R>=expand("%p:h")<cr><cr>
    silent execute a:action . "! -Q \"" . escape(a:kw, '''\\"') . "\" \"" . expand("%:p:h") . "\""
endfunction
" }}}


