#package sc.ript.color

class RGB

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

