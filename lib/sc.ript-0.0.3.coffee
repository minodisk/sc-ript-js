sc = {
  "ript": {
    "color": {},
    "deferred": {},
    "display": {},
    "event": {},
    "filter": {},
    "geom": {},
    "serializer": {},
    "util": {}
  }
}
if window? then window.sc = sc
if module? then module.exports = sc

class sc.ript.color.Color

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


class sc.ript.color.HSV

  constructor: (@h, @s, @v) ->
    if arguments.length is 1
      hex = h
      rgb = new RGB hex
      r = rgb.r / 255
      g = rgb.g / 255
      b = rgb.b / 255

      h = s = v = 0
      if r >= g then x = r else x = g
      if b > x then x = b
      if r <= g then y = r else y = g
      if b < y then y = b
      v = x
      c = x - y
      if x is 0
        s = 0
      else
        s = c / x
      if s isnt 0
        if r is x
          h = (g - b) / c
        else
          if g is x
            h = 2 + (b - r) / c
          else
            if b is x
              h = 4 + (r - g) / c
        h = h * 60
        if h < 0
          h = h + 360
      @h = h
      @s = s
      @v = v
    @normalize()

  normalize: ->
    @s = if @s < 0 then 0 else if @s > 1 then 1 else @s
    @v = if @v < 0 then 0 else if @v > 1 then 1 else @v
    @h = @h % 360
    @h += 360 if @h < 0

  toRGB: ->
    @normalize()
    {h, s, v} = @
    h /= 60
    i = h >> 0
    x = v * (1 - s)
    y = v * (1 - s * (h - 1))
    z = v * (1 - s * (1 - h + i))
    x = x * 0xff >> 0
    y = y * 0xff >> 0
    z = z * 0xff >> 0
    v = v * 0xff >> 0
    switch i
      when 0 then new RGB v, z, x
      when 1 then new RGB y, v, x
      when 2 then new RGB x, v, z
      when 3 then new RGB x, y, v
      when 4 then new RGB z, x, v
      when 5 then new RGB v, x, y

  toHex: ->
    @toRGB().toHex()




class sc.ript.color.RGB

  @average: (rgbs...) ->
    r = g = b = 0
    for rgb in rgbs
      r += rgb.r
      g += rgb.g
      b += rgb.b
    length = rgbs.length
    r /= length
    g /= length
    b /= length
    new RGB r, g, b


  constructor: (@r, @g, @b) ->
    if arguments.length is 1
      hex = r
      @r = hex >> 16 & 0xff
      @g = hex >> 8 & 0xff
      @b = hex & 0xff
    @normalize()

  normalize: ->
    @r &= 0xff
    @g &= 0xff
    @b &= 0xff

  toHex: ->
    @r << 16 | @g << 8 | @b



class sc.ript.deferred.DLoader

  @loadData: (url, method = 'get', data = '') ->
    d = new Deferred

    if window.ActiveXObject?
      try
        xhr = new ActiveXObject 'Msxml2.XMLHTTP'
      catch err
        try
          xhr = new ActiveXObject 'Microsoft.XMLHTTP'
        catch err
          throw new TypeError 'doesn\'t support XMLHttpRequest'
    else if window.XMLHttpRequest
      xhr = new XMLHttpRequest
    else
      throw new TypeError 'doesn\'t support XMLHttpRequest'

    xhr.onerror = (err) ->
      d.fail err
    xhr.onreadystatechange = ->
      unless xhr.readyState is 4
        # progress
        return
      d.call xhr.responseText
    xhr.open method, url, true
    xhr.send data

    d

  @loadImage: (url) ->
    d = new Deferred
    image = new Image
    image.onerror = (err) ->
      d.fail err
    image.onload = ->
      d.call image
    image.src = url
    d

  @loadFile: (file) ->
    d = new Deferred
    reader = new FileReader
    reader.onerror = (err) ->
      d.fail err
    reader.onload = ->
      d.call reader.result
    reader.readAsDataURL file
    d



