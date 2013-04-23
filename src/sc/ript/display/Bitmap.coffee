#package sc.ript.display

class Bitmap extends DisplayObject

  @_PI_2                       : Math.PI * 2
  @_PI_OVER_2                  : Math.PI / 2
  @_ELLIPSE_CUBIC_BEZIER_HANDLE: (Math.SQRT2 - 1) * 4 / 3

  constructor: (width = 320, height = 320, color = 0, alpha = 0) ->
    super()

    if width instanceof Bitmap
      source = width
      width = source.width()
      height = source.height()
    else
      switch width.nodeName
        when 'CANVAS'
          canvas = width
          width = canvas.width
          height = canvas.height
        when 'IMG'
          source = width
          width = source.width
          height = source.height

    width = +width
    height = +height
    if width is 0 or height is 0
      throw new TypeError 'Can\'t construct with 0 size'

    if canvas?
      @canvas = canvas
    else
      @canvas = document.createElement 'canvas'
      @width width
      @height height
    @_context = @canvas.getContext '2d'
    @_context.strokeStyle = 'rgba(0,0,0,0)'
    if alpha isnt 0
      @beginFill color, alpha
      @drawRect 0, 0, width, height
      @endFill()

    if source?
      @draw source

  clone: ->
    bitmap = new Bitmap @width(), @height()
    bitmap.draw @
    bitmap

  width: (value) ->
    return @canvas.width unless value?
    @canvas.width = value

  height: (value) ->
    return @canvas.height unless value?
    @canvas.height = value


  ##############################################################################
  # Binary API
  ##############################################################################

  encodeAsPNG: ->
    ByteArray.fromDataURL @canvas.toDataURL 'image/png'

  encodeAsJPG: (quality = 0.8) ->
    ByteArray.fromDataURL @canvas.toDataURL 'image/jpeg', quality


  ##############################################################################
  # BitmapData API
  ##############################################################################

  clear: ->
    @canvas.width = @canvas.width
    @_context.fillStyle = @_context.strokeStyle = 'rgba(0,0,0,0)'

  draw: (image, matrix) ->
    if image instanceof Bitmap
      if image.blendMode isnt BlendMode.NORMAL
        src = image.getPixels()
        dst = @getPixels()
        dst = Blend.scan image.blendMode, src, dst
      image = image.canvas
    if matrix?
      @_context.setTransform matrix.m11, matrix.m12, matrix.m21, matrix.m22, matrix.tx, matrix.ty
    if dst?
      @_context.putImageData dst, 0, 0
    else
      @_context.drawImage image, 0, 0
    @_context.setTransform 1, 0, 0, 1, 0, 0

  getPixels: (rect) ->
    rect = new Rectangle 0, 0, @width(), @height() unless rect?
    @_context.getImageData rect.x, rect.y, rect.width, rect.height

  setPixels: (imageData) ->
    @_context.putImageData imageData, 0, 0

  getPixel32: (x, y) ->
    {data: [r, g, b, a]} = @_context.getImageData x, y, 1, 1
    a << 24 | r << 16 | g << 8 | b

  getPixel: (x, y) ->
    {data: [r, g, b]} = @_context.getImageData x, y, 1, 1
    r << 16 | g << 8 | b

  filter: (filters...) ->
    imageData = @getPixels()
    for filter in filters
      filter.run imageData
    @setPixels imageData



  ##############################################################################
  # Graphics API
  ##############################################################################

  lineStyle: (thickness = 1, color = 0, alpha = 1, capsStyle = CapsStyle.NONE, jointStyle = JointStyle.BEVEL, miterLimit = 10) ->
    @_context.lineWidth = thickness
    @_context.strokeStyle = Color.toCSSString color, alpha
    @_context.lineCaps = capsStyle
    @_context.lineJoin = jointStyle
    @_context.miterLimit = miterLimit

  beginFill: (color = 0, alpha = 1) ->
    @_context.fillStyle = Color.toCSSString color, alpha

  endFill: ->
    @_context.closePath()
    @_context.fillStyle = 'rgba(0,0,0,0)'

  moveTo: (x, y) ->
    @_context.moveTo x, y

  lineTo: (x, y) ->
    @_context.lineTo x, y

  drawRect: (x, y, width, height) ->
    @_context.beginPath()
    @_context.rect x, y, width, height
    @_context.closePath()
    @_render()
#    r = x + width
#    b = y + height
#    @drawPath [
#      GraphicsPathCommand.MOVE_TO
#      GraphicsPathCommand.LINE_TO
#      GraphicsPathCommand.LINE_TO
#      GraphicsPathCommand.LINE_TO
#      GraphicsPathCommand.LINE_TO
#    ], [
#      x, y
#      r, y
#      r, b
#      x, b
#      x, y
#    ]

  drawCircle: (x, y, radius, clockwise) ->
    @_context.beginPath()
    @_context.moveTo x + radius, y
    @_context.arc x, y, radius, 0, Bitmap._PI_2, clockwise < 0
    @_context.closePath()
    @_render()

  drawEllipse: (x, y, width, height, clockwise = 0) ->
    width /= 2
    height /= 2
    x += width
    y += height
    handleWidth = width * Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE
    handleHeight = height * Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE
    @drawPath [
      GraphicsPathCommand.MOVE_TO
      GraphicsPathCommand.CUBIC_CURVE_TO
      GraphicsPathCommand.CUBIC_CURVE_TO
      GraphicsPathCommand.CUBIC_CURVE_TO
      GraphicsPathCommand.CUBIC_CURVE_TO
    ], [
      x + width, y
      x + width, y + handleHeight, x + handleWidth, y + height, x, y + height
      x - handleWidth, y + height, x - width, y + handleHeight, x - width, y
      x - width, y - handleHeight, x - handleWidth, y - height, x, y - height
      x + handleWidth, y - height, x + width, y - handleHeight, x + width, y
    ], clockwise

  curveTo: (x1, y1, x2, y2) ->
    @_context.quadraticCurveTo x1, y1, x2, y2

  cubicCurveTo: (x1, y1, x2, y2, x3, y3) ->
    @_context.bezierCurveTo x1, y1, x2, y2, x3, y3

  drawPath: (commands, data, clockwise = 0) ->
