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

  draw: (image, matrix) ->
    if matrix?
      @context.setTransform matrix.m11, matrix.m12, matrix.m21, matrix.m22, matrix.tx, matrix.ty
    @context.drawImage image, 0, 0

  encodeAsPNG: ->
    ByteArray.fromDataURL @canvas.toDataURL 'image/png'

  encodeAsJPG: (quality = 0.8) ->
    ByteArray.fromDataURL @canvas.toDataURL 'image/jpeg', quality