class sc.ript.display.Blend

  @_mix: (a, b, f) ->
    a + (((b - a) * f) >> 8)

  @_peg: (n) ->
    if n < 0 then 0 else if n > 255 then 255 else n

  @scan: (method, src, dst) ->
    method = Blend[method]
    throw new TypeError "#{ method } isn't defined." unless method?
    s = src.data
    d = dst.data
    for i in [0...d.length] by 4
      o = method d[i], d[i + 1], d[i + 2], d[i + 3], s[i], s[i + 1], s[i + 2], s[i + 3]
      d[i..i + 3] = o[0..3]
    dst

  @blend: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, sr, sa
      Blend._mix dg, sg, sa
      Blend._mix db, sb, sa
      da + sa
    ]

  @add: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      dr + (sr * sa >> 8)
      dg + (sg * sa >> 8)
      db + (sb * sa >> 8)
      da + sa
    ]

  @subtract: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      dr - (sr * sa >> 8)
      dg - (sg * sa >> 8)
      db - (sb * sa >> 8)
      da + sa
    ]

  @darkest: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Math.min(dr, sr * sa >> 8), sa
      Blend._mix dg, Math.min(dg, sg * sa >> 8), sa
      Blend._mix db, Math.min(db, sb * sa >> 8), sa
      da + sa
    ]

  @lightest: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Math.max dr, sr * sa >> 8
      Math.max dg, sg * sa >> 8
      Math.max db, sb * sa >> 8
      da + sa
    ]

  @difference: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if dr > sr then dr - sr else sr - dr), sa
      Blend._mix dg, (if dg > sg then dg - sg else sg - dg), sa
      Blend._mix db, (if db > sb then db - sb else sb - db), sa
      da + sa
    ]

  @exclusion: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, dr + sr - (dr * sr >> 7), sa
      Blend._mix dg, dg + sg - (dg * sg >> 7), sa
      Blend._mix db, db + sb - (db * sb >> 7), sa
      da + sa
    ]

  @reflex: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if sr is 0xff then sr else dr * dr / (0xff - sr)), sa
      Blend._mix dg, (if sg is 0xff then sg else dg * dg / (0xff - sg)), sa
      Blend._mix db, (if sb is 0xff then sb else db * db / (0xff - sb)), sa
      da + sa
    ]

  @multiply: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, dr * sr >> 8, sa
      Blend._mix dg, dg * sg >> 8, sa
      Blend._mix db, db * sb >> 8, sa
      da + sa
    ]

  @screen: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, 0xff - ((0xff - dr) * (0xff - sr) >> 8), sa
      Blend._mix dg, 0xff - ((0xff - dg) * (0xff - sg) >> 8), sa
      Blend._mix db, 0xff - ((0xff - db) * (0xff - sb) >> 8), sa
      da + sa
    ]

  @overlay: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if dr < 0x80 then dr * sr >> 7 else 0xff - ((0xff - dr) * (0xff - sr) >> 7)), sa
      Blend._mix dg, (if dg < 0x80 then dg * sg >> 7 else 0xff - ((0xff - dg) * (0xff - sg) >> 7)), sa
      Blend._mix db, (if db < 0x80 then db * sb >> 7 else 0xff - ((0xff - db) * (0xff - sb) >> 7)), sa
      da + sa
    ]

  @softLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (dr * sr >> 7) + (dr * dr >> 8) - (dr * dr * sr >> 15), sa
      Blend._mix dg, (dg * sg >> 7) + (dg * dg >> 8) - (dg * dg * sg >> 15), sa
      Blend._mix db, (db * sb >> 7) + (db * db >> 8) - (db * db * sb >> 15), sa
      da + sa
    ]

  @hardLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if sr < 0x80 then dr * sr >> 7 else 0xff - (((0xff - dr) * (0xff - sr)) >> 7)), sa
      Blend._mix dg, (if sg < 0x80 then dg * sg >> 7 else 0xff - (((0xff - dg) * (0xff - sg)) >> 7)), sa
      Blend._mix db, (if sb < 0x80 then db * sb >> 7 else 0xff - (((0xff - db) * (0xff - sb)) >> 7)), sa
      da + sa
    ]

  @vividLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      (
        if sr is 0 then 0
        else if sr is 0xff then 0xff
        else if sr < 0x80 then 0xff - Blend._peg(((0xff - dr) << 8) / (sr * 2))
        else Blend._peg((dr << 8) / ((0xff - sr) * 2))
      ),
      (
        if sg is 0 then 0
        else if sg is 0xff then 0xff
        else if sg < 0x80 then 0xff - Blend._peg(((0xff - dg) << 8) / (sg * 2))
        else Blend._peg((dg << 8) / ((0xff - sg) * 2))
      ),
      (
        if sb is 0 then 0
        else if sb is 0xff then 0xff
        else if sb < 0x80 then 0xff - Blend._peg(((0xff - db) << 8) / (sb * 2))
        else Blend._peg((db << 8) / ((0xff - sb) * 2))
      ),
      da + sa
    ]

  @linearLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      (
        if sr < 0x80 then Math.max(sr * 2 + dr - 0xff, 0)
        else Math.min(sr + dr, 0xff)
      ),
      (
        if sg < 0x80 then Math.max(sg * 2 + dg - 0xff, 0)
        else Math.min(sg + dg, 0xff)
      ),
      (
        if sb < 0x80 then Math.max(sb * 2 + db - 0xff, 0)
        else Math.min(sb + db, 0xff)
      ),
      da + sa
    ]

  @pinLight: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      (
        if sr < 0x80 then Math.min sr * 2, dr
        else Math.max (sr - 0x80) * 2, dr
      ),
      (
        if sg < 0x80 then Math.min sg * 2, dg
        else Math.max (sg - 0x80) * 2, dg
      ),
      (
        if sb < 0x80 then Math.min sb * 2, db
        else Math.max (sb - 0x80) * 2, db
      ),
      da + sa
    ]

  @hardMix: (dr, dg, db, da, sr, sg, sb, sa) ->
    r = (
      if sr is 0 then 0
      else if sr is 0xff then 0xff
      else if sr < 0x80 then 0xff - Blend._peg(((0xff - dr) << 8) / (sr * 2))
      else Blend._peg((dr << 8) / ((0xff - sr) * 2))
    )
    g = (
      if sg is 0 then 0
      else if sg is 0xff then 0xff
      else if sg < 0x80 then 0xff - Blend._peg(((0xff - dg) << 8) / (sg * 2))
      else Blend._peg((dg << 8) / ((0xff - sg) * 2))
    )
    b = (
      if sb is 0 then 0
      else if sb is 0xff then 0xff
      else if sb < 0x80 then 0xff - Blend._peg(((0xff - db) << 8) / (sb * 2))
      else Blend._peg((db << 8) / ((0xff - sb) * 2))
    )
    [
      if r < 0x80 then 0 else 0xff,
      if g < 0x80 then 0 else 0xff,
      if b < 0x80 then 0 else 0xff,
      da + sa
    ]

  @dodge: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Blend._peg((dr << 8) / (0xff - sr)), sa
      Blend._mix dg, Blend._peg((dg << 8) / (0xff - sg)), sa
      Blend._mix db, Blend._peg((db << 8) / (0xff - sb)), sa
      da + sa
    ]

  @burn: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, (if sr is 0 then 0 else 0xff - Blend._peg(((0xff - dr) << 8) / sr)), sa
      Blend._mix dg, (if sg is 0 then 0 else 0xff - Blend._peg(((0xff - dg) << 8) / sg)), sa
      Blend._mix db, (if sb is 0 then 0 else 0xff - Blend._peg(((0xff - db) << 8) / sb)), sa
      da + sa
    ]

  @linearDodge: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Math.min(sr + dr, 0xff), sa
      Blend._mix dg, Math.min(dg + sg, 0xff), sa
      Blend._mix db, Math.min(db + sb, 0xff), sa
      da + sa
    ]

  @linearBurn: (dr, dg, db, da, sr, sg, sb, sa) ->
    [
      Blend._mix dr, Math.max(sr + dr - 0xff, 0), sa
      Blend._mix dg, Math.max(dg + sg - 0xff, 0), sa
      Blend._mix db, Math.max(db + sb - 0xff, 0), sa
      da + sa
    ]

  @punch: #do ->
