if exists("g:loaded_exampleplugin")
    finish
endif
let g:loaded_exampleplugin = 1

function! StartServer()
	let current_directory = getcwd()
	call luaeval('require("live-server").start(_A)', current_directory)
endfunction

command! -nargs=0 StartServer call StartServer()
