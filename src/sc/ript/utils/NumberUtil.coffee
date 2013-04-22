#package sc.ript.utils

class NumberUtil

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

