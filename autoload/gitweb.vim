if exists('g:autoloaded_gitweb')
  finish
endif
let g:autoloaded_gitweb = 1

function! gitweb#homepage_for_url(url) abort
    let domains = get(g:, 'gitweb_urls', {})
    call map(copy(domains), 'substitute(v:val, "/$", "", "")')
    if empty(domains)
        return ''
    endif
    let domain_pattern = ''
    for domain in keys(domains)
        if domain_pattern != ''
            let domain_pattern .= '\|'
        endif
        let domain_pattern .= escape(split(domain, '://')[-1], '.')
    endfor
    let base = matchstr(a:url, '^\%(https\=://\|git://\|git@\|ssh://git@\)\=\zs\('.domain_pattern.'\)[/:].\{-\}\ze\%(\.git\)\=$')
    if empty(base)
        return ''
    else
        let parts = split(base, ':')
        return domains[parts[0]] . '?p=' . join(parts[1:-1], ':') . '.git'
    endif
endfunction


function! gitweb#fugitive_url(opts, ...) abort
    if a:0 || type(a:opts) != type({}) || !has_key(a:opts, 'repo')
        return ''
    endif

    let root = gitweb#homepage_for_url(get(a:opts, 'remote'))
    if empty(root)
        return ''
    endif

    if a:opts.path =~# '^\.git/refs/.'
        return root . ';a=shortlog;h=' . matchstr(a:opts.path,'^\.git/\zs.*')
    elseif a:opts.path =~# '^\.git\>'
        return root
    endif

    let url = root
    if a:opts.commit =~# '^\x\{40\}$'
        if a:opts.type ==# 'commit'
            let url .= ';a=commit'
        endif
        let url .= ';h=' . a:opts.repo.rev_parse(a:opts.commit . (a:opts.path == '' ? '' : ':' . a:opts.path))
    else
        if a:opts.type ==# 'blob' && empty(a:opts.commit)
            let url .= ';h='.a:opts.repo.git_chomp('hash-object', a:opts.path)
        else
            try
                let url .= ';h=' . a:opts.repo.rev_parse((a:opts.commit == '' ? 'HEAD' : ':' . a:opts.commit) . ':' . a:opts.path)
            catch /^fugitive:/
                call s:throw('fugitive: cannot browse uncommitted file')
            endtry
        endif
        let root .= ';hb=' . matchstr(a:opts.repo.head_ref(),'[^ ]\+$')
    endif

    if a:opts.path !=# ''
        let url .= ';f=' . substitute(a:opts.path, '\/$', '', '')
    endif

    if get(a:opts, 'line1')
        let url .= '#l' . a:opts.line1
    endif

    return url
endfunction