#    rect = new Rectangle data[0], data[1], 0, 0
#    for i in [1...data.length / 2] by 1
#      j = i * 2
#      rect.contain data[j], data[j + 1]

#    if clockwise < 0
#      d = []
#      i = 0
#      for command in commands
#        switch command
#          when 0, 1 then d.unshift data[i++], data[i++]
#          when 2
#            i += 4
#            d.unshift data[i - 2], data[i - 1], data[i - 4], data[i - 3]
#          when 3
#            i += 6
#            d.unshift data[i - 2], data[i - 1], data[i - 4], data[i - 3], data[i - 6], data[i - 5]
#      data = d
#
#      commands = commands.slice()
#      c = commands.shift()
#      commands.reverse()
#      commands.unshift c
    @_context.beginPath()
    i = 0
    for command in commands
      switch command
        when GraphicsPathCommand.MOVE_TO
          @_context.moveTo data[i++], data[i++]
        when GraphicsPathCommand.LINE_TO
          @_context.lineTo data[i++], data[i++]
        when GraphicsPathCommand.CURVE_TO
          @_context.quadraticCurveTo data[i++], data[i++], data[i++], data[i++]
        when GraphicsPathCommand.CUBIC_CURVE_TO
          @_context.bezierCurveTo data[i++], data[i++], data[i++], data[i++], data[i++], data[i++]
    # Close path when start and end is equal
    #    if data[0] is data[data.length - 2] and data[1] is data[data.length - 1]

    @_context.closePath()
    @_render()

  drawRoundRect: (x, y, width, height, ellipseW, ellipseH = ellipseW, clockwise = 0) ->
    @drawPath [0, 1, 2, 1, 2, 1, 2, 1, 2], [
      x + ellipseW, y
      x + width - ellipseW, y
      x + width, y, x + width, y + ellipseH
      x + width, y + height - ellipseH
      x + width, y + height, x + width - ellipseW, y + height
      x + ellipseW, y + height
      x, y + height, x, y + height - ellipseH
      x, y + ellipseH
      x, y, x + ellipseW, y
    ], clockwise

  drawRegularPolygon: (x, y, radius, length = 3, clockwise = 0) ->
    commands = []
    data = []
    unitRotation = Bitmap._PI_2 / length
    for i in [0..length]
      commands.push if i is 0 then 0 else 1
      rotation = -Bitmap._PI_OVER_2 + unitRotation * i
      data.push x + radius * Math.cos(rotation), y + radius * Math.sin(rotation)
    @drawPath commands, data, clockwise

  drawRegularStar: (x, y, outer, length = 5, clockwise = 0) ->
    cos = Math.cos Math.PI / length
    @drawStar x, y, outer, outer * (2 * cos - 1 / cos), length, clockwise

  drawStar: (x, y, outer, inner, length = 5, clockwise = 0) ->
    commands = []
    data = []
    unitRotation = Math.PI / length
    for i in [0..length * 2] by 1
      commands.push if i is 0 then 0 else 1
      radius = if (i & 1) is 0 then outer else inner
      rotation = -Bitmap._PI_OVER_2 + unitRotation * i
      data.push x + radius * Math.cos(rotation), y + radius * Math.sin(rotation)
    @drawPath commands, data, clockwise

  drawLine: (points) ->
    commands = []
    data = []
    for point in points
      commands.push GraphicsPathCommand.LINE_TO
      data.push point.x, point.y
    @drawPath commands, data

  drawSpline: (points, interpolation = 50) ->
    commands = []
    data = []

    closed = points[0].equals points[points.length - 1]
    pointsLength = points.length
    jLen = if closed then pointsLength else pointsLength - 1
    iLen = interpolation
    for j in [0...jLen] by 1
      p0 = points[@_normalizeIndex(j - 1, pointsLength, closed)]
      p1 = points[@_normalizeIndex(j, pointsLength, closed)]
      p2 = points[@_normalizeIndex(j + 1, pointsLength, closed)]
      p3 = points[@_normalizeIndex(j + 2, pointsLength, closed)]
      if j is jLen - 1
        iLen = if closed then 1 else interpolation + 1
      for i in [0...iLen] by 1
        commands.push GraphicsPathCommand.LINE_TO
        data.push(
          @_interpolateSpline(p0.x, p1.x, p2.x, p3.x, i / interpolation),
          @_interpolateSpline(p0.y, p1.y, p2.y, p3.y, i / interpolation)
        )
    commands[0] = GraphicsPathCommand.MOVE_TO

    @drawPath commands, data

  _normalizeIndex: (index, pointsLength, closed) ->
    unless closed
      if index < 0 then 0 else if index >= pointsLength then pointsLength - 1 else index
    else
      if index < 0 then pointsLength - 1 + index else if index >= pointsLength then 1 + (index - pointsLength) else index

  _interpolateSpline: (p0, p1, p2, p3, t) ->
    t2 = t * t
    t3 = t2 * t
    0.5 * (-p0 + 3 * p1 - 3 * p2 + p3) * t3 +
    0.5 * (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
    0.5 * (-p0 + p2) * t +
    p1

  _render: ->
    @_context.fill()
    @_context.stroke()








