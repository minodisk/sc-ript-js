class sc.ript.jquery.Preloader extends sc.ript.event.EventEmitter

  { Event } = sc.ript.event
  { Type } = sc.ript.util


  constructor: ->
    super()
    @urls = []

  addElement: (el) ->
    for e in $ el
      @urls.push.apply @urls, @_findURLs e
    @

  addURL: (url) ->
    @urls.push url
    @

  load: ->
    total = @urls.length
    loaded = 0
    for url in @urls
      $('<img>')
        .attr('src', url)
        .on 'load error', =>
          @emit new Event 'progress',
            loaded: ++loaded
            total : total
          if loaded is total
            @emit new Event 'complete'
    @


  _findURLs: (el) ->
    urls = []
    @_findURL el, urls
    for el in $(el).find('*')
      @_findURL el, urls
    urls

  _findURL: (el, urls) ->
    if el.nodeName is 'IMG' and (url = $(el).attr('src'))?
      urls.push url
    if (url = $(el).css('background-image')) isnt 'none'
      [ {},
        url ] = url.match /url\((.*)\)/
      if url?
        urls.push url


