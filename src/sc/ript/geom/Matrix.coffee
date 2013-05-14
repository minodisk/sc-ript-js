class sc.ript.geom.Matrix

  constructor: (@m11 = 1, @m12 = 0, @m21 = 0, @m22 = 1, @tx = 0, @ty = 0) ->

  translate  : (x = 0, y = 0) ->
    @concat new Matrix 1, 0, 0, 1, x, y
    @

  scale: (x = 1, y = 1) ->
    @concat new Matrix x, 0, 0, y, 0, 0
    @

  rotate: (theta) ->
    s = Math.sin theta
    c = Math.cos theta
    @concat new Matrix c, s, -s, c, 0, 0
    @

  concat: (matrix) ->
    { m11, m12, m21, m22, tx, ty } = @
    @m11 = m11 * matrix.m11 + m12 * matrix.m21
    @m12 = m11 * matrix.m12 + m12 * matrix.m22
    @m21 = m21 * matrix.m11 + m22 * matrix.m21
    @m22 = m21 * matrix.m12 + m22 * matrix.m22
    @tx = tx * matrix.m11 + ty * matrix.m21 + matrix.tx
    @ty = tx * matrix.m12 + ty * matrix.m22 + matrix.ty
    @

  invert: ->
    { m11, m12, m21, m22, tx, ty } = @
    d = m11 * m22 - m12 * m21
    @m11 = m22 / d
    @m12 = -m12 / d
    @m21 = -m21 / d
    @m22 = m11 / d
    @m41 = (m21 * ty - m22 * tx) / d
    @m42 = (m12 * tx - m11 * ty) / d
    @
