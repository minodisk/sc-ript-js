class Point

  @equals: (pt0, pt1) ->
    pt0.equals pt1

  @dotProduct: (pt0, pt1) ->
    pt0.x * pt1.x + pt0.y * pt1.y

  @angle: (pt0, pt1) ->
    pt1.subtract(pt0).angle()

  @distance: (pt0, pt1) ->
    pt1.subtract(pt0).length()

  @interpolate: (pt0, pt1, ratio) ->
    pt0.add pt1.subtract(pt0).multiply(ratio)
    
  @inflate: (src, dst, pixel) ->
    dx = src.x - dst.x
    dy = src.y - dst.y
    d = Math.sqrt dx * dx + dy * dy
    ratio = 1 + pixel / d
    @interpolate src, dst, ratio


  constructor: (x = 0, y = 0) ->
    @x = +x
    @y = +y

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

  equals: (pt) ->
    @x is pt.x and @y is pt.y

  add: (pt) ->
    new Point @x + pt.x, @y + pt.y

  subtract: (pt) ->
    new Point @x - pt.x, @y - pt.y

  multiply: (value) ->
    new Point @x * value, @y * value

  divide: (value) ->
    new Point @x / value, @y / value

