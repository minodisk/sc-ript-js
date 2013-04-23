#package sc.ript.display

class Bitmap

  @_PI_2                       : Math.PI * 2
  @_PI_OVER_2                  : Math.PI / 2
  @_ELLIPSE_CUBIC_BEZIER_HANDLE: (Math.SQRT2 - 1) * 4 / 3

  constructor: (canvas) ->
    @_canvas = canvas
    @_context = @_canvas.getContext '2d'
    @_context.fillStyle = @_context.strokeStyle = 'rgba(0,0,0,0)'
    console.log 'lineStyle:', @_context.strokeStyle
    console.log 'fillStyle:', @_context.fillStyle

  width: (value) ->
    return @_canvas.width unless value?
    @_canvas.width = value

  height: (value) ->
    return @_canvas.height unless value?
    @_canvas.height = value

  clear: ->
    @_canvas.width = @_canvas.width
    @_context.fillStyle = @_context.strokeStyle = 'rgba(0,0,0,0)'

  draw: (image, matrix) ->
    if matrix?
      @_context.setTransform matrix.m11, matrix.m12, matrix.m21, matrix.m22, matrix.tx, matrix.ty
    @_context.drawImage image, 0, 0

  encodeAsPNG: ->
    ByteArray.fromDataURL @_canvas.toDataURL 'image/png'

  encodeAsJPG: (quality = 0.8) ->
    ByteArray.fromDataURL @_canvas.toDataURL 'image/jpeg', quality


  # Graphics API

  lineStyle: (thickness = 1, color = 0, alpha = 1, capsStyle = CapsStyle.NONE, jointStyle = JointStyle.BEVEL, miterLimit = 10) ->
    @_context.lineWidth = thickness
    @_context.strokeStyle = ColorUtil.toCSSString color, alpha
    @_context.lineCaps = capsStyle
    @_context.lineJoin = jointStyle
    @_context.miterLimit = miterLimit

    console.log 'lineStyle:', @_context.strokeStyle

  beginFill: (color = 0, alpha = 1) ->
    @_context.fillStyle = ColorUtil.toCSSString color, alpha

    console.log 'fillStyle:', @_context.fillStyle

  moveTo: (x, y) ->
    @_context.moveTo x, y

  lineTo: (x, y) ->
    @_context.lineTo x, y

  drawRect: (x, y, width, height) ->
    @_context.rect x, y, width, height

  drawCircle: (x, y, radius, clockwise) ->
    @_context.moveTo x + radius, y
    @_context.arc x, y, radius, 0, Bitmap._PI_2, clockwise < 0

  drawEllipse: (x, y, width, height, clockwise = 0) ->
    width /= 2
    height /= 2
    x += width
    y += height
    handleWidth = width * Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE
    handleHeight = height * Bitmap._ELLIPSE_CUBIC_BEZIER_HANDLE
    @drawPath [0, 3, 3, 3, 3], [
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
    rect = new Rectangle data[0], data[1], 0, 0
    for i in [1...data.length / 2] by 1
      j = i * 2
      rect.contain data[j], data[j + 1]

    if clockwise < 0
      d = []
      i = 0
      for command in commands
        switch command
          when 0, 1 then d.unshift data[i++], data[i++]
          when 2
            i += 4
            d.unshift data[i - 2], data[i - 1], data[i - 4], data[i - 3]
          when 3
            i += 6
            d.unshift data[i - 2], data[i - 1], data[i - 4], data[i - 3], data[i - 6], data[i - 5]
      data = d

      commands = commands.slice()
      c = commands.shift()
      commands.reverse()
      commands.unshift c

    i = 0
    for command in commands
      switch command
        when GraphicsPathCommand.MOVE_TO
          @_context.moveTo data[i++], data[i++]
          console.log 'moveTo:', data[i-2],data[i-1]
        when GraphicsPathCommand.LINE_TO
          @_context.lineTo data[i++], data[i++]
          console.log 'lineTo:', data[i-2],data[i-1]
        when GraphicsPathCommand.CURVE_TO
          @_context.quadraticCurveTo data[i++], data[i++], data[i++], data[i++]
        when GraphicsPathCommand.CUBIC_CURVE_TO
          @_context.bezierCurveTo data[i++], data[i++], data[i++], data[i++], data[i++], data[i++]

    # Close path when start and end is equal
    if data[0] is data[data.length - 2] and data[1] is data[data.length - 1]
      @_context.closePath()

    @_context.fill()
    @_context.stroke()

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







