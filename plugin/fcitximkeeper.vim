scriptencoding utf-8

if exists('g:loaded_fcitximkeeper')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if has("unix") && !( has("mac") && has("gui") )
  augroup FcitxImKeeper
    autocmd!
    autocmd BufWinEnter  * let b:input_toggle = 0
    autocmd InsertEnter  * call ToggleOnEnter()

    " autocmd CmdlineLeave * call ToggleOnLeave()
    " This autocmd don't work with deoplete with vim 8.2 on 2019/09/06
    " (Slow and sometimes '<Plug>_' is inserted automatically). work well with neocomplete.
    " Instead of this line, Toggle IM by mapping <CR> in commandline-mode below
  augroup END

  " Toggle IM when leaving command-line-mode with enter. Also effective with '/' or '?' command
  cnoremap <silent> <CR> <C-\>eSaveCmdline()<CR><C-\>eToggleOnLeave()<CR><C-\>eRestoreCmdline()<CR><CR>
  " Toggle IM when leaving command-line-mode with backspace
  cnoremap <expr>   <BS> ToggleOnCmdLeaveWithBS()

  if has("gui_running")
    " InsertLeave on gvim not working
    inoremap <expr> <ESC> ToggleOnInsLeave()
  else
    augroup FcitxImKeeper
      autocmd InsertLeave * call ToggleOnLeave()
    augroup END
  endif

  nnoremap <expr> f CharWithIMControl("f")
  nnoremap <expr> F CharWithIMControl("F")

  onoremap <expr> f CharWithIMControl("f")
  onoremap <expr> F CharWithIMControl("F")
  onoremap <expr> t CharWithIMControl("t")
  onoremap <expr> T CharWithIMControl("T")

  nnoremap <expr> / ToggleOnCmdEnter("/")
  nnoremap <expr> ? ToggleOnCmdEnter("?")

  function! SaveCmdline()
    let b:save_cmdline = getcmdline()
    let b:save_cmdpos  = getcmdpos()
    return ''
  endfunction

  function! RestoreCmdline()
    call setcmdpos(b:save_cmdpos)
    return b:save_cmdline
    endif
  endfunction

  function! ToggleOnEnter()
    if !exists('b:input_toggle')
      return
    endif

    let s:input_status = system("fcitx-remote")
    if s:input_status != 2 && b:input_toggle == 1
      call system("fcitx-remote -o")
      let b:input_toggle = 0
    endif
  endfunction

  function! ToggleOnLeave()
    if !exists('b:input_toggle')
      return
    endif
    let s:input_status = system("fcitx-remote")
    if s:input_status == 2
      call system("fcitx-remote -c")
      let b:input_toggle = 1
    endif
  endfunction

  function! ToggleOnInsLeave()
    call ToggleOnLeave()
    return "\<ESC>"
  endfunction

  " To be called by backspace
  function! ToggleOnCmdLeave()
    if b:save_cmdpos == 1
      call ToggleOnLeave()
    endif
    return ''
  endfunction

  " Enable IM according to toggle_state -> receive char -> return command
  function! CharWithIMControl(cmd)
    call ToggleOnEnter()

    let l:char = nr2char(getchar())
    let l:cmd = a:cmd . l:char

    call ToggleOnLeave()
    return l:cmd
  endfunction

  function! ToggleOnCmdEnter(cmd)
    call ToggleOnEnter()
    return a:cmd
  endfunction

  function! ToggleOnCmdLeaveWithBS()
    call SaveCmdline()
    call ToggleOnCmdLeave()
    call feedkeys("\<BS>\<BS>", "in")
  endfunction

endif

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_fcitximkeeper = 1
