{Type} = sc.ript.utils

class QueryString

  @stringify: (obj, sep = '&', eq = '=') ->
    kvs = []
    for key, val of obj
      kvs.push "#{key}#{eq}#{val}"
    kvs.join sep

  @parse: (str, sep = '&', eq = '=', {maxKeys}) ->
    maxKeys = 1000 unless maxKeys?
    obj = {}
    for kv, i in str.split sep
      break if maxKeys isnt 0 and i > maxKeys
      [k, v] = kv.split sep
      if obj[k]?
        if Type.isArray obj[k]
          obj[k].push v
        else
          obj[k] = [obj[k], v]
      else
        obj[k] = v
    obj



