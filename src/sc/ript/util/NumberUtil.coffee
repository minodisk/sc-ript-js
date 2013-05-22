class sc.ript.util.NumberUtil

  @RADIAN_PER_DEGREE: Math.PI / 180
  @DEGREE_PER_RADIAN: 180 / Math.PI
  @KB               : 1024
  @MB               : @KB * @KB
  @GB               : @MB * @KB
  @TB               : @GB * @KB

  @degree: (radian) ->
    radian * @DEGREE_PER_RADIAN

  @radian: (degree) ->
    degree * @RADIAN_PER_DEGREE

  @signify: (value, digit) ->
    base = Math.pow 10, digit
    (value * base >> 0) / base

  @kb: (bytes) ->
    bytes / @KB

  @mb: (bytes) ->
    bytes / @MB

  @gb: (bytes) ->
    bytes / @GB

  @random: (a, b) ->
    a + (b - a) * Math.random()

  @toSplit3String: (value) ->
    value = "#{value}"
    while value isnt (tmp = value.replace /^([+-]?\d+)(\d\d\d)/, '$1,$2')
      value = tmp
    value

  @digitAt: (num, digit) ->
    str = "#{num}"
    return 0 if digit > str.length
    +str.substr -digit, 1

