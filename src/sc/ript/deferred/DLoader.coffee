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

