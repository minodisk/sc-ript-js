class sc.ript.util.Iterator

  @count: (len, callback, step = 1) ->
    return if step is 0 or len <= 0
    if step > 0
      i = 0
      while i < len
        return if callback(i) is false
        i += step
    else
      i = len
      while (i += step) >= 0
        return if callback(i) is false
        

