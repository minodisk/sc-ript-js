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