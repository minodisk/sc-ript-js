class sc.ript.util.StringUtil

  @padLeft: (str, len, pad) ->
    str = '' + str
    while str.length < len
      str = pad + str
    str

  @padRight: (str, len, pad) ->
    str = '' + str
    while str.length < len
      str += pad
    str

