#package sc.ript.geom

class Point

  @equals: (pt0, pt1) ->
    pt0.x is pt1.x and pt0.y is pt1.y

  @dotProduct: (pt0, pt1) ->
    pt0.x * pt1.x + pt0.y * pt1.y

  @angle: (pt0, pt1) ->
    pt1.subtract(pt0).angle()

  @distance: (pt0, pt1) ->
    pt1.subtract(pt0).length()

  @interpolate: (pt0, pt1, ratio) ->
    pt0.add pt1.subtract(pt0).multiply(ratio)


  constructor: (@x = 0, @y = 0) ->

  angle      : (value) ->
    return Math.atan2 @y, @x unless value?

    length = @length()
    @x = length * Math.cos value
    @y = length * Math.sin value

  length: (value) ->
    return Math.sqrt @x * @x + @y * @y unless value?

    angle = @angle()
    @x = value * Math.cos angle
    @y = value * Math.sin angle

  clone: ->
    new Point @x, @y

  add: (pt) ->
    new Point @x + pt.x, @y + pt.y

  subtract: (pt) ->
    new Point @x - pt.x, @y - pt.y

  multiply: (value) ->
    new Point @x * value, @y * value

  divide: (value) ->
    new Point @x / value, @y / value

