class sc.ript.filter.Filter

  constructor: (@quality = 1) ->

  run        : (imageData) ->
    {width, height, data} = imageData
    pixels = []
    i = 0
    for y in [0...height] by 1
      pixels[y] = []
      for x in [0...width] by 1
        pixels[y][x] = [data[i], data[i + 1], data[i + 2], data[i + 3]]
        i += 4
    pixels

    q = @quality
    while q--
      i = 0
      for y in [0...height] by 1
        for x in [0...width] by 1
          p = pixels[y][x] = @_evaluatePixel pixels, x, y, width, height
          data[i] = p[0]
          data[i + 1] = p[1]
          data[i + 2] = p[2]
          data[i + 3] = p[3]
          i += 4


  _evaluatePixel: (pixels, x, y, width, height) ->
    pixels[y][x]

  _getPixel: (pixels, x, y, width, height) ->
    x = if x < 0 then 0 else if x > width - 1 then width - 1 else x
    y = if y < 0 then 0 else if y > height - 1 then height - 1 else y
    pixels[y][x]

