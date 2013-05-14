class sc.ript.filter.BlurFilter extends sc.ript.filter.KernelFilter

  constructor: (radiusX, radiusY, quality) ->
    side = radiusX * 2 - 1
    length = side * side
    invert = 1 / length
    kernel = []
    kernel.push invert while length--
    console.log radiusX, radiusY, kernel
    super radiusX, radiusY, kernel, quality, true

