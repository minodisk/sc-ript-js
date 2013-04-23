#package sc.ript.color

class RGB

  @average: (rgbs...) ->
    r = g = b = 0
    for rgb in rgbs
      r += rgb.r
      g += rgb.g
      b += rgb.b
    length = rgbs.length
    r /= length
    g /= length
    b /= length
    new RGB r, g, b


  constructor: (@r, @g, @b) ->
    if arguments.length is 1
      hex = r
      @r = hex >> 16 & 0xff
      @g = hex >> 8 & 0xff
      @b = hex & 0xff
    @normalize()

  normalize: ->
    @r &= 0xff
    @g &= 0xff
    @b &= 0xff

  toHex: ->
    @r << 16 | @g << 8 | @b

