#package sc.ript.filter

class BilateralFilter extends KernelFilter

  @_SIGMA_8BIT: 2.04045

  constructor: (radiusX = 2, radiusY = 2, threshold = 0x20) ->
    # generate kernel
    kernel = []
    gaussSpaceCoeff = -0.5 / ((radiusX / BilateralFilter._SIGMA_8BIT) * (radiusY / BilateralFilter._SIGMA_8BIT))
    for relY in [1 - radiusY...radiusY] by 1
      for relX in [1 - radiusX...radiusX] by 1
        kernel.push Math.exp((relX * relX + relY * relY) * gaussSpaceCoeff)

    # call super constructor
    super radiusX, radiusY, kernel

    sigmaColor = threshold / 0xff * Math.sqrt(0xff * 0xff * 3) / BilateralFilter._SIGMA_8BIT
    @_gaussColorCoeff = -0.5 / (sigmaColor * sigmaColor)

  _runKernel: (pixel, pixels, x, y, width, height) ->
    center = @_getPixel pixels, x, y, width, height
    totalWeight = 0

    i = 0
    for relY in [1 - @_radiusY...@_radiusY] by 1
      absY = y + relY
      for relX in [1 - @_radiusX...@_radiusX] by 1
        absX = x + relX
        p = @_getPixel pixels, absX, absY, width, height
        dr = p[0] - center[0]
        dg = p[1] - center[1]
        db = p[2] - center[2]
        weight = @_kernel[i] * Math.exp((dr * dr + dg * dg + db * db) * @_gaussColorCoeff)
        totalWeight += weight
        pixel[0] += p[0] * weight
        pixel[1] += p[1] * weight
        pixel[2] += p[2] * weight
        i++

    pixel[0] /= totalWeight
    pixel[1] /= totalWeight
    pixel[2] /= totalWeight

