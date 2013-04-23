#package sc.ript.color

class Color

  @toCSSString: (color, alpha = 1) ->
    r = color >> 16 & 0xff
    g = color >> 8 & 0xff
    b = color & 0xff
    alpha = if alpha < 0 then 0 else if alpha > 1 then 1 else alpha
    if alpha is 1
      "rgb(#{r},#{g},#{b})"
    else
      "rgba(#{r},#{g},#{b},#{alpha})"

  @average: (colors...) ->
    rgbs = do -> new RGB color for color in colors
    rgb = RGB.average.apply null, rgbs
    rgb.toHex()
