#package sc.ript.filter


# |R|   |m0  m1  m2  m3 ||r|   |m4 |
# |G| = |m5  m6  m7  m8 ||g| + |m9 |
# |B|   |m10 m11 m12 m13||b|   |m14|
# |A|   |m15 m16 m17 m18||a|   |m19|
class ColorMatrixFilter extends Filter

  constructor: (@matrix) ->
    super()

  _evaluatePixel: (pixels, x, y, width, height) ->
    m = @matrix
    [r, g, b, a] = pixels[y][x]
    [
      r * m[0] + g * m[1] + b * m[2] + a * m[3] + m[4]
      r * m[5] + g * m[6] + b * m[7] + a * m[8] + m[9]
      r * m[10] + g * m[11] + b * m[12] + a * m[13] + m[14]
      r * m[15] + g * m[16] + b * m[17] + a * m[18] + m[19]
    ]

