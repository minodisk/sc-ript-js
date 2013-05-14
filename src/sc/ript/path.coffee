class sc.ript.path

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
    return normalized.join '/'

