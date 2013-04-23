#package sc.ript.filter

class BlurFilter extends KernelFilter

  constructor: (radiusX, radiusY, quality) ->
    side = radiusX * 2 - 1
    length = side * side
    invert = 1 / length
    kernel = []
    kernel.push invert while length--
    super radiusX, radiusY, kernel, quality

