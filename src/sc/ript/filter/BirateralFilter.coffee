#package sc.ript.filter

class BirateralFilter extends KernelFilter

  constructor: (radiusX, radiusY, kernel) ->
    super radiusX, radiusY, kernel

