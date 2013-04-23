#package sc.ript.filter

class ThresholdFilter extends Filter

  # @param operation "<", "<=", ">", ">=", "==", "!="
  constructor: (@threshold, @operation) ->
    super()

  _evaluatePixel: (pixels, x, y, width, height) ->
    [r, g, b, a] = pixels[y][x]
    color = a << 24 | r << 16 | g << 8 | b
    switch @operation
      when "<"
        color = if color < @threshold then color else 0
      when "<="
        color = if color <= @threshold then color else 0
      when ">"
        color = if color > @threshold then color else 0
      when ">="
        color = if color >= @threshold then color else 0
      when "=="
        color = if color == @threshold then color else 0
      when "!="
        color = if color != @threshold then color else 0
    [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff, color >> 24 & 0xff]



