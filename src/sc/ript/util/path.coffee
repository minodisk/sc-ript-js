class sc.ript.util.Path

  splitPathRe = /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/
  splitPath = (filename) ->
    splitPathRe.exec(filename).splice(1)


  @join: (pathes...) ->
    pathes = pathes.join('/').replace(/\/{2,}/g, '/').split('/');
    normalized = []
    for path in pathes
      switch path
        when '.'
        # do nothing
          break
        when '..'
          last = normalized[normalized.length - 1]
          if last? && last isnt '..'
            normalized.pop()
          else
            normalized.push path
          break
        else
          normalized.push path
          break
    normalized.join '/'

  @dirname: (path) ->
    [ root, dir ] = splitPath path
    return '.' if not root? and not dir?
    if dir
      dir = dir.substr 0, dir.length - 1
    root + dir


  @basename: (path, ext) ->
    [ {},
    {},
      f ] = splitPath path
    if ext and f.substr(-1 * ext.length) is ext
      f = f.substr 0, f.length - ext.length
    f

  @extname: (path) ->
    splitPath(path)[3]


