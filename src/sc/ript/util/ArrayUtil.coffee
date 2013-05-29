class sc.ript.util.ArrayUtil

  slice = Array::slice


  @unique: (arr) ->
    arr = slice.call arr
    storage = {}
    for elem, i in arr
      if storage[elem]
        arr.splice i--, 1
      storage[elem] = true
    arr

  @one: (arr) ->
    arr[arr.length * Math.random() >> 0]
