#package sc.ript.serializer

class QueryString

  @stringify: (obj, sep = '&', eq = '=') ->
    kvs = []
    for key, val of obj
      kvs.push "#{key}#{eq}#{val}"
    kvs.join sep