#    if /Android/.test navigator.userAgent
#      (dr, dg, db, da, sr, sg, sb, sa) ->
#        [
#          dr
#          dg
#          db
#          if (da * Blend._peg(0xff - sa) / 0xff >> 0) > 0xf0 then 0xff else 0
#        ]
#    else
      (dr, dg, db, da, sr, sg, sb, sa) ->
        [
          dr
          dg
          db
          da * Blend._peg(0xff - sa) / 0xff >> 0
        ]

  @mask: #do ->
#    if /Android/.test navigator.userAgent
#      (dr, dg, db, da, sr, sg, sb, sa) ->
#        [
#          dr
#          dg
#          db
#          if da * sa / 0xff  > 0xf0 then 0xff else 0
#        ]
#    else
      (dr, dg, db, da, sr, sg, sb, sa) ->
        [
          dr
          dg
          db
          da * sa / 0xff >> 0
        ]




class sc.ript.display.BlendMode

  @NORMAL: 'normal'
  @BLEND: 'blend'
  @ADD: 'add'
  @SUBTRACT: 'subtract'
  @DARKEST: 'darkest'
  @LIGHTEST: 'lightest'
  @DIFFERENCE: 'difference'
  @EXCLUSION: 'exclusion'
  @MULTIPLY: 'multiply'
  @SCREEN: 'screen'

  @OVERLAY: 'overlay'
  @SOFT_LIGHT: 'softLight'
  @HARD_LIGHT: 'hardLight'
  @VIVID_LIGHT: 'vividLight'
  @LINEAR_LIGHT: 'linearLight'
  @PIN_LIGHT: 'pinLight'
  @HARD_MIX: 'hardMix'

  @DODGE: 'dodge'
  @BURN: 'burn'
  @LINEAR_DODGE: 'linearDodge'
  @LINEAR_BURN: 'linearBurn'

  @PUNCH: 'punch'
  @MASK: 'mask'


