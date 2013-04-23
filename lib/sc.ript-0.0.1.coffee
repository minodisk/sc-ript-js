#package sc.ript.deferred


class DLoader

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



#package sc.ript.display

class GraphicsPathCommand

  @NO_OP         : 0
  @MOVE_TO       : 1
  @LINE_TO       : 2
  @CURVE_TO      : 3
  @WIDE_MOVE_TO  : 4
  @WIDE_LINE_TO  : 5
  @CUBIC_CURVE_TO: 6


#package sc.ript.display

class JointStyle

  @BEVEL: 'bevel'
  @MITER: 'miter'
  @ROUND: 'round'

#package sc.ript.events


class Event

  constructor: (@type, @data) ->


#package sc.ript.display

class CapsStyle

  @NONE  : 'butt'
  @BUTT  : 'butt'
  @ROUND : 'round'
  @SQUARE: 'square'

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









#package sc.ript.geom


class Rectangle

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



#package sc.ript

class path

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



class ColorUtil

  @toCSSString: (color, alpha = 1) ->
    r = color >> 16 & 0xff
    g = color >> 8 & 0xff
    b = color & 0xff
    alpha = if alpha < 0 then 0 else if alpha > 1 then 1 else alpha
    if alpha is 1
      "rgb(#{r},#{g},#{b})"
    else
      "rgba(#{r},#{g},#{b},#{alpha})"

#package sc.ript.utils

class ByteArray

  @BlobBuilder: window.BlobBuilder or window.WebKitBlobBuilder or window.MozBlobBuilder

  @fromDataURL: (dataURL) ->
    mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0]
    byteString = atob dataURL.split(',')[1]

    ab = new ArrayBuffer byteString.length
    ia = new Uint8Array ab
    for i in [0...byteString.length] by 1
      ia[i] = byteString.charCodeAt i

    if @BlobBuilder?
      bb = new ByteArray.BlobBuilder
      bb.append ab
      new ByteArray bb.getBlob mimeString
    else
      new ByteArray new Blob [ab], type: mimeString

# for Chrome
#      new ByteArray new Blob [ia], type: mimeString


  constructor: (@data) ->

  length: ->
    @data.size


#package sc.ript.events


class EventEmitter

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

#package sc.ript.utils

class NumberUtil

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



#package sc.ript.geom

class Point

  @equals: (pt0, pt1) ->
    pt0.x is pt1.x and pt0.y is pt1.y

  @dotProduct: (pt0, pt1) ->
    pt0.x * pt1.x + pt0.y * pt1.y

  @angle: (pt0, pt1) ->
    pt1.subtract(pt0).angle()

  @distance: (pt0, pt1) ->
    pt1.subtract(pt0).length()

  @interpolate: (pt0, pt1, ratio) ->
    pt0.add pt1.subtract(pt0).multiply(ratio)


  constructor: (@x = 0, @y = 0) ->

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

  add: (pt) ->
    new Point @x + pt.x, @y + pt.y

  subtract: (pt) ->
    new Point @x - pt.x, @y - pt.y

  multiply: (value) ->
    new Point @x * value, @y * value

  divide: (value) ->
    new Point @x / value, @y / value



#package sc.ript.ui


class Button extends EventEmitter

  @FULL:
    out     : '_out'
    over    : '_over'
    down    : '_down'
    disabled: '_disabled'

  @DEFAULT:
    out : '_out'
    over: '_over'

  @TOUCH:
    out     : '_out'
    disabled: '_disabled'

  @defaultPostfixes:
    out : '_out'
    over: '_over'


  constructor: (@$elem, @postfixes, @recursive = false)->
    super()

    throw new TypeError 'element isn\'t exist' unless @$elem?.length > 0

    @postfixes = Button.defaultPostfixes unless @postfixes?

    if @$elem[0].nodeName is 'IMG'
      $imgs = @$elem
    else if @recursive
      $imgs = @$elem.find 'img'
    else
      $imgs = @$elem.children 'img'

    @_namePartsRegistry = {}
    @_imgs = []

    postfixes = []
    for key, postfix of @postfixes
      postfixes.push postfix

    for img in $imgs
      $img = $ img
      src = $img.attr 'src'
      continue unless src?

      for postfix, i in postfixes
        continue unless postfix?

        nameParts = src.match RegExp "^(.*)#{postfix}(\\.\\w+)$"
        continue unless nameParts?.length is 3

        @_namePartsRegistry[img] = nameParts
        unloadedPostfixes = postfixes.slice()
        unloadedPostfixes.splice i, 1
        @_preload nameParts, unloadedPostfixes
        @_imgs.push $img
        break

    @$elem
      .on('click', @_onClick)
      .on('mouseleave', @_onMouseOut)
      .on('mouseenter', @_onMouseOver)
      .on('mousedown', @_onMouseDown)
      .on('mouseup', @_onMouseUp)
    @enabled true

  destruct: ->
    @$elem
      .off('click', @_onClick)
      .off('mouseleave', @_onMouseOut)
      .off('mouseenter', @_onMouseOver)
      .off('mousedown', @_onMouseDown)
      .off('mouseup', @_onMouseUp)
    delete @$elem
    delete @postfixes
    delete @recursive
    delete @_enabled
    delete @_status
    delete @_isMouseOver
    delete @_namePartsRegistry
    delete @_imgs

  enabled: (value) ->
    return @_enabled unless value?
    return @ if @_enabled is value

    if value
      @_enabled = value
      @$elem
        .css('cursor', 'pointer')
      @_onMouseUp()
    else
      @$elem
        .css('cursor', 'default')
      @_onMouseOut()
      @status 'disabled'
      @_enabled = value
    @

  status: (value) ->
    return @_status unless value?
    return @ if @_status is value

    postfix = @postfixes[value]
    return @ unless postfix?

    @_status = value
    for $img in @_imgs
      nameParts = @_namePartsRegistry[$img[0]]
      src = nameParts[1] + postfix + nameParts[2]

      vml = $img[0].vml
      if vml
        vml.image.fill.setAttribute 'src', src
        continue

      $img.attr 'src', src

  _preload: (nameParts, postfixes) ->
    for postfix in postfixes
      continue unless postfix?
      $('<img>').attr 'src', nameParts[1] + postfix + nameParts[2]

  _onMouseOut: (e) =>
    @_isMouseOver = false
    return unless @_enabled
    @status 'out'
    @emit e if e

  _onMouseOver: (e) =>
    @_isMouseOver = true
    return unless @_enabled
    @status 'over'
    @emit e if e

  _onMouseDown: (e) =>
    return unless @_enabled
    @status 'down'
    @emit e if e

  _onMouseUp: (e) =>
    return unless @_enabled
    @status if @_isMouseOver then 'over' else 'out'
    @emit e if e

  _onClick: (e) =>
    return unless @_enabled
    @emit e if e



window[k] = v for k, v of {
  "sc": {
    "ript": {
      "deferred": {
        "DLoader": DLoader
      },
      "display": {
        "GraphicsPathCommand": GraphicsPathCommand,
        "JointStyle": JointStyle,
        "CapsStyle": CapsStyle,
        "Bitmap": Bitmap
      },
      "events": {
        "Event": Event,
        "EventEmitter": EventEmitter
      },
      "geom": {
        "Rectangle": Rectangle,
        "Point": Point
      },
      "path": path,
      "utils": {
        "ColorUtil": ColorUtil,
        "ByteArray": ByteArray,
        "NumberUtil": NumberUtil
      },
      "ui": {
        "Button": Button
      }
    }
  }
}