if exists("g:loaded_gitweb")
    finish
endif
let g:loaded_gitweb = 1

if !exists('g:fugitive_browse_handlers')
    let g:fugitive_browse_handlers = []
endif
if index(g:fugitive_browse_handlers, function('gitweb#fugitive_url')) < 0
    call insert(g:fugitive_browse_handlers, function('gitweb#fugitive_url'))
endif