class sc.ript.display.CapsStyle

  @NONE  : 'butt'
  @BUTT  : 'butt'
  @ROUND : 'round'
  @SQUARE: 'square'

class sc.ript.display.DisplayObject

  @_RADIAN_PER_DEGREE: Math.PI / 180

  constructor: ->
    @x = @y = @rotation = 0
    @scaleX = @scaleY = 1
    @blendMode = BlendMode.NORMAL

  matrix: ->
    new Matrix()
      .scale(@scaleX, @scaleY)
      .rotate(@rotation * DisplayObject._RADIAN_PER_DEGREE)
      .translate(@x, @y)




class sc.ript.display.Bitmap extends sc.ript.display.DisplayObject

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
    ByteArray.fromDataURL @encodeAsBase64PNG()

  encodeAsJPG: (quality = 0.8) ->
    ByteArray.fromDataURL @encodeAsBase64JPG quality

  encodeAsBase64PNG: (onlyData = false) ->
    data = @canvas.toDataURL 'image/png'
    if onlyData
      data.split(',')[1]
    else
      data

  encodeAsBase64JPG: (quality = 0.8, onlyData = false) ->
    data = @canvas.toDataURL 'image/jpeg', quality
    if onlyData
      data.split(',')[1]
    else
      data

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

  drawSpline: (points, interpolation = 10) ->
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










class sc.ript.display.GraphicsPathCommand

  @NO_OP         : 0
  @MOVE_TO       : 1
  @LINE_TO       : 2
  @CURVE_TO      : 3
  @WIDE_MOVE_TO  : 4
  @WIDE_LINE_TO  : 5
  @CUBIC_CURVE_TO: 6


class sc.ript.display.JointStyle

  @BEVEL: 'bevel'
  @MITER: 'miter'
  @ROUND: 'round'

class sc.ript.event.Event

  constructor: (@type, @data) ->


