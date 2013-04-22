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