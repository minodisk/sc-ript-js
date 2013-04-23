#package sc.ript.filter

class KernelFilter extends Filter

  constructor: (radiusX, radiusY, kernel) ->
    super()

    @_radiusX = radiusX
    @_radiusY = radiusY
    @_width = @_radiusX * 2 - 1
    @_height = @_radiusY * 2 - 1
    console.log kernel.length, @_width * @_height
    if kernel.length isnt @_width * @_height
      throw new TypeError 'kernel length isn\'t match with radius'

    @_kernel = kernel

  _evaluatePixel: (pixels, x, y, width, height) ->
    pixel = [0, 0, 0, pixels[y][x][3]]
    @_runKernel pixel, pixels, x, y, width, height
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
        i++

  _getPixel: (pixels, x, y, width, height) ->
    x = if x < 0 then 0 else if x > width - 1 then width - 1 else x
    y = if y < 0 then 0 else if y > height - 1 then height - 1 else y
    pixels[y][x]
  

