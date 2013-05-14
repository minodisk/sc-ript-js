class sc.ript.ui.Button extends sc.ript.event.EventEmitter

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

