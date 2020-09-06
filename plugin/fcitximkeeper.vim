scriptencoding utf-8

if exists('g:loaded_fcitximkeeper')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if has("unix")
  augroup FcitxImKeeper
    autocmd!
    autocmd BufWinEnter  * let b:input_toggle = 0
    autocmd InsertEnter  * call ToggleOnEnter()
    autocmd CmdlineLeave * call ToggleOnLeave()
  augroup END

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

  nnoremap <expr> / CmdEnter("/")
  nnoremap <expr> ? CmdEnter("?")

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

  " Enable IM according to toggle_state -> receive char -> return command
  function! CharWithIMControl(cmd)
    call ToggleOnEnter()

    let b:char = nr2char(getchar())
    let b:cmd = a:cmd . b:char

    call ToggleOnLeave()
    return b:cmd
  endfunction

  function! CmdEnter(cmd)
    call ToggleOnEnter()
    return a:cmd
  endfunction

endif

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_fcitximkeeper = 1