class sc.ript.event.EventEmitter

  constructor: ->
    @_receivers = {}

  on: (type, listener, useCapture = false, priority = 0) ->
    if typeof listener isnt 'function'
      throw new TypeError 'listener is\'t Function'

    # typeに対応するレシーバのリストが存在するかをチェック
    unless @_receivers[type]?
      @_receivers[type] = []

    receivers = @_receivers[type]

    # リスナが格納済みではないかをチェック
    i = receivers.length
    while i--
      receiver = reveicers[i]
      if receiver.listener is listener
        return @

    # リスナを格納し優先度順にソート
    receivers.push
      listener  : listener
      useCapture: useCapture
      priority  : priority
    receivers.sort (a, b) ->
      b.priority - a.priority

    @

  off: (type, listener) ->
    receivers = @_receivers[type]

    # typeに対応するレシーバが登録されているかをチェック
    unless receivers
      return @

    # 格納されていればリストから取り除く
    i = receivers.length
    while i--
      if receivers[i].listener is listener
        receivers.splice i, 1
      if receivers.length is 0
        delete @_receivers[type]

    @

  emit: (event) ->
    receivers = @_receivers[event.type]

    # typeに対応するレシーバが登録されているかをチェック
    unless receivers?
      return @

    event.currentTarget = @

    # 全てのレシーバのリスナをイベントオブジェクトを引数としてコールする
    # リスナはEventEmitterオブジェクトで束縛される
    for receiver in receivers
      do (receiver) =>
        setTimeout =>
          if event._isPropagationStoppedImmediately
            return
          receiver.listener.call @, event
        , 0

    @

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



# |R|   |m0  m1  m2  m3 ||r|   |m4 |
# |G| = |m5  m6  m7  m8 ||g| + |m9 |
# |B|   |m10 m11 m12 m13||b|   |m14|
# |A|   |m15 m16 m17 m18||a|   |m19|
class sc.ript.filter.ColorMatrixFilter extends sc.ript.filter.Filter

  constructor: (@matrix) ->
    super()

  _evaluatePixel: (pixels, x, y, width, height) ->
    m = @matrix
    [r, g, b, a] = pixels[y][x]
    [
      r * m[0] + g * m[1] + b * m[2] + a * m[3] + m[4]
      r * m[5] + g * m[6] + b * m[7] + a * m[8] + m[9]
      r * m[10] + g * m[11] + b * m[12] + a * m[13] + m[14]
      r * m[15] + g * m[16] + b * m[17] + a * m[18] + m[19]
    ]



class sc.ript.filter.KernelFilter extends sc.ript.filter.Filter

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
  



class sc.ript.filter.BilateralFilter extends sc.ript.filter.KernelFilter

  @_SIGMA_8BIT: 2.04045

  constructor: (radiusX = 2, radiusY = 2, threshold = 0x20) ->
    # generate kernel
    kernel = []
    gaussSpaceCoeff = -0.5 / ((radiusX / BilateralFilter._SIGMA_8BIT) * (radiusY / BilateralFilter._SIGMA_8BIT))
    for relY in [1 - radiusY...radiusY] by 1
      for relX in [1 - radiusX...radiusX] by 1
        kernel.push Math.exp((relX * relX + relY * relY) * gaussSpaceCoeff)

    # call super constructor
    super radiusX, radiusY, kernel, 1, false

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



class sc.ript.filter.BlurFilter extends sc.ript.filter.KernelFilter

  constructor: (radiusX, radiusY, quality) ->
    side = radiusX * 2 - 1
    length = side * side
    invert = 1 / length
    kernel = []
    kernel.push invert while length--
    console.log radiusX, radiusY, kernel
    super radiusX, radiusY, kernel, quality, true



class sc.ript.filter.GaussianBlurFilter extends sc.ript.filter.KernelFilter

  constructor: (radiusX, radiusY, sigma = 0.84089642) ->
    s = 2 * sigma * sigma
    weight = 0
    kernel = []
    for dy in [1 - radiusY...radiusY] by 1
      for dx in [1 - radiusX...radiusX] by 1
        w = 1 / (s * Math.PI) * Math.exp(-(dx * dx + dy * dy) / s)
        weight += w
        kernel.push w
    kernel[i] /= weight for i in [0...kernel.length] by 1
    super radiusX, radiusY, kernel, 1, true

