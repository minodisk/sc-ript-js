class sc.ript.util.URL

  splitURLRe = /^((\S+?:)(?:\/\/)?(([^\/:]+)(:\d+)?))([^?#]*)(\?[^#]*)?(#[\s\S]*)?$/

  @parse: (url) ->
    r = splitURLRe.exec url
    for v, i in r
      unless v?
        r[i] = ''
    [href, origin, protocol, host, hostname, port, pathname, search, hash] = r
    href    : href
    origin  : origin
    protocol: protocol
    host    : host
    hostname: hostname
    port    : port
    pathname: pathname
    search  : search
    hash    : hash
