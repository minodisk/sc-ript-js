class KernelFilter extends sc.ript.filter.Filter

  constructor: (radiusX, radiusY, kernel, quality, applyAlpha) ->
    super quality

    @_radiusX = radiusX
    @_radiusY = radiusY
    @_width = @_radiusX * 2 - 1
    @_height = @_radiusY * 2 - 1
    if kernel.length isnt @_width * @_height
      throw new TypeError 'kernel length isn\'t match with radius'

    @_applyAlpha = applyAlpha
    @_kernel = kernel

  _evaluatePixel: (pixels, x, y, width, height) ->
    pixel = [0, 0, 0, 0]
    @_runKernel pixel, pixels, x, y, width, height
    unless @_applyAlpha
      pixel[3] = pixels[y][x][3]
    pixel

  _runKernel: (pixel, pixels, x, y, width, height) ->
    i = 0
    for relY in [1 - @_radiusY...@_radiusY] by 1
      absY = y + relY
      for relX in [1 - @_radiusX...@_radiusX] by 1
        absX = x + relX
        p = @_getPixel pixels, absX, absY, width, height
        amount = @_kernel[i]
        pixel[0] += p[0] * amount
        pixel[1] += p[1] * amount
        pixel[2] += p[2] * amount
        pixel[3] += p[3] * amount
        i++
  