class sc.ript.filter.ThresholdFilter extends sc.ript.filter.Filter

  # @param operation "<", "<=", ">", ">=", "==", "!="
  constructor: (@threshold, @operation) ->
    super()

  _evaluatePixel: (pixels, x, y, width, height) ->
    [r, g, b, a] = pixels[y][x]
    color = a << 24 | r << 16 | g << 8 | b
    switch @operation
      when "<"
        color = if color < @threshold then color else 0
      when "<="
        color = if color <= @threshold then color else 0
      when ">"
        color = if color > @threshold then color else 0
      when ">="
        color = if color >= @threshold then color else 0
      when "=="
        color = if color == @threshold then color else 0
      when "!="
        color = if color != @threshold then color else 0
    [color >> 16 & 0xff, color >> 8 & 0xff, color & 0xff, color >> 24 & 0xff]





class sc.ript.geom.Matrix

  constructor: (@m11 = 1, @m12 = 0, @m21 = 0, @m22 = 1, @tx = 0, @ty = 0) ->

  translate  : (x = 0, y = 0) ->
    @concat new Matrix 1, 0, 0, 1, x, y
    @

  scale: (x = 1, y = 1) ->
    @concat new Matrix x, 0, 0, y, 0, 0
    @

  rotate: (theta) ->
    s = Math.sin theta
    c = Math.cos theta
    @concat new Matrix c, s, -s, c, 0, 0
    @

  concat: (matrix) ->
    { m11, m12, m21, m22, tx, ty } = @
    @m11 = m11 * matrix.m11 + m12 * matrix.m21
    @m12 = m11 * matrix.m12 + m12 * matrix.m22
    @m21 = m21 * matrix.m11 + m22 * matrix.m21
    @m22 = m21 * matrix.m12 + m22 * matrix.m22
    @tx = tx * matrix.m11 + ty * matrix.m21 + matrix.tx
    @ty = tx * matrix.m12 + ty * matrix.m22 + matrix.ty
    @

  invert: ->
    { m11, m12, m21, m22, tx, ty } = @
    d = m11 * m22 - m12 * m21
    @m11 = m22 / d
    @m12 = -m12 / d
    @m21 = -m21 / d
    @m22 = m11 / d
    @m41 = (m21 * ty - m22 * tx) / d
    @m42 = (m12 * tx - m11 * ty) / d
    @


class sc.ript.geom.Point

  @equals: (pt0, pt1) ->
    pt0.equals pt1

  @dotProduct: (pt0, pt1) ->
    pt0.x * pt1.x + pt0.y * pt1.y

  @angle: (pt0, pt1) ->
    pt1.subtract(pt0).angle()

  @distance: (pt0, pt1) ->
    pt1.subtract(pt0).length()

  @interpolate: (pt0, pt1, ratio) ->
    pt0.add pt1.subtract(pt0).multiply(ratio)
    
  @inflate: (src, dst, pixel) ->
    dx = src.x - dst.x
    dy = src.y - dst.y
    d = Math.sqrt dx * dx + dy * dy
    ratio = 1 + pixel / d
    @interpolate src, dst, ratio


  constructor: (x = 0, y = 0) ->
    @x = +x
    @y = +y

  angle      : (value) ->
    return Math.atan2 @y, @x unless value?

    length = @length()
    @x = length * Math.cos value
    @y = length * Math.sin value

  length: (value) ->
    return Math.sqrt @x * @x + @y * @y unless value?

    angle = @angle()
    @x = value * Math.cos angle
    @y = value * Math.sin angle

  clone: ->
    new Point @x, @y

  equals: (pt) ->
    @x is pt.x and @y is pt.y

  add: (pt) ->
    new Point @x + pt.x, @y + pt.y

  subtract: (pt) ->
    new Point @x - pt.x, @y - pt.y

  multiply: (value) ->
    new Point @x * value, @y * value

  divide: (value) ->
    new Point @x / value, @y / value



