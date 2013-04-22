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


