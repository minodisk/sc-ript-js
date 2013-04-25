#package sc.ript.utils

class ByteArray

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