class sc.ript.geom.Rectangle

  # ## new Rectangle(x:*Number* = 0, y:*Number* = 0, width:*Number* = 0, height:*Number* = 0)
  # Creates a new *Rectangle* instance.
  constructor: (@x = 0, @y = 0, @width = 0, @height = 0) ->

  # ## toString():*String*
  # Creates *String* composed of x, y, width and height.
  toString: ->
    "[Rectangle x=#{@x} y=#{@y} width=#{@width} height=#{@height}]"

  # ## clone():*Rectangle*
  # Clones this object.
  clone: ->
    new Rectangle @x, @y, @width, @height

  # ## apply(rect:*Rectangle*):*Rectangle*
  # Applies target properties to this object.
  apply: (rect) ->
    @x = rect.x
    @y = rect.y
    @width = rect.width
    @height = rect.height
    @

  contains: (x, y) ->
    @x < x < @x + @width and @y < y < @y + @height

  containsPoint: (point) ->
    @x < point.x < @x + @width and @y < point.y < @y + @height

  contain: (x, y) ->
    if x < @x
      @width += @x - x
      @x = x
    else if x > @x + @width
      @width = x - @x
    if y < @y
      @height += @y - y
      @y = y
    else if y > @y + @height
      @height = y - @y
    @

  # ## offset(dx:*Number*, dy:*Number*):*Rectangle*
  # Add x and y to this object.
  offset: (dx, dy) ->
    @x += dx
    @y += dy
    @

  # ## offsetPoint(pt:*Point*):*Rectangle*
  # Add x and y to this object using a *Point* object as a parameter.
  offsetPoint: (pt) ->
    @x += pt.x
    @y += pt.y
    @

  inflate: (dw, dh) ->
    @width += dw
    @height += dh
    @

  inflatePoint: (pt) ->
    @width += pt.x
    @height += pt.y
    @

  deflate: (dw, dh) ->
    @width -= dw
    @height -= dh
    @

  deflatePoint: (pt) ->
    @width -= pt.x
    @height -= pt.y
    @

  union: (rect) ->
    l = if @x < rect.x then @x else rect.x
    r1 = @x + @width
    r2 = rect.x + rect.width
    r = if r1 > r2 then r1 else r2
    w = r - l
    t = if @y < rect.y then @y else rect.y
    b1 = @y + @height
    b2 = rect.y + rect.height
    b = if b1 > b2 then b1 else b2
    h = b - t
    @x = l
    @y = t
    @width = if w < 0 then 0 else w
    @height = if h < 0 then 0 else h
    @

  isEmpty: ->
    @x is 0 and @y is 0 and @width is 0 and @height is 0

  intersects: (rect) ->
    l = _max @x, rect.x
    r = _min @x + @width, rect.x + rect.width
    w = r - l
    return false if w <= 0
    t = _max @y, rect.y
    b = _min @y + @height, rect.y + rect.height
    h = b - t
    return false if h <= 0
    true

  intersection: (rect) ->
    l = _max @x, rect.x
    r = _min @x + @width, rect.x + rect.width
    w = r - l
    return new Rectangle() if w <= 0
    t = _max @y, rect.y
    b = _min @y + @height, rect.y + rect.height
    h = b - t
    return new Rectangle() if h <= 0
    new Rectangle l, t, w, h

  measureFarDistance: (x, y) ->
    l = @x
    r = @x + @width
    t = @y
    b = @y + @height
    dl = x - l
    dr = x - r
    dt = y - t
    db = y - b
    dl = dl * dl
    dr = dr * dr
    dt = dt * dt
    db = db * db
    min = _max dl + dt, dr + dt, dr + db, dl + db
    _sqrt min

  adjustOuter: ->
    x = Math.floor @x
    y = Math.floor @y
    if x isnt @x
      @width++
    if y isnt @y
      @height++
    @x = x
    @y = y
    @width = Math.ceil @width
    @height = Math.ceil @height
    @

  transform: (matrix) ->
    lt = new Matrix 1, 0, 0, 1, @x, @y
    rt = new Matrix 1, 0, 0, 1, @x + @width, @y
    rb = new Matrix 1, 0, 0, 1, @x + @width, @y + @height
    lb = new Matrix 1, 0, 0, 1, @x, @y + @height
    lt.concat matrix
    rt.concat matrix
    rb.concat matrix
    lb.concat matrix
    l = _min lt.ox, rt.ox, rb.ox, lb.ox
    r = _max lt.ox, rt.ox, rb.ox, lb.ox
    t = _min lt.oy, rt.oy, rb.oy, lb.oy
    b = _max lt.oy, rt.oy, rb.oy, lb.oy
    @x = l
    @y = t
    @width = r - l
    @height = b - t
    @



