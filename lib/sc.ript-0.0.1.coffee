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


class Bitmap

  constructor: (@canvas) ->
    @context = @canvas.getContext '2d'

  width: (value) ->
    return @canvas.width unless value?
    @canvas.width = value

  height: (value) ->
    return @canvas.height unless value?
    @canvas.height = value

  clear: ->
    @canvas.width = @canvas.width

  draw: (image) ->
    @context.drawImage image, 0, 0

  drawAt: (image, point) ->
    @context.drawImage image, point.x, point.y

  drawTo: (image, rect) ->
    @context.drawImage image, rect.x, rect.y, rect.width, rect.height

  drawFromTo: (image, from, to) ->
    @context.drawImage image, from.x, from.y, from.width, from.height, to.x, to.y, to.width, to.height

  encodeAsPNG: ->
    @canvas.toDataURL 'image/jpeg'

  encodeAsJPG: (quality = 0.8) ->
    @canvas.toDataURL 'image/jpeg', quality




#package sc.ript.events


class Event

  constructor: (@type, @data) ->


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



#package sc.ript.geom


class Rectangle

  constructor: (@x = 0, @y = 0, @width = 0, @height = 0) ->



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

  @random: (a, b) ->
    a + (b - a) * Math.random()



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
        "Bitmap": Bitmap
      },
      "events": {
        "Event": Event,
        "EventEmitter": EventEmitter
      },
      "geom": {
        "Point": Point,
        "Rectangle": Rectangle
      },
      "path": path,
      "utils": {
        "NumberUtil": NumberUtil
      },
      "ui": {
        "Button": Button
      }
    }
  }
}