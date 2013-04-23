#package sc.ript.display

class DisplayObject

  @_RADIAN_PER_DEGREE: Math.PI / 180

  constructor: ->
    @x = @y = @rotation = 0
    @scaleX = @scaleY = 1

  matrix: ->
    new Matrix()
      .scale(@scaleX, @scaleY)
      .rotate(@rotation * DisplayObject._RADIAN_PER_DEGREE)
      .translate(@x, @y)