class sc.ript.path

  @join: (pathes...) ->
    pathes = pathes.join('/').replace(/\/{2,}/g, '/').split('/');
    normalized = []
    for path in pathes
      switch path
        when '.'
          # do nothing
          break
        when '..'
          last = normalized[normalized.length - 1]
          if last? && last isnt '..'
            normalized.pop()
          else
            normalized.push path
          break
        else
          normalized.push path
          break
    return normalized.join '/'



class sc.ript.serializer.QueryString

  {Type} = sc.ript.util

  @stringify: (obj, sep = '&', eq = '=') ->
    kvs = []
    for key, val of obj
      kvs.push "#{key}#{eq}#{val}"
    kvs.join sep

  @parse: (str, sep = '&', eq = '=', {maxKeys} = {}) ->
    maxKeys = 1000 unless maxKeys?
    obj = {}
    for kv, i in str.split sep
      break if maxKeys isnt 0 and i > maxKeys
      [k, v] = kv.split eq
      if obj[k]?
        if Type.isArray obj[k]
          obj[k].push v
        else
          obj[k] = [obj[k], v]
      else
        obj[k] = v
    obj





class sc.ript.util.ByteArray

  @BlobBuilder: window.BlobBuilder or window.WebKitBlobBuilder or window.MozBlobBuilder or window.MSBlobBuilder

  @fromDataURL: (dataURL) ->
    mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0]
    byteString = atob dataURL.split(',')[1]

    ab = new ArrayBuffer byteString.length
    ia = new Uint8Array ab
    for i in [0...byteString.length] by 1
      ia[i] = byteString.charCodeAt i

    if @BlobBuilder?
      bb = new @BlobBuilder
      bb.append ia.buffer
      bb.getBlob mimeString
    else if window.Blob?
      new Blob [ab], type: mimeString

# for Chrome
#      new Blob [ia], type: mimeString



class sc.ript.util.NumberUtil

  @RADIAN_PER_DEGREE: Math.PI / 180
  @DEGREE_PER_RADIAN: 180 / Math.PI
  @KB               : 1024
  @MB               : @KB * @KB
  @GB               : @MB * @KB
  @TB               : @GB * @KB

  @degree: (radian) ->
    radian * @DEGREE_PER_RADIAN

  @radian: (degree) ->
    degree * @RADIAN_PER_DEGREE

  @signify: (value, digit) ->
    base = Math.pow 10, digit
    (value * base >> 0) / base

  @kb: (bytes) ->
    bytes / @KB

  @mb: (bytes) ->
    bytes / @MB

  @gb: (bytes) ->
    bytes / @GB

  @random: (a, b) ->
    a + (b - a) * Math.random()



class sc.ript.util.StringUtil



class sc.ript.util.Type

  { toString, hasOwnProperty } = Object.prototype

  @isElement: (value) ->
    value?.nodeType is 1

  @isArray: Array.isArray or (value) ->
    toString.call(value) is '[object Array]'

  @isArguments: do ->
    isArguments = (value) ->
      toString.call(value) is "[object Arguments]"
    if isArguments arguments
      isArguments
    else
      (value) ->
        value? and hasOwnProperty.call(value, 'callee')


  @isFunction: do ->
    if typeof /./ is 'function'
      (value) ->
        toString.call(value) is "[object Function]"
    else
      (value) ->
        typeob value is 'function'

  @isString: (value) ->
    toString.call(value) is "[object String]"

  @isNumber: (value) ->
    toString.call(value) is "[object Number]"

  @isDate: (value) ->
    toString.call(value) is "[object Date]"

  @isRegExp: (value) ->
    toString.call(value) is "[object RegExp]"

  @isFinite: (value) ->
    isFinite(value) and not isNaN(parseFloat(value))

  @isNaN: (value) ->
    @isNumber(value) and value isnt +value

  @isBoolean: (value) ->
    value is true or value is false or toString.call(value) is "[object Boolean]"

  @isNull: (value) ->
    value is null

  @isUndefined: (value) ->
    value?

  @isObject: (value) ->
    value is Object value


